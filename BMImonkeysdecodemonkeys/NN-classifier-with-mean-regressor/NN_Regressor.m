clc,clear
load('monkeydata_training.mat')
[data_formatted, labels] = tidy_spikes(trial);

labels = full(ind2vec(labels'));
data_formatted = data_formatted';
data_formatted3 = cat(3, data_formatted, data_formatted)

%trial(n,k).handPos

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