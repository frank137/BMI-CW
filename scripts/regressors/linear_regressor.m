 %% Test function for regressor
clear, close all
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

%% train linear regressor

movement = 7;
x_position = data_formatted_train(movement).out(:,1);
y_position = data_formatted_train(movement).out(:,2);
max_x = max(x_position);
max_y = max(y_position);
min_x = min(x_position);
min_y = min(y_position);
length_data_in = length(data_formatted_train(1).in);
processed_electrodes = [ones(length_data_in,1),data_formatted_train(movement).in];
params_x = regress(x_position,processed_electrodes);
params_y = regress(y_position,processed_electrodes);
% params_x = mvregress(processed_electrodes,x_position);
% params_y = mvregress(processed_electrodes,y_position);


%% test linear regressor
test_inputt = prepare_regressor_data(testData,'train');
test_input = test_inputt(movement).in;
test_output_real = test_inputt(movement).out;
length_place = size(test_input,1);
x_prediction = zeros(length_place,1);
y_prediction = zeros(length_place,1);
 for a = 1:size(test_input,1)
    x_prediction(a) = params_x'*[1,test_input(a,:)]';
    y_prediction(a) = params_y'*[1,test_input(a,:)]';
    if x_prediction(a) > max_x
        x_prediction(a) = max_x;
    end
    if y_prediction(a) > max_y
        y_prediction(a) = max_y;
    end
    if x_prediction(a) < min_x
        x_prediction(a) = min_x;
    end
    if y_prediction(a) < min_y
        y_prediction(a) = min_y;
    end
 end

prediction = [x_prediction,y_prediction];

%%
plot(x_prediction,y_prediction,'ko')
hold on
plot(test_output_real(:,1),test_output_real(:,2),'b+')
legend('Predicted data', 'Real data')
ylabel('y'); xlabel('x')
title(['Linear regression performance for movement ',num2str(movement)])
grid on
RMSE = sqrt(mean((prediction-test_output_real).^2))

