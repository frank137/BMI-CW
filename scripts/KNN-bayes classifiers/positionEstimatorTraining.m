%%% Team Members: Francesco Guagliardo, Luis
%%% Chaves Rodriguez, Daniele Olmeda, Arun Paul
%%% KNN implementation
function  [modelParameters] = positionEstimatorTraining(trainingData)

% Arguments:

% - training_data:
%     training_data(n,k)              (n = trial id,  k = reaching angle)
%     training_data(n,k).trialId      unique number of the trial
%     training_data(n,k).spikes(i,t)  (i = neuron id, t = time)
%     training_data(n,k).handPos(d,t) (d = dimension [1-3], t = time)

%
%time_range = 1:360;%280:480;
%[data_formatted, labels] = tidy_spikes(trainingData,time_range);
[n,k] = size(trainingData);
[i,t] = size(trainingData(1,1).spikes);

train_times = 320:20:400;%540;
data_formatted_per_train_time = zeros(n*k,i,length(train_times));
for end_t = 1:length(train_times)
    [data_formatted, labels] = tidy_spikes(trainingData,1:train_times(end_t));
    data_formatted_per_train_time(:,:,end_t) = data_formatted;    
end

% regressor
data_formatted_train = prepare_regressor_data(trainingData,'train');
W = 2;
for ang = 1:k
regr_param(ang) = train_regrssor_bmi(data_formatted_train(ang).in, data_formatted_train(ang).out, W, 2);
coeff_pca(:,:,ang) = data_formatted_train(ang).coeff_pca;
end

modelParameters.train_in = data_formatted_per_train_time;
modelParameters.labels = labels;
mean_vals = regressor(trainingData);
k_knn = 1;
modelParameters.mean_vals = mean_vals;
modelParameters.k = k_knn;
modelParameters.regr_param = regr_param;
modelParameters.coeff_pca = coeff_pca;
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
