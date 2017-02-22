clc;
clear;
close all;
set_figure_style_pre()
legend_info = {};

%%
Vout = 1;
Vin = 6;
Iout = 1;
dI = 0.1;
fsw = 100e3;
L = 10e-6;
Vm = (Vout):0.1:(Vin);

%% 1 stage buck
gv2_1stage = 1*Vin^2      % GV^2 for 1 staage buck
L = Vout.*(1-Vout./Vin)/(fsw*dI*Iout);
E_L = L*Iout^2;
plot([Vm(1) Vm(end)],[E_L E_L],'--')
hold on;
legend_info{end+1} = '1 stage buck';

set_figure_style();

%% 2 stage buck
fsw1 = fsw;
fsw2 = fsw;
Im = Iout*Vout./Vm;

gv2_2stage2 = 1*Vm.^2*2;   % Gv^2 for the second stage
% gv2_2stage1 = gv2_1stage - gv2_2stage2; % Gv^2 budget left for the first stage
gv2_2stage1 = 1./(Vm/Vout)*Vin^2;    


L1 = Vm.*(1-Vm./Vin)./(fsw1*dI.*Im);
L2 = Vout.*(1-Vout./Vm)/(fsw2*dI*Iout);
E_L1 = L1.*Im.^2;
E_L2 = L2*Iout^2;

plot(Vm,E_L1)
hold on;
plot(Vm,E_L2)
plot(Vm, E_L1+E_L2)

legend_info{end+1} = '2-stage buck, 1st stage';
legend_info{end+1} = '2-stage buck, 2nd stage';
legend_info{end+1} = '2-stage buck, total';
legend(legend_info,'Location','Best')

set_figure_style();

%% Looks at the simple switch stress defined as Vsw*Isw
figure
% 1-stage
stress1 = Vin*Iout;
% 2-stage
stress2_1 = Vin*Iout.*(Vout./Vm);
stress2_2 = Vin*Iout.*(Vm/Vin);
stress2 = stress2_1 + stress2_2;

plot([Vm(1) Vm(end)],[stress1 stress1])
hold on;
plot(Vm,stress2_1)
plot(Vm,stress2_2)
plot(Vm,stress2)

legend('1-stage','2-stage 1st','2-stage 2nd','2-stage total','Location','Best')
set_figure_style()
