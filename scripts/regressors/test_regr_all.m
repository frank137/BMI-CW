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
%training data formatted will come in the form of sums of spikes for
%different electrodes (or combinations of them) and for all trials - see
%function comments for more info
data_formatted_train = prepare_regressor_data(trainingData,'train');

%data_formatted_test = prepare_train_data(testData);

%% train regressor
figure
for a = 1:k
pause(0.001)
W = 2;
param = train_regrssor_bmi(data_formatted_train(a).in, data_formatted_train(a).out, W, W);

%% test regressor
%give as input like in competion 
% time_to = 540;
% test_prep.spikes = testData(1,a).spikes(:,1:time_to);
% test_input = prepare_regressor_data(test_prep,'test');
% test_output_real = testData(1,a).handPos(1:2,time_to);
% test_output_real = test_output_real';

% test all
test_inputt = prepare_regressor_data(testData,'train');
test_input = test_inputt(a).in;
test_output_real = test_inputt(a).out;

prediction = test_regressor_bmi(test_input, param);

%% scores

RMSE(:,:,a) = sqrt(mean((prediction-test_output_real).^2));
plot(prediction(:,1),prediction(:,2))
hold on
plot(test_output_real(:,1),test_output_real(:,2))
end
title 'Regressor vs true position';
legend('Predicted with regressor','true')
mean(mean(RMSE))

%% functions
% function data_formatted = prepare_regressor_data(data_to_format, train_or_test)
% % train_or_test = 'train' prepares training data, train_or_test = 'test'
% % prepares test data
% [n,k] = size(data_to_format);
% [i,t] = size(data_to_format(1,1).spikes);
% 
% dimensions = [3,4,18,34,36];%1:i; %electrodes used, some are useless so we shouldn't use them
% end_time = 540; %ms
% start_time = 320; %ms
% step_time = 20; %ms
% times = start_time:step_time:end_time;
% 
% if strcmp(train_or_test,'train')
%     % .in(20,30) contains the sum of the spikes up to time 320ms of
%     % electrode number 30 from trial 20. .in(120,30) contains the sum of
%     % the spikes up to time 340ms (if step_time = 20) electrode 30 for trial 20
%     % .out(20,:) contains the x and y position for trial 20 at time stamp
%     % 320ms, .out(120,:) contains the x and y for trial 20 at time stamp
%     % 340 ms and so on.
%     for a = 1:k
%         data_formatted(a).in = zeros(n*length(times),length(dimensions)); %cumulative sums
%         data_formatted(a).out = zeros(length(times),2); %x,y
%         count = 1;
%         for tim = times
%             for t = 1:n % number of trials
%                 data_formatted(a).out(count,:) = data_to_format(t,a).handPos(1:2,tim);
%                 for el = dimensions
%                     data_formatted(a).in(count,el==dimensions) = sum(data_to_format(t,a).spikes(el,1:tim));
%                 end
%                 count = count +1;
%             end
%         end
%     end
%     
% elseif strcmp(train_or_test,'test')
%     data_formatted = zeros(1,length(dimensions));
%     for el = dimensions
%         data_formatted(el==dimensions) = sum(data_to_format.spikes(el,1:400));
%     end
% else
%     warning('Insert either train or test')
% end
% end
