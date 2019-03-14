%% Test function for regressor
clear,clc, close all
addpath(['..',filesep,'KNN-bayes classifiers'])
load monkeydata_training.mat

%start by regressing position 1
[n,k] = size(trial);
[i,t] = size(trial(1,1).spikes);

rng(2013);
ix = randperm(length(trial));
trainingData = trial(ix(1:80),:);
testData = trial(ix(81:end),:);

%% tidy data up
clear data_formatted
data_formatted = prepare_train_data(trainingData);

%% train regressor
W = 2;
param = train_regrssor_bmi(data_formatted(1).train_in, data_formatted(1).train_out, W, W);

%% test regressor 
prediction = 0;


%% functions
function data_formatted = prepare_train_data(data_to_format)
[n,k] = size(data_to_format);
[i,t] = size(data_to_format(1,1).spikes);

dimensions = 1:i; %electrodes used, some are useless so we shouldn't use them
end_time = 540; %ms
start_time = 320; %ms
step_time = 20; %ms
times = start_time:step_time:end_time;

% train_in(20,30) contains the sum of the spikes up to time 320ms of 
% electrode number 30 from trial 20. train_in(120,30) contains the sum of
% the spikes up to time 340ms (if step_time = 20) electrode 30 for trial 20
% train_out(20,:) contains the x and y position for trial 20 at time stamp
% 320ms, train_out(120,:) contains the x and y for trial 20 at time stamp
% 340 ms and so on.
for a = 1:k
    data_formatted(a).train_in = zeros(n*length(times),length(dimensions)); %cumulative sums
    data_formatted(a).train_out = zeros(length(times),2); %x,y
    count = 1;
    for tim = times
        for t = 1:n % number of trials
            data_formatted(a).train_out(count,:) = data_to_format(t,a).handPos(1:2,tim);
            for el = dimensions
                data_formatted(a).train_in(count,el) = sum(data_to_format(t,a).spikes(el,1:tim));
            end
            count = count +1;
        end
    end
end


end

