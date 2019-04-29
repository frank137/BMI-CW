function [modelParameters] = positionEstimatorTraining(training_data)
% Arguments:

% - training_data:
%     training_data(n,k)              (n = trial id,  k = reaching angle)
%     training_data(n,k).trialId      unique number of the trial
%     training_data(n,k).spikes(i,t)  (i = neuron id, t = time)
%     training_data(n,k).handPos(d,t) (d = dimension [1-3], t = time)

% ... train your model

% Return Value:

% - modelParameters:
%     single structure containing all the learned parameters of your
%     model and which can be used by the "positionEstimator" function.
electrode = 1:98;
endtime = 380;
TR = [];
TEST = [];
% label_tr =zeros(800,1);
% label_test = zeros(800,1);
label_vecTR =[];
label_vec1 = zeros(length(training_data),1);
meanpath = zeros(2,1000,8);
%prepare training data for regressor
data_formatted_train = prepare_regressor_data(training_data,'train');
%for every movement
for movement = 1:8
    %for all the trials of the training data
    for trial = 1:length(training_data)
        % for all electrodes (98)
        for i = electrode 
            %for one electrode for one trial for one movement
            %take spikes up to specified endtime
            cell_tr = training_data(trial,movement).spikes(i,1:endtime);
            %process it: basically add all the spikes in this time space,
            %this will give you one value for each electrode for each trial
            %for each movement
            processed_training(trial,i) = sum(cell_tr);
            %collect the movement for later on training a model
            label_vec1(trial) = movement;      
        end
        %collect the hand position (trajectory) for this trial
        handpos = training_data(trial,movement).handPos(1:2,:);
        %pad it so that it reaches a length of 1000
        zeropad = 1000-length(handpos);
        % add the mean path to the specific movement, later on this will be
        % averaged over the number of trials
        meanpath(:,:,movement) =  meanpath(:,:,movement)+[handpos,zeros(2,zeropad)];
    end
    %store sum of spikes in training vector, this will store
    %trial*electrode number of values for each movement
    TR = [TR;processed_training];
    %store labels of training vector
    label_vecTR = [label_vecTR;label_vec1];
    
    %REGRESSION
    
    %get x positin from processed training data
x_position = data_formatted_train(movement).out(:,1);
%get y position from processed training data
y_position = data_formatted_train(movement).out(:,2);
% get max and mins for x and y in order to later bound estimations
max_x = max(x_position);
max_y = max(y_position);
min_x = min(x_position);
min_y = min(y_position);
maxs_mins(:,:,movement) = [ min_x max_x;min_y max_y];
% get length of data
length_data_in = length(data_formatted_train(1).in);
%get processed spike data and concatenate to a colum of ones to prepare it
%for the regress function
processed_electrodes = [ones(length_data_in,1),data_formatted_train(movement).in];
%calculate parameters for x and y for this movement
% LINEAR REGRESSION
params_x = LuisLinearRegressor(x_position,processed_electrodes,0);
params_y = LuisLinearRegressor(y_position,processed_electrodes,0);
%store coefficient for this movement
% Params_x(:,movement) = params_x;
% Params_y(:,movement) = params_y;
 coeffs(:,:,movement) = [params_x,params_y];
    
end
% normalise meanpath by number of trials aka calculate actual mean
meanpath = meanpath./length(training_data);

%train model
Mdl = fitcecoc(TR,label_vecTR,'Learners','svm');

%store model as one of the model parameters
modelParameters.Mdl = Mdl;
%store mean path as nother one
modelParameters.path = meanpath;
%store linear regressor coefficients
modelParameters.coeffs = coeffs;
% modelParameters.Xparams = Params_x;
% modelParameters.Yparams = Params_y;
%store max and mins for each movement
modelParameters.extremes = maxs_mins;

end
