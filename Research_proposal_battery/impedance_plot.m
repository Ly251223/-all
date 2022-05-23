%% 充电
clear,clc
close all

% filename={'B0005.mat'};
var = load('B0018.mat');%  struct with fields: B0005: [1×1 struct]
var =var.B0018.cycle;
N = size(var,2);
cyc=0;
I_charge = {};
T_c = [];

% 充电：以 1.5A 的恒定电流（CC）模式进行充电，直到电池电压达到 4.2V，
% 然后以恒定电压（CV）模式充电，直到充电电流降至 20mA。
figure
for i = 1:N %
    if strcmp(var(i).type, 'charge') %
        cyc = cyc +1;
        %  capacity_B18(cyc,:) = B0018.cycle(i).data.Capacity;
        I = var(i).data.Current_charge;
        I_charge{i} = I;
        plot(var(i).data.Time, I),hold on
        T_c = [T_c;var(i).data.Time(end)];
        %  xlim([0, sensorData.Time(end)]);
        %  grid('on');

    end
end
xlim([0, max(T_c)])
xlabel('Time(s)');
ylabel('Current(A)');
title('Charging curve of measured current','FontSize',13)

% isequal(A,[]);
% isempty(I_charge{i})
I_charge(cellfun(@isempty,I_charge))=[];

figure
for i = [1,60,size(I_charge,2)] %
    plot(I_charge{i},'linewidth', 1.5),hold on
end
xlim([0, 3000])
legend({'charge time：1','charge time：60','charge time：end'});
xlabel('Time(s)');
ylabel('Current(A)');
title('Charging curve of measured current','FontSize',13)
%% 充电时电压

V_mea = {}; % V_measured
figure
for j = 1:N %
    if strcmp(var(j).type, 'charge') %
        cyc = cyc +1;
        %  capacity_B18(cyc,:) = B0018.cycle(i).data.Capacity;
        V_charge = var(j).data.Voltage_measured;
        plot(var(j).data.Time,V_charge),hold on
        T_c = [T_c;var(j).data.Time(end)];
        V_mea{j} = V_charge'; % save I
    end
end
xlim([0, max(T_c)])
xlabel('Time(s)');
ylabel('Voltage(V)');
title('Charging curve of measured voltage','FontSize',13)

V_mea(cellfun(@isempty,V_mea))=[];
figure
for i = [1,60,size(V_mea,2)] %
    plot(V_mea{i},'linewidth', 1.5),hold on
end
% xlim([0, 400])
legend({'charge time：1','charge time：60','charge time：end'});
xlabel('Time(s)');
ylabel('Voltage(V)');
title('Charging curve of measured voltage','FontSize',13)
