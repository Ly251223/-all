load('Train_dataset.mat')
%% Prepare Data for Padding
% L_dat = min(numel(capacity),numel(In_all));
% idx = idx(:,1:L_dat);
% 
for i=1:numel(XTrain)
    sequence = XTrain{i};
    sequenceLengths(i) = size(sequence,2);
end

[sequenceLengths,idx] = sort(sequenceLengths,'descend');%idx descend

In_all = XTrain(idx); 
Out_soc = YTrain(idx);
 
% SOC={};
% for i=1:131
%      SOC{i,1}=Out_soc;
% end

% View the sorted sequence lengths in a bar chart.
figure
bar(sequenceLengths)
xlabel("Sequence")
ylabel("Length")
title("Sorted Data")

%% Setup a CNN/LSTM model
% 选择一个小批量大小，它可以均匀地划分训练数据，减少小批量中的填充量
 miniBatchSize = 1;
% % Define Network Architecture
% % Define the network architecture. Create an LSTM network that consists of an LSTM layer with 200 hidden units, followed 
% % by a fully connected layer of size 50 and a dropout layer with dropout probability 0.5.
% 
 numFeatures = size(XTrain{1},1); %3
 numResponses = 1;
 numHiddenUnits = 5;
layers = [ ...
    sequenceInputLayer(numFeatures)
    lstmLayer(numHiddenUnits,'OutputMode','sequence')
    fullyConnectedLayer(10)
    dropoutLayer(0.8)
    fullyConnectedLayer(numResponses)
    regressionLayer];
% 
maxEpochs = 100;

options = trainingOptions('adam', ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchSize, ...
    'InitialLearnRate',1.0e-7, ...
    'LearnRateSchedule','piecewise',...
    'GradientThreshold',1, ...
    'LearnRateDropPeriod',500,...
    'LearnRateDropFactor',0.2,...
    'Shuffle','never', ...
    'Plots','training-progress',...
    'Verbose',0);
net = trainNetwork(In_all,Out_soc,layers,options);