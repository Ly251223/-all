clear,clc
close all;

%%
str=dir('C:\Users\81702\Desktop\battery_dataset\*.mat');
% str = '/Users/81702/Desktop/RUL-Prediction-Battery-master/data/B0005.mat';
i=1;
var = load(str(i).name); %namelist(i).name 05,06,07,18

[s05,cycle] = SOH(var.B0005.cycle); % s=capacity for each discharged  [168,1]
%type,ambient_temperature,time,data

% % function [s,c] = SOH(var)
% % %var = var.B0005.cycle;
% % c = 0;
% % s = [];
% % for i = 1 : size(var,2)
% %     type = var(i).type;
% %     if type == "discharge"
% %         c = c + 1;
% %         cap = var(i).data.Capacity;
% %         s = [s;cap];
% %     end
% % end
% %     %s = s/s(1);
% % end

% discharge battery
figure
title('Capacity degradation curve at 24 degree')
hold on
plot(1:size(s05,1),s05, '-', 'color','m', 'linewidth', 1.5);
%%
str = 'B0006.mat';
var = load(str);
[s06,cycle] = SOH(var.B0006.cycle);
hold on
plot(1:size(s06,1),s06, '-', 'color','b', 'linewidth', 1.5);
%%
str = 'B0007.mat';
var = load(str);
[s07,cycle] = SOH(var.B0007.cycle);
hold on
plot(1:size(s07,1),s07, '-', 'color','r', 'linewidth', 1.5);
%%
str = 'B0018.mat';
var = load(str);
[s18,cycle] = SOH(var.B0018.cycle);
hold on
plot(1:size(s18,1),s18, '-', 'color','g', 'linewidth', 1.5);
hold on

line([0,size(s05,1)],[1.4,1.4],'Color','red','linewidth', 1.5,'LineStyle','--');
% line([500,2500],[1.05,1.05],'linestyle',':');
xlabel('Charge and discharge cycle/Cycle');
ylabel('Actual Capacity/Ah');
legend({ '#5 Battery','#6 Battery','#7 Battery','#18 Battery','70% rated capacity'});