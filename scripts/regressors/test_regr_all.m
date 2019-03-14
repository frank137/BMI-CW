%% Test function for regressor
clear,clc, close all
addpath(['..',filesep,'KNN-bayes classifiers'])
load monkeydata_training.mat

%start by regressing position 1
[n,k] = size(trial);
[i,t] = size(trial(1,1).spikes);

%%

train_struct = tidy_data_regressor(trial);

[data_formatted] = tidy_spikes_regressor(trial,1:train_times(end_t));
angle = 1;





%% functions
function data_formatted = tidy_handPos(data_to_format)
[n,k] = size(data_to_format);
[i,t] = size(data_to_format(1,1).spikes);

data_formatted = zeros(n*k,2,540);
count = 1;
for a = 1:k
    for t = 1:n % number of trials
        data_formatted(count,:,:) = data_to_format(t,a).handPos(1:2,1:540);
        count = count +1;
    end
end


end

function train_struct = tidy_data_regressor(data_to_format)
[n,k] = size(data_to_format);
[i,t] = size(data_to_format(1,1).spikes);

end_time = 540;
% train out
train_out = struct(1,8);%zeros(n*k,2,end_time);
count = 1;
for a = 1:k
    for t = 1:n % number of trials
        train_out(count,:,:) = data_to_format(t,a).handPos(1:2,1:540);
        count = count +1;
    end
end


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