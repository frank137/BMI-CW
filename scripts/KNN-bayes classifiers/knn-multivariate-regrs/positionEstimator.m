%%% Team Members: Francesco Guagliardo, Luis
%%% Chaves Rodriguez, Daniele Olmeda, Arun Paul
%%% KNN
function [x, y, new_param] = positionEstimator(test_data, modelParameters)

% **********************************************************
%
% You can also use the following function header to keep your state
% from the last iteration
%
% function [x, y, newModelParameters] = positionEstimator(test_data, modelParameters)
%                 ^^^^^^^^^^^^^^^^^^
% Please note that this is optional. You can still use the old function
% declaration without returning new model parameters.
%
% *********************************************************

% - test_data:
%     test_data(m).trialID
%         unique trial ID
%     test_data(m).startHandPos
%         2x1 vector giving the [x y] position of the hand at the start
%         of the trial
%     test_data(m).decodedHandPos
%         [2xN] vector giving the hand position estimated by your
%         algorithm during the previous iterations. In this case, N is
%         the number of times your function has been called previously on
%         the same data sequence.
%     test_data(m).spikes(i,t) (m = trial id, i = neuron id, t = time)
%     in this case, t goes from 1 to the current time in steps of 20
%     Example:
%         Iteration 1 (t = 320):
%             test_data.trialID = 1;
%             test_data.startHandPos = [0; 0]
%             test_data.decodedHandPos = []
%             test_data.spikes = 98x320 matrix of spiking activity
%         Iteration 2 (t = 340):
%             test_data.trialID = 1;
%             test_data.startHandPos = [0; 0]
%             test_data.decodedHandPos = [2.3; 1.5]
%             test_data.spikes = 98x340 matrix of spiking activity

[i,t] = size(test_data(1,1).spikes);
input_len = size(test_data,1);

input_time = size(test_data.spikes,2);
% up_to = 360;
% if input_time < up_to
%     time_range = 1:input_time;%280:480;
% else
%     time_range = 1:up_to;%280:480;
% end
train_times = 320:20:400;
up_to = find(train_times==input_time);
if isempty(up_to)
    up_to = length(train_times);
end


%[test_data_formatted, ~] = tidy_spikes(test_data,time_range);
[test_data_formatted, ~] = tidy_spikes(test_data,1:train_times(up_to));
label = zeros(size(test_data,1),1);

K = modelParameters.k;
%all_dist = pdist2(test_data_formatted, modelParameters.train_in(:,:,up_to),'cityblock');
all_dist = sum(abs(test_data_formatted-modelParameters.train_in(:,:,up_to)),2)';
[~, prev_idxs] = sort(all_dist,2);
%numm_test x K array. Each row contains the indeces of the K shortest
%distances
K_prev_idxs = prev_idxs(:,1:K);
% find out to what training class these indeces belogs to and do a
% majority vote
% rows contain class of K closest training points to the test point
K_training_classes = modelParameters.labels(K_prev_idxs);

for i = 1:input_len
    [class_unique, ~, counts_arr] = unique(K_training_classes(i,:));
    class_counts = hist(counts_arr,length(class_unique));
    [~, pred_class_idx] = max(class_counts);
    
    label(i,1) = class_unique(pred_class_idx);
end

% regressor
test_input = prepare_regressor_data(test_data,'test');
if modelParameters.coeff_pca(label) ~= 0 % this only applies if pca was done
    test_input = test_input*modelParameters.coeff_pca(:,:,label);
end
prediction = test_regressor_bmi(test_input, modelParameters.regr_param(label));

% max min check
maxmins = modelParameters.extremes;
min_x = maxmins(1,1,label);
max_x = maxmins(1,2,label);
min_y = maxmins(2,1,label);
max_y = maxmins(2,2,label);
if prediction(1) > max_x,  prediction(1) = max_x; end
if prediction(2) > max_y,   prediction(2) = max_y; end
if prediction(1) < min_x, prediction(1) = min_x; end
if prediction(2) < min_y,  prediction(2) = min_y; end



x = prediction(1);
y = prediction(2);
%x = modelParameters.mean_vals(label).mean_pos(1,t);
%y = modelParameters.mean_vals(label).mean_pos(2,t);
modelParameters.test_label = label;
new_param = modelParameters;
end

% format the data in a way
function [data_formatted, labels] = tidy_spikes(data_to_format,range)
[n,k] = size(data_to_format);
[i,t] = size(data_to_format(1,1).spikes);

% output in train_trials trials x 98
data_formatted = zeros(n*k,i);
labels = zeros(n*k,1);

count = 1;
for a = 1:k
    for t = 1:n % number of trials
        for el = 1:i
            data_formatted(count,el) = red_dim(data_to_format(t,a).spikes(el,range));
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


