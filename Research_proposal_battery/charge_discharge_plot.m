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

pause
%% 放电
% 以2A的恒定电流（CC）模式进行放电，直到电池 5、6、7 和 18的电压降到
% 2.7V，2.5V，2.2V 和 2.5V。
T_dis = [];
V_discharge = {}; % Voltage_measured
figure
for j = 1:N %
    if strcmp(var(j).type, 'discharge') %放电循环里才有容量数据
        cyc = cyc +1;
        %  capacity_B18(cyc,:) = B0018.cycle(i).data.Capacity;
        V = var(j).data.Voltage_measured;
        V_discharge{j} = V';
        plot(var(j).data.Time,V),hold on
        T_dis = [T_dis;var(j).data.Time(end)];


        %  grid('on');
        %  I_charge = [I_charge;I];
    end
end
xlim([0, max(T_dis)])
xlabel('Time(s)');
ylabel('Voltage(V)');
title('Discharging curve','FontSize',13)

V_discharge(cellfun(@isempty,V_discharge))=[];
figure
for i = [1,60,size(V_discharge,2)] %
    plot(V_discharge{i},'linewidth', 1.5),hold on
end
xlim([0, 400])
legend({'discharge time：1','discharge time：60','discharge time：end'});
xlabel('Time(s)');
ylabel('Voltage(V)');
title('Discharging curve','FontSize',13)
%%%%%%%%%%%%%%%%%%%%%%
I_dis = [];
I_discharge = {}; % Current_measured
figure
for j = 1:N %
    if strcmp(var(j).type, 'discharge') %放电循环里才有容量数据
        cyc = cyc +1;
        %  capacity_B18(cyc,:) = B0018.cycle(i).data.Capacity;
        Current_dis = var(j).data.Current_measured;
        plot(var(j).data.Time,Current_dis),hold on
        T_dis = [T_dis;var(j).data.Time(end)];
        I_discharge{j} = Current_dis'; % save I
    end
end
xlim([0, max(T_dis)])
xlabel('Time(s)');
ylabel('Current(A)');
title('Discharging curve of measured current','FontSize',13)

I_discharge(cellfun(@isempty,I_discharge))=[];
figure
for i = [1,60,size(I_discharge,2)] %
    plot(I_discharge{i},'linewidth', 1.5),hold on
end
xlim([0, 400])
legend({'discharge time：1','discharge time：60','discharge time：end'});
xlabel('Time(s)');
ylabel('Current(A)');
title('Discharging curve of measured current','FontSize',13)

%%
% 获取锂电池充电或放电时的测试数据
%  getBatteryValues(Battery, Type='charge'):
%     data=[]
%     for Bat in Battery:
%         if Bat['type'] == Type:
%             data.append(Bat['data'])
%     return data

%% Read all data %%
% path='D:\my_data\test data\IV data\20171116\'
% %此处文件地址改为需要的文件夹路径
% Files = dir(strcat(path,'*.xlsx'));

% kk=datetime(2008,4,2,16,37,51.984)-datetime(2008,4,2,13,8,17.921);
% kk.Format='s'
% kk.Format='m'

% % clc
% % clear,close all
% % str = 'B0005.mat';
% % var = load(str);
% % var =var.B0005.cycle;
% % c = 0;
% % s = [];
% %
% % % for i = 1 : size(var,2)
% % for i = 1:10% 4 times
% %     type = var.type;
% %     if type == "charge"
% %         c = c + 1;
% %         cap = var(i).data.Current_charge;
% %         s = [s;cap];
% %     end
% % end
% % xlabel('Time');
% % ylabel('Current (A)');
% % legend({ 'charge time：0','charge time：50','charge time：100'});
% % % figure,
% % % plot(1:size(s,1),s, '-', 'color','b', 'linewidth', 1.5);
% % % hold on



% legend({'Cumulative','Individual'},'FontSize',11)
% text(2.5,80,'第１+第２主成分で約９０％', 'FontSize',15,'Color','red');

% figure('Name', 'Plot imported data', 'NumberTitle', 'off', 'Units', 'normalized', 'Position', [0.05, 0.25, 0.80, 0.58]);
% for k = 1:24
%     subplot(4,6,k);
%     plot(sensorData.Time, sensorData{:,2+k})
%     title(sensorData.Properties.VariableNames{2+k});
%     xlabel('Time'); xlim([0, sensorData.Time(end)]); grid('on');
% end