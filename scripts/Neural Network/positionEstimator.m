%%% Team Members: Francesco Guagliardo, Luis
%%% Chaves Rodriguez, Daniele Olmeda, Arun Paul
%%% NN
function [x, y, newModelParameters] = positionEstimator(test_data, modelParameters)

[i,t] = size(test_data(1,1).spikes);
newModelParameters = modelParameters;

[test_data_formatted, ~] = tidy_spikes(test_data);
test_data_formatted = test_data_formatted';
newModelParameters.label = vec2ind(modelParameters.net(test_data_formatted));

label = newModelParameters.label;
x = modelParameters.mean_vals(label).mean_pos(1,t);
y = modelParameters.mean_vals(label).mean_pos(2,t);
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
