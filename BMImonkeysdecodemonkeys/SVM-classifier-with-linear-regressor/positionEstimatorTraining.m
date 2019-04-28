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
            cell_tr = training_data(trial,movement).spikes(i,1:380);
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

function b = LuisLinearRegressor(y,X,option)
% this linear regressor takes as an input your feature space, concated to a
% vector of ones as the constant term which will give the bias or
% "y-intercept"
% we consider y and X given as column vector where time is in the rows

if option == 0
    b = inv(X'*X)*X'*y;
else
    r = 18;
    [Ur,Sr,Vr] = svds(X,r);
    b = Vr/Sr*Ur'*y;
end
end

function data_out = prepare_regressor_data(data_to_format, train_or_test)
% train_or_test = 'train' prepares training data, train_or_test = 'test'
% prepares test data
[n,k] = size(data_to_format);
[i,t] = size(data_to_format(1,1).spikes);

%dimensions = [3,4,7,18,27,31,33,34,36,41,55,68,69,75,81,90,92,98];
%[3,4,7,18,27,31,33,34,36,41,55,68,69,75,81,90,92,98];
%[3,4,18,34,36,96];%1:i; %electrodes used, some are useless so we shouldn't use them
start_time = 320; %ms
end_time = 540; %ms
step_time = 20; %ms
times = start_time:step_time:end_time;
dim_reducer = 3;%14; % final dimensions will be initial dimensions / dim_reducer
if strcmp(train_or_test,'train')
    % .in(20,30) contains the sum of the spikes up to time 320ms of
    % electrode number 30 from trial 20. .in(120,30) contains the sum of
    % the spikes up to time 340ms (if step_time = 20) electrode 30 for trial 20
    % .out(20,:) contains the x and y position for trial 20 at time stamp
    % 320ms, .out(120,:) contains the x and y for trial 20 at time stamp
    % 340 ms and so on.
    for a = 1:k
        data_formatted(a).in = zeros(n*length(times),length(dimensions)); %cumulative sums
        %data_formatted(a).out = zeros(length(times),2); %x,y
        %data_out(a).in = zeros(n*length(times),reduced_dimensions);
        data_out(a).out = zeros(length(times),2); %x,y
        count = 1;
        for tim = times
            for t = 1:n % number of trials
                data_out(a).out(count,:) = data_to_format(t,a).handPos(1:2,tim);
                for el = dimensions
                    data_formatted(a).in(count,el==dimensions) = sum(data_to_format(t,a).spikes(el,1:tim));
                end
                count = count +1;
            end
        end
        % reduce data
        data_out(a).in = reduce_feat_dim(data_formatted(a).in,dim_reducer);%data_formatted(a).in;%
        %[data_out(a).in, coeff_pca] = reduce_feat_dim(data_formatted(a).in, 8);
        %data_out(a).coeff_pca=coeff_pca;
        data_out(a).coeff_pca=0;
    end
elseif strcmp(train_or_test,'test')
    data_formatted = zeros(1,length(dimensions));
    for el = dimensions
        data_formatted(el==dimensions) = sum(data_to_format.spikes(el,:));
    end
    % reduce data
    data_out = reduce_feat_dim(data_formatted,dim_reducer);%data_formatted;%reduce_feat_dim(data_formatted,0.65);
    %data_out = data_formatted;
else
    warning('Insert either train or test')
end
end

function reduced_features = reduce_feat_dim(features,sum_int)
%features is a obervations x dimensions vector and the dimensions are
%reduced by summing over dimensions sum_int by sum_int
new_dim = size(features,2)/sum_int;
reduced_features = zeros(size(features,1),new_dim);
start_idx = 1;
for i = 1:new_dim
    reduced_features(:,i)= sum(features(:,start_idx:start_idx+sum_int-1),2);
    start_idx = start_idx+sum_int;
end

end

% function [reduced_features, best_coeff] = reduce_feat_dim(features, M_pca)
% % examples:
% %features = reduce_feat_dim(features,0.99); does PCA with 99% variance kept.
%
% [coeff,score,latent,tsquared,explained,mu] = pca(features);
% sum_eig = sum(explained(1:M_pca))
% %perc_accepted = 0.95; % 144
%
%
% best_coeff = coeff(:,1:M_pca);
% reduced_features = score(:,1:M_pca);
%
% end

