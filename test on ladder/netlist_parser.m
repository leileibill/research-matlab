%% This script reads a spice netlist and parse all the information required for MNA stamping
function [A b]=netlist_parser()
clc;
clear all;


circuit={};             % a cell array that contains all the elements
omega=1;                % Frequency

%% File handling
fid = fopen('sample_netlist.txt');  % open netlist file
tline = fgets(fid);     % read netlist into lines

while ischar(tline)     % parse through each line
%     disp(tline);
    cline=textscan(tline,'%s',-1,'delimiter',' ');
    identifier=char(cline{1}(1));
    if identifier(1)=='*'
        tline = fgets(fid); % read next line
        continue;       % pass any comment line
    end
    
    element=elements(cline,tline);
    circuit{end+1}=element;
    
    tline = fgets(fid); % read next line
end
fclose(fid);

%% This scritp generates the MNA matrix from the circuit

node_list={};
current_list={};

%% Get all control variables, i.e. the vector x
for index=1:length(circuit)
    node_list=[node_list; circuit{index}.list_of_nodes];
    current_list=[current_list; circuit{index}.controlling_current];
end
node_list=unique(node_list);
current_list=unique(current_list);
x=[node_list;current_list];

%% Create the matrix by stamping

A=zeros(length(x));
b=zeros(length(x),1);
for index=1:length(circuit)
    element=circuit{index};
    switch element.type
        case 'R'
            value=1/element.value;            
            [Lia,Loc1] = ismember(element.list_of_nodes{1},x);
            [Lia,Loc2] = ismember(element.list_of_nodes{2},x);
            A(Loc1,Loc1)=A(Loc1,Loc1)+value;
            A(Loc1,Loc2)=A(Loc1,Loc2)-value;
            A(Loc2,Loc1)=A(Loc2,Loc1)-value;
            A(Loc2,Loc2)=A(Loc2,Loc2)+value;
        case 'C'
            value=complex(0,omega*element.value);
            [Lia,Loc1] = ismember(element.list_of_nodes{1},x);
            [Lia,Loc2] = ismember(element.list_of_nodes{2},x);
            A(Loc1,Loc1)=A(Loc1,Loc1)+value;
            A(Loc1,Loc2)=A(Loc1,Loc2)-value;
            A(Loc2,Loc1)=A(Loc2,Loc1)-value;
            A(Loc2,Loc2)=A(Loc2,Loc2)+value;
        case 'L'
            value=complex(0,omega*element.value);
            [Lia,Loc1] = ismember(element.list_of_nodes{1},x);
            [Lia,Loc2] = ismember(element.list_of_nodes{2},x);
            [Lia,Loc3] = ismember(element.controlling_current{1},x);            
            A(Loc1,Loc3)=A(Loc1,Loc3)+1;
            A(Loc2,Loc3)=A(Loc2,Loc3)-1;
            A(Loc3,Loc1)=A(Loc3,Loc1)+1;
            A(Loc3,Loc2)=A(Loc3,Loc2)-1;
            A(Loc3,Loc3)=A(Loc3,Loc3)-value;
        case 'V'
            value=element.value;
            [Lia,Loc1] = ismember(element.list_of_nodes{1},x);
            [Lia,Loc2] = ismember(element.list_of_nodes{2},x);
            [Lia,Loc3] = ismember(element.controlling_current{1},x);            
            A(Loc1,Loc3)=A(Loc1,Loc3)+1;
            A(Loc2,Loc3)=A(Loc2,Loc3)-1;
            A(Loc3,Loc1)=A(Loc3,Loc1)+1;
            A(Loc3,Loc2)=A(Loc3,Loc2)-1;
            b(Loc3)=b(Loc3)+value;
        case 'I'
            value=element.value;
            [Lia,Loc1] = ismember(element.list_of_nodes{1},x);
            [Lia,Loc2] = ismember(element.list_of_nodes{2},x);
            b(Loc1)=b(Loc1)-value;
            b(Loc2)=b(Loc2)+value;

        case 'VCVS'
            value=element.value;            
            [Lia,Loc1] = ismember(element.list_of_nodes{1},x);
            [Lia,Loc2] = ismember(element.list_of_nodes{2},x);
            [Lia,Loc3] = ismember(element.list_of_nodes{3},x);
            [Lia,Loc4] = ismember(element.list_of_nodes{4},x);
            [Lia,Loc5] = ismember(element.controlling_current{1},x);            
            A(Loc1,Loc5)=A(Loc1,Loc5)+1;
            A(Loc2,Loc5)=A(Loc2,Loc5)-1;
            A(Loc5,Loc1)=A(Loc5,Loc1)+1;
            A(Loc5,Loc2)=A(Loc5,Loc2)-1;
            A(Loc5,Loc3)=A(Loc5,Loc3)-value;
            A(Loc5,Loc4)=A(Loc5,Loc4)+value;            
        case 'VCCS'
            value=element.value;            
            [Lia,Loc1] = ismember(element.list_of_nodes{1},x);
            [Lia,Loc2] = ismember(element.list_of_nodes{2},x);
            [Lia,Loc3] = ismember(element.list_of_nodes{3},x);
            [Lia,Loc4] = ismember(element.list_of_nodes{4},x);
            A(Loc1,Loc3)=A(Loc1,Loc3)+value;
            A(Loc1,Loc4)=A(Loc1,Loc4)-value;
            A(Loc2,Loc3)=A(Loc2,Loc3)-value;
            A(Loc2,Loc4)=A(Loc2,Loc4)+value;
        case 'CCVS'
            value=element.value;
            [Lia,Loc1] = ismember(element.list_of_nodes{1},x);
            [Lia,Loc2] = ismember(element.list_of_nodes{2},x);
            [Lia,Loc5] = ismember(element.self_current{1},x)
            [Lia,Loc6] = ismember(element.controlling_current{2},x)  
            
            A(Loc1,Loc5)=A(Loc1,Loc5)+1;
            A(Loc2,Loc5)=A(Loc2,Loc5)-1;
            A(Loc5,Loc1)=A(Loc5,Loc1)+1;
            A(Loc5,Loc2)=A(Loc5,Loc2)-1;
            A(Loc5,Loc6)=A(Loc5,Loc6)-value; 
            
            for j=1:length(circuit)
                element2=circuit{j};
                if strcmp(element2.self_current{1},element.controlling_current{1})==1
                    % check if this element has already been stamped using
                    % current before
                    [Lia,Loc3] = ismember(element2.list_of_nodes{1},x);
                    [Lia,Loc4] = ismember(element2.list_of_nodes{2},x);                    
    
                    if A(Loc5,Loc5)~=0
                        break
                    end
                        
                    % stamp this element2 using current as variable
                    switch element2.type 
                        case 'R'
                            value2=1/element2.value;            
                            A(Loc5,Loc3)=A(Loc5,Loc3)+1;
                            A(Loc5,Loc4)=A(Loc5,Loc4)-1;  
                            A(Loc5,Loc5)=A(Loc5,Loc5)-value2;                             

                        case 'C'
                            value2=complex(0,omega*element2.value);            
                            A(Loc5,Loc3)=A(Loc5,Loc3)+value2;
                            A(Loc5,Loc4)=A(Loc5,Loc4)-value2;  
                            A(Loc5,Loc5)=A(Loc5,Loc5)-1;  
                        case 'L'
                            % do nothing
                        case 'V'
                            % do nothing
                        case 'I'
                            value=element.value;
                            A(Loc5,Loc5)=A(Loc5,Loc5)+value2; 
                            b(Loc5)=b(Loc5)+value;
                    end
                    break
                end
            end   
                
        case 'CCCS'
            value=element.value;            
            [Lia,Loc1] = ismember(element.list_of_nodes{1},x);
            [Lia,Loc2] = ismember(element.list_of_nodes{2},x);
            [Lia,Loc5] = ismember(element.controlling_current{1},x); 
            A(Loc1,Loc5)=A(Loc1,Loc5)+value;
            A(Loc2,Loc5)=A(Loc2,Loc5)-value;

           %             A(Loc3,Loc5)=A(Loc5,Loc1)+1;
%             A(Loc4,Loc5)=A(Loc5,Loc2)-1;
            for j=1:length(circuit)
                element2=circuit{j};
                if strcmp(element2.self_current{1},element.controlling_current{1})==1
                    % check if this element has already been stamped using
                    % current before
                    [Lia,Loc3] = ismember(element2.list_of_nodes{1},x);
                    [Lia,Loc4] = ismember(element2.list_of_nodes{2},x);
  
                    if A(Loc5,Loc5)~=0
                        break
                    end
                        
                    % stamp this element2 using current as variable
                    switch element2.type 
                        case 'R'
                            value2=1/element2.value;            
                            A(Loc5,Loc3)=A(Loc5,Loc3)+1;
                            A(Loc5,Loc4)=A(Loc5,Loc4)-1;  
                            A(Loc5,Loc5)=A(Loc5,Loc5)-value2;                             

                        case 'C'
                            value2=complex(0,omega*element2.value);            
                            A(Loc5,Loc3)=A(Loc5,Loc3)+value2;
                            A(Loc5,Loc4)=A(Loc5,Loc4)-value2;  
                            A(Loc5,Loc5)=A(Loc5,Loc5)-1;  
                        case 'L'
                            % do nothing
                        case 'V'
                            % do nothing
                        case 'I'
                            value=element.value;
                            A(Loc5,Loc5)=A(Loc5,Loc5)+value2; 
                            b(Loc5)=b(Loc5)+value;
                    end
                    break
                end
            end
%             A(Loc5,Loc3)=A(Loc5,Loc3)-value;
%             A(Loc5,Loc4)=A(Loc5,Loc4)+value;          
            
        otherwise
            disp('Error: incorrect element type encountered during stamping')
    end
end

%% Remove the first row and first column (which is assumed to be ground)
A(1,:)=[];
A(:,1)=[];
b(1)=[];
x(1)=[]

end
