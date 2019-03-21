%%% Team Members: Francesco Guagliardo, Luis
%%% Chaves Rodriguez, Daniele Olmeda, Arun Paul
%%% KNN implementation
function  [modelParameters] = positionEstimatorTraining(trainingData,r)

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
r = 36;
for ang = 1:k
    %get x positin from processed training data
    x_position = data_formatted_train(ang).out(:,1);
    %get y position from processed training data
    y_position = data_formatted_train(ang).out(:,2);
    
    % get length of data
    length_data_in = length(data_formatted_train(1).in);
    %get processed spike data and concatenate to a colum of ones to prepare it
    %for the regress function
    processed_electrodes = [ones(length_data_in,1),data_formatted_train(ang).in];
    
    params_x = train_regressor(x_position,processed_electrodes,r,1);
    params_y = train_regressor(y_position,processed_electrodes,r,1);
    %store coefficient for this movement
    coeffs(:,:,ang) = [params_x,params_y];
    
    % get max and mins for x and y in order to later bound estimations
    max_x = max(x_position);
    max_y = max(y_position);
    min_x = min(x_position);
    min_y = min(y_position);
    maxs_mins(:,:,ang) = [ min_x max_x;min_y max_y];
    
end
modelParameters.train_in = data_formatted_per_train_time;
modelParameters.labels = labels;
k_knn = 1;
modelParameters.k = k_knn;
% regressor
modelParameters.coeffs = coeffs;
modelParameters.extremes = maxs_mins;
modelParameters.new_dim = r;
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

function b = train_regressor(y,X,r,option)
% this linear regressor takes as an input your feature space, concated to a
% vector of ones as the constant term which will give the bias or
% "y-intercept"
% we consider y and X given as column vector where time is in the rows

if option == 0
    b = inv(X'*X)*X'*y;
else
    [Ur,Sr,Vr] = svds(X,r);
    b = Vr/Sr*Ur'*y;
end
end
