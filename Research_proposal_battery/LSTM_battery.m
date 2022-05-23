% openExample('nnet/PredictBatterySOCUsingDeepLearningExample')

%%
close all;
clear,clc

filename = 'B0018';
load(filename)
cycles1 = B0018.cycle; % 保存步骤数组到新变量

counter = 0;
counter1 = 0;
In_all = {};
In_dis  = {};
for i = 1:length(cycles1)-1 % search through the array of step structures
    if strcmp(cycles1(i).type,'charge') % charge
        counter1 = counter1+1;
        da = cycles1(i).data; % V,I,Temp,Current_charge,Volatge_charge
        %         Vin(counter1) = mean(da.Voltage_measured);
        %         Iin(counter1) = mean(da.Current_measured);
        Charge_in = [da.Voltage_measured;da.Current_measured;da.Temperature_measured];
        In_all{i} = Charge_in;
    end
    In_all(cellfun(@isempty,In_all))=[];

    %     if strcmp(cycles1(i).type,'discharge') % discharge
    %         counter = counter+1;
    %         Tc(counter)=counter-1; % start from 0
    %         da = cycles1(i).data;%
    %         capacity1(counter) = da.Capacity;
    %         discharge_out = [da.Voltage_measured;da.Current_measured;da.Temperature_measured];
    %         In_dis{i} = discharge_out;
    %         % V,I,Temp,current_load,Volatge_load,Time,Capacity
    %         %         Vout(counter) = mean(da.Voltage_measured);
    %         %         Iout(counter) = mean(da.Current_measured);
    %         %         T(counter) = mean(da.Temperature_measured);
    %     end
    %     In_dis(cellfun(@isempty,In_dis))=[];

    if strcmp(cycles1(i).type,'discharge') % discharge
        counter = counter+1;
        Tc(counter)=counter-1; % start from 0
        da = cycles1(i).data;%
        capacity1(counter) = da.Capacity;
    end

end
In_all = In_all';
% In_dis = In_dis';
capacity = capacity1';

% m = min([In_all{:}],[],2);
% M = max([In_all{:}],[],2);
% idxConstant = M == m;
% for i = 1:numel(In_all)
%     In_all{i}(idxConstant,:) = [];
% end
% numFeatures = size(In_all{1},1);
figure,
stackedplot([In_all{2,1}]') 

%% Normalize Training Predictors
% size([In_all{:}])=3*279810;
mu = nanmean([In_all{:}],2);%
sig = nanstd([In_all{:}],0,2);

for i = 1:numel(In_all)
    In_all{i} = (In_all{i} - mu) ./ sig;
end
%% Clip Responses

%% Prepare Data for Padding
L_dat = min(numel(capacity),numel(In_all));
% idx = idx(:,1:L_dat);
% 
% for i=1:numel(In_all)
for i=1:L_dat
    sequence = In_all{i};
    sequenceLengths(i) = size(sequence,2);
end

[sequenceLengths,idx] = sort(sequenceLengths,'descend');%idx descend

XTrain = In_all(idx); 
YTrain = capacity(idx);
 
SOC={};
for i=1:131
     SOC{i,1}=YTrain';
end

% View the sorted sequence lengths in a bar chart.
figure
bar(sequenceLengths)
xlabel("Sequence")
ylabel("Length")
title("Sorted Data")

%%  FNN
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
%     'L2Regularization',1, ...
%      'ValidationData', {X,Y}, ...
%     'Shuffle','never',...
%     "Verbose",1,...
%     'ValidationFrequency',validationFrequency, ...
%     'MiniBatchSize',miniBatchSize, ...
%     'Plots','training-progress'); 

% %% Setup a CNN model
% % 选择一个小批量大小，它可以均匀地划分训练数据，减少小批量中的填充量
%  miniBatchSize = 20;
% % % Define Network Architecture
% % % Define the network architecture. Create an LSTM network that consists of an LSTM layer with 200 hidden units, followed 
% % % by a fully connected layer of size 50 and a dropout layer with dropout probability 0.5.
% % 
%  numFeatures = size(XTrain{1},1); %3
%  numResponses = 1;
%  numHiddenUnits = 20;
% layers = [ ...
%     sequenceInputLayer(numFeatures)
%     lstmLayer(numHiddenUnits,'OutputMode','sequence')
%     fullyConnectedLayer(50)
%     dropoutLayer(0.5)
%     fullyConnectedLayer(numResponses)
%     regressionLayer];
% % 
% maxEpochs = 30;
% miniBatchSize = 20;
% options = trainingOptions('adam', ...
%     'MaxEpochs',250, ...
%     'MiniBatchSize',miniBatchSize, ...
%     'InitialLearnRate',0.01, ...
%     'LearnRateSchedule','piecewise',...
%     'GradientThreshold',1, ...
%     'LearnRateDropPeriod',125,...
%     'LearnRateDropFactor',0.2,...
%     'Shuffle','never', ...
%     'Plots','training-progress',...
%     'Verbose',0);
% net = trainNetwork(XTrain,SOC,layers,options);
%% CNN 
% numFeatures = 3;
% numHiddenUnits = 100;
% numResponses = 1;
% 
% layers = [
%     sequenceInputLayer(numFeatures)
%     convolution1dLayer(5,32,Padding="causal")
%     batchNormalizationLayer()
%     reluLayer()
%     convolution1dLayer(7,64,Padding="causal")
%     batchNormalizationLayer
%     reluLayer()
%     convolution1dLayer(11,128,Padding="causal")
%     batchNormalizationLayer
%     reluLayer()
%     convolution1dLayer(13,256,Padding="causal")
%     batchNormalizationLayer
%     reluLayer()
%     convolution1dLayer(15,512,Padding="causal")
%     batchNormalizationLayer
%     reluLayer()
%     fullyConnectedLayer(numHiddenUnits)
%     reluLayer()
%     dropoutLayer(0.5)
%     fullyConnectedLayer(numResponses)
%     regressionLayer()];
% %% Options
% maxEpochs = 30;
% miniBatchSize = 20;
% % 
% options = trainingOptions('adam',...
%     LearnRateSchedule='piecewise',...
%     MaxEpochs=maxEpochs,...
%     MiniBatchSize=miniBatchSize,...
%     InitialLearnRate=0.01,...
%     GradientThreshold=1,...
%     Shuffle='never',...
%     Plots='training-progress',...
%     Verbose=0);
% 
% %% Train CNN model   已经知道前100个点预测后30个
% net = trainNetwork(XTrain,SOC,layers,options);
% 
% % Plot the layer graph of the network to visualize the underlying network architecture.
% figure;
% lgraph = layerGraph(net.Layers);
% plot(lgraph)