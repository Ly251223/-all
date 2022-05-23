% openExample('nnet/PredictBatterySOCUsingDeepLearningExample')
close all;
clear,clc

filename = 'B0006';
load(filename)
cycles1 = B0006.cycle; % 保存步骤数组到新变量

counter = 0; 
counter1 = 0;
counter2 = 0;% initialize counters初始化计数器

for i = 1:length(cycles1)-1 % search through the array of step structures

     if strcmp(cycles1(i).type,'charge') % charge
        counter1 = counter1+1;
        da = cycles1(i).data; % V,I,Temp,Current_charge,Volatge_charge
        Vin(counter1) = mean(da.Voltage_measured);
        Iin(counter1) = mean(da.Current_measured);
     end

    if strcmp(cycles1(i).type,'discharge') % discharge
        counter = counter+1;
        Time_c(counter)=counter-1; % start from 0
        da = cycles1(i).data;% 
        capacity1(counter) = da.Capacity; 
        % V,I,Temp,current_load,Volatge_load,Time,Capacity
        Vout(counter) = mean(da.Voltage_measured);
        Iout(counter) = mean(da.Current_measured);
        T(counter) = mean(da.Temperature_measured);
    end

    if strcmp(cycles1(i).type,'impedance')  %电阻抗
        counter2 = counter2+1;
        da = cycles1(i).data;
        R(counter2)= da.Rct;
    end
end
% Vin=Vin(:,1:131);
% Iin=Iin(:,1:131);
L = min(size(Vin,2),size(Vout,2));
Vin=Vin(:,1:L);%0005
Iin=Iin(:,1:L);

% S=capacity1/1.8565;
% S=capacity1;
S = capacity1/capacity1(1,1);
C1 = Time_c; % Time from 0
% In_all = [C1;Iout;Vout;Iin;Vin]; % features
In_all = [T;Iout;Vout;Iin;Vin]; % features  Temp
Out_soc = S; % SOC

% XTrain{4,1} = In_all;
% YTrain{4,1} = Out_soc;
%%
% p_t= In_all(:,33:93);
% t_t= Out_soc(:,33:93);
p_t= In_all(:,1:168);%train
t_t= Out_soc(:,1:168);
p_t2 = In_all(:,91:end);%test
t_t2 = Out_soc(:,91:end);
% setdemorandstream(2)

[input,ps1]  = mapminmax(p_t); % train_data
[target,ps2] = mapminmax(t_t); %
 
net=newff(input,target,[10,10],{
    'purelin','purelin','purelin'},'trainlm');
% net=newff(input,target,10,{
%     'purelin','purelin'},'trainlm');
% TF1='tansig';TF2='purelin';
% net=newff(input,target,[10,10],{TF1 TF2},'traingdm');%网络创建

% net.trainParam.epochs=1000; %最大训练次数
% net.trainParam.goal=0.00001;%目标最小误差
% LP.lr=0.000001;%学习速率
% net = train(net,input,target); % train the network
net.trainParam.epochs=10000;%训练次数设置
net.trainParam.goal=1e-7;%训练目标设置
net.trainParam.lr=1e-8;%学习率设置,应设置为较少值，太大虽然会在开始加快收敛速度，但临近最佳点时，会产生动荡，而致使无法收敛
net.trainParam.mc=0.9;%动量因子的设置，默认为0.9
net.trainParam.show=25;%显示的间隔次数
net = train(net,input,target); % train the network
 
%%
% In_test = In_all(:,91:end);%test
% Out_test = Out_soc(:,91:end);
% output_test = net(In_test); % Test
% prediction1 = mapminmax('reverse',output_test,ps2);
% % 'reverse',预处理之后的数据进行反转得到原始数据。
% SOH = prediction1;
% 
% figure(1);
% plot(t_t,'*r')
% hold on
% plot(SOH,'-b')
% legend('original data','BP predicted')
% xlabel('cycle of Li battery');
% ylabel('battery health state SOH');

%% Train data
SOH_train = mapminmax('reverse',target,ps2);
figure(1)
plot(t_t,'-*r')    % original
hold on
plot(SOH_train,'-b')  % predicted
% legend('original data','Predicted')
% xlabel('Cycle of Li battery');
% ylabel('Battery health state SOH');

%% Test data 
[input2,pt2] = mapminmax(p_t2);% Test_data--In_all(:,91:end);
[target2,tt2] = mapminmax(t_t2); % Out_soc(:,91:end);
output_test = net(input2); % Test
% prediction2 = mapminmax('reverse',output2,ps2);
SOH_test = mapminmax('reverse',output_test,tt2);
% mapminmax按行逐行地对数据进行标准化处理，将每一行数据分别标准化到区间[ymin,ymax]内;
% 'reverse',预处理之后的数据进行反转得到原始数据。

t=[91:168];
% figure
hold on
plot(t,t_t2,'-*r')    % original
hold on
plot(t,SOH_test,'-b')  % predicted
legend('Original data','Predicted')
xlabel('Cycle of Li battery');
ylabel('Battery health state SOH');

%% Test All_cycle
[input_all,I_all]=mapminmax(In_all); % train_data
[targeta_all,S_all]=mapminmax(S); 
output_all = net(input_all); % Test
prediction_all = mapminmax('reverse',output_all,S_all);
SOH_all = prediction_all;

figure,
plot(S,'*r')
hold on
plot(SOH_all,'-b')
legend('Original data','Predicted')
xlabel('Cycle of Li battery');
ylabel('Battery health state SOH');

%% 误差计算 test data

% root-mean-square error (RMSE)
figure
rmse = sqrt(mean((SOH_test - t_t2).^2))*100
rmse_all = sqrt(mean((SOH_all - S).^2))
histogram(SOH_test - t_t2)
title("RMSE = " + rmse)
ylabel("Frequency")
xlabel("Error")

figure
plot((SOH_test - t_t2)*100,'LineWidth',1.5,'LineStyle','-'); 
%legend("Error curve")
xlim([1,length(SOH_test - t_t2)])
ylabel("Prediction Error(%)")
xlabel('Cycle')
title("Error curve")  
%Visualize some of the predictions in a plot.
% idx = randperm(numel(YPred),4);
% figure
% for i = 1:numel(idx)
%     subplot(2,2,i)
%     
%     plot(YTest{idx(i)},'--')
%     hold on
%     plot(YPred{idx(i)},'.-')
%     hold off
%     
%     ylim([0 thr + 25])
%     title("Test Observation " + idx(i))
%     xlabel("Time Step")
%     ylabel("RUL")
% end
% legend(["Test Data" "Predicted"],'Location','southeast')


%%
% numResponses = 1;
% numFeatures = 5; 
% numHiddenUnits = 50;
% Epochs  = 50;
% LearnRateDropPeriod = 1000;
% InitialLearnRate= 0.01;
% LearnRateDropFactor=0.1;
% validationFrequency =10;
% layers = [sequenceInputLayer(numFeatures,"Normalization","zerocenter")
%     fullyConnectedLayer(numHiddenUnits)
%     tanhLayer                            % Hyperbolic Tangent
%     fullyConnectedLayer(numHiddenUnits)
%     leakyReluLayer(0.3)                  % The leaky rectified linear unit (ReLU) activation operation performs a nonlinear threshold operation, where any input value less than zero is multiplied by a fixed scale factor
%     fullyConnectedLayer(numResponses)
%     clippedReluLayer(1)                  % A clipped ReLU layer performs a threshold operation, where any input value less than zero is set to zero and any value above the clipping ceiling, this case '1', is set to that clipping ceiling.
%     regressionLayer];
% 
% options = trainingOptions('adam', ...                    % Adam optimizer
%     'MaxEpochs',Epochs,'ExecutionEnvironment','cpu', ...% Select GPU if you works on computer with GPU
%     'GradientThreshold',1, ...
%     'InitialLearnRate',InitialLearnRate, ...
%     'LearnRateSchedule','piecewise', ...
%     'LearnRateDropPeriod',LearnRateDropPeriod, ...
%     'LearnRateDropFactor',LearnRateDropFactor, ...
%     'L2Regularization',1);
% %     'ValidationData', {X,Y}, ...
% %     'Shuffle','never',...
% %     "Verbose",1,...
% %     'ValidationFrequency',validationFrequency, ...
% %     'MiniBatchSize',miniBatchSize, ...
% %     'Plots','training-progress');
% net = trainNetwork(In_all,layers,options);   