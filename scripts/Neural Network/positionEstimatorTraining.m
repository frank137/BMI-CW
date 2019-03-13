%%% Team Members: Francesco Guagliardo, Luis
%%% Chaves Rodriguez, Daniele Olmeda, Arun Paul
%%% KNN implementation

% RSME is 31.6992
% accuracy is 0.74375
% 20 layers
%trainscg

% RSME is 22.6437
% accuracy is 0.975
% 80 layers
%trainlm

% RSME is 19.785
% accuracy is 0.9875
% 30 layers
%trainbr


function  [modelParameters] = positionEstimatorTraining(trainingData)

[data_formatted, labels] = tidy_spikes(trainingData);

labels = full(ind2vec(labels'));
data_formatted = data_formatted';

% Create a Pattern Recognition Network
net = patternnet(33, 'trainbr');

% Choose Input and Output Pre/Post-Processing Functions
net.input.processFcns = {'removeconstantrows','mapminmax'};

% Setup Division of Data for Training, Validation, Testing
%net.divideFcn = 'dividerand';  % Divide data randomly
net.divideMode = 'sample';  % Divide up every sample
net.divideParam.trainRatio = 80/100;
net.divideParam.valRatio = 20/100;
net.divideParam.testRatio = 0/100;

% Choose a Performance Function
net.performFcn = 'mae';

% Train the Network
[net,tr] = train(net, data_formatted,labels);

% Return Value:
modelParameters.net = net;
mean_vals = regressor(trainingData);
modelParameters.mean_vals = mean_vals;

end

% format the data in a way
function [data_formatted, labels] = tidy_spikes(data_to_format)
[n,k] = size(data_to_format);
[i,t] = size(data_to_format(1,1).spikes);

% output in train_trials trials x 98
data_formatted = zeros(n*k,i);
labels = zeros(n*k,1);

count = 1;
for a = 1:k
    for t = 1:n % number of trials
        for el = 1:i
            data_formatted(count,el) = red_dim(data_to_format(t,a).spikes(el,:));
        end
        labels(count,1) = a;
        count = count +1;
    end
end

end

% function to agglomerate the data
function reduced_dimension_data = red_dim(data_in)

reduced_dimension_data = sum(data_in);

end

function coeff =  regressor(trainingData)

[n,k] = size(trainingData);
tim = 1000;
for a = 1:k
    temp = zeros(2,tim);
    for t = 1:n
        size_time = size(trainingData(t,a).handPos,2);
        temp = temp+[trainingData(t,a).handPos(1:2,:),zeros(2,tim-size_time)];
    end
    coeff(a).mean_pos = temp./n;
end

end