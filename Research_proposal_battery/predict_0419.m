% openExample('nnet/PredictBatterySOCUsingDeepLearningExample')

clear all;
close all;
clc;

str = '/Users/81702/Desktop/RUL-Prediction-Battery-master/data/B0005.mat';
var = load(str);
[s,cycle] = SOH(var.B0005.cycle);
​
load('B0007')
cycles1 = B0007.cycle; % 保存步骤数组到新变量
​
counter = 0; 
counter1 = 0;
​​
output=net(input);
prediction=mapminmax('reverse',output,ps2);
SOH=prediction;
​
input2=mapminmax('apply',p_t2,ps1);%应用之前的种子归一化
output2=net(input2);
prediction2=mapminmax('reverse',output2,ps2);
SOH2=prediction2;
% 
% figure(1);
% plot(t_t,'*r')
% hold on
% plot(SOH,'-')
% legend('训练数据','BP预测训练数据')
% xlabel('锂电池充放电次数');
% ylabel('锂电池健康状态SOH');
figure(3);
plot(t_t2,'-*r')
hold on
plot(SOH2,'-b')
% legend('被预测数据','BP预测值')
% xlabel('锂电池充放电次数');
% ylabel('锂电池健康状态SOH');
% title('电池健康状态变化曲线')