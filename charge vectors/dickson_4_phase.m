
clc;

disp('Dickson')
display('Voltage vectors')
% [in C3 C2 C1 out]
A=[1 -1 0 0 -1; 0 0 1 -1 -1; 0 1 -1 0 -1; 0 0 0 1 -1];
A(:,1:end-1)
null(A(:,1:end-1))
A1=A(1:2,2:end);
A2=A(3:end,2:end);
A3=[1 0 0 0 0; 0 0 1 -1 -1];
A4=[0 1 -1 0 -1; 1 0 0 0 0];
NullA1=null(A1);
NullA1=[1 1; NullA1(1:end-1,1:end)]
NullA2=null(A2);
NullA2=[1 1; NullA2(1:end-1,1:end)]
NullA3=null(A3);
NullA3=NullA3(1:end-1,1:end)
NullA4=null(A4);
NullA4=NullA4(1:end-1,1:end)

B1=[NullA1 -NullA2];
NullB1=null(B1)
B2=[NullA4 -NullA2];
NullB2=null(B2);
B3=[NullA2 -NullA3];
NullB3=null(B3);
B4=[NullA3 -NullA1];
NullB4=null(B4);


dv1=NullA1
dv2=NullA2
dv3=NullA3
dv4=NullA4
% dv_1=[0  0; null(A1)*NullB1(1:2,:)]
% dv_2=null(A4)*NullB1(3:4)
% dv_1=null(A4)*NullB2(1:2)
% dv_2=null(A2)*NullB2(3:4)
% dv_1=null(A2)*NullB3(1:2)
% dv_2=null(A3)*NullB3(3:4)
% dv_1=null(A3)*NullB4(1:2)
% dv_2=null(A1)*NullB4(3:4)

%% Charge vector
display('Charge vectors')
% [in C3 C2 C1 out]
A1=[0 1 0 1 -1;1 0 1 0 1;-1 -1 0 0 0];
NullA1_0=null(A1);
NullA1=NullA1_0(2:end-1,1:end);
A2=[0 1 1 0 0; 0 1 0 1 1; 0 0 1 -1 -1; 1 0 0 0 0]; 
NullA2_0=null(A2);
NullA2=NullA2_0(2:end-1,1:end);

A3=[0 0 1 1 0; 0 0 0 1 1; 0 1 0 0 0;1 0 0 0 0]; % new 1
NullA3_0=null(A3);
NullA3=NullA3_0(2:end-1,1:end);

%q_in=0
A4=[0 1 1 0 0; 0 0 1 0 1; 0 0 0 1 0; 1 0 0 0 0]; % new 2
NullA4_0=null(A4);
NullA4=NullA4_0(2:end-1,1:end);


B=null([NullA1 NullA2 NullA3 NullA4]);

q1=[0 0; NullA1];
q2=[0 0; NullA2];
q3=[0; NullA3];
q4=[0; NullA4];
% q1=null(A1)*B(1:2,:)

%% Combine voltage and charge vector to solve for soft-charging condition
c=[0 1 2 3]'; % [0 C3 C2 C1]
dv1=dv1.*[c c];
dv2=dv2.*[c c];
NullQ1=null([dv1 -q1]);
q1=q1*NullQ1(3:4);
NullQ2=null([dv2 -q2]);
q2=q2*NullQ2(3:4);
NullQ=null([q1 q2 q3 q4]);


q1a = NullA1_0*NullQ1(3:4)*NullQ(1)
q2a = NullA2_0*NullQ2(3:4)*NullQ(2)
q1b = NullA3_0*NullQ(3)
q2b = NullA4_0*NullQ(4)

% duty ratio of each phase
duties = abs([q1a(end) q2a(end) q1b(end) q2b(end)]);
duties = duties/sum(duties)