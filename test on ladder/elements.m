%% This file defines the circuit element class
%% The element class contains all the information of the element
%%  The constructor of the class parse the netlist and store the inforamtion depending on the type of the device
classdef elements
    properties (Access=public)
        identifier      % name of the element
        type            % type of the element
        number_of_nodes
        number_of_currents
        list_of_nodes   % list of node connected by the element
        self_current    % the current of the element
        controlling_current % the current that is the controlling variable
        value           % parameter of the element, such as R,C,L,alpha
    end
    methods
        function obj = elements(cline,tline)
            identifier=char(cline{1}(1));
            obj.identifier=identifier;
            obj.self_current={strcat('i',identifier)};            
            obj.value=str2num(char(cline{1}(end)));
            switch identifier(1)
                case 'R'        % resistor
                    obj.type='R';
                    obj.number_of_nodes=2;
                case 'C'
                    if length(identifier)>=4
                        switch identifier(1:4)
                            case 'CCVS' % current controlled voltage source
                                obj.type='CCVS';
                                obj.number_of_nodes=2;
                                obj.controlling_current={strcat('i',identifier);char(cline{1}(4))};

                            case 'CCCS' % current controlled current source
                                obj.type='CCCS';
                                obj.number_of_nodes=2;
                                obj.controlling_current={char(cline{1}(4))};

                            otherwise   % capacitor
                                obj.type='C';
                                obj.number_of_nodes=2;
                              
                        end
                    else                % capacitor
                        obj.type='C';
                        obj.number_of_nodes=2;
                       
                    end
                case 'L'            % indcutor
                    obj.type='L';
                    obj.number_of_nodes=2;
                    obj.controlling_current={strcat('i',identifier)};

                case 'V'
                      if length(identifier)>=4          
                        switch identifier(1:4)
                            case 'VCVS' % voltage controlled voltage source
                                obj.type='VCVS';
                                obj.number_of_nodes=4;
                                obj.controlling_current={strcat('i',identifier)};

                            case 'VCCS' % voltage controlled current source
                                obj.type='VCCS';
                                obj.number_of_nodes=4;

                            otherwise   % constant voltage source
                                obj.type='V';
                                obj.number_of_nodes=2;
                                obj.controlling_current={strcat('i',identifier)};

                        end
                    else              % constant voltage source
                        obj.type='V';
                        obj.number_of_nodes=2;
                        obj.controlling_current={strcat('i',identifier)};

                      end

                case 'I'            % constant current source
                    obj.type='I';
                    obj.number_of_nodes=2;
         
                case '.'
        %             do nothing;  % spice directive, igonore for now
                otherwise
                    disp('Unknown element type on the following line')
                    disp(tline);
            end
            obj.list_of_nodes=cline{1}(2:1+obj.number_of_nodes);

        end
    end
end