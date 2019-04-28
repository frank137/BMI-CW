
function [x, y] = positionEstimator(test_data, modelParameters)

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



% ... compute position at the given timestep.

% Return Value:

% - [x, y]:
%     current position of the hand
time = length(test_data.spikes(1,:));
electrode = 1:98;
TEST = [];
% label_tr =zeros(800,1);
% label_test = zeros(800,1);
label_vecTST =[];
label_vec2 = zeros(length(test_data),1);
up_time = 380;
if time < up_time
    ins_time = time;
else
    ins_time = up_time;
end

for i = electrode
    %use this line if wanna get an estimate for each time point
    %      cell_test = test_data.spikes(i,:);
    %use this line if you wanna go with the first estimate and that's it
    cell_test = test_data.spikes(i,1:ins_time);
    processed_test(i) = sum(cell_test);
end
TEST = [TEST;processed_test];

predicted_label = predict(modelParameters.Mdl,TEST);
test_spikes = prepare_regressor_data(test_data,'test');
% Xparams = modelParameters.Xparams;
% Yparams = modelParameters.Yparams;
coeffs = modelParameters.coeffs;
maxmins = modelParameters.extremes;
for movement = 1:8
    if predicted_label == movement
        %mean approximation
        %         x = modelParameters.path(1,time,movement);
        %         y = modelParameters.path(2,time,movement);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %linear regressor
        x_prediction = 0;
        y_prediction = 0;
        min_x = maxmins(1,1,movement);
        max_x = maxmins(1,2,movement);
        min_y = maxmins(2,1,movement);
        params_x = coeffs(:,1,movement);
        params_y = coeffs(:,2,movement);
        max_y = maxmins(2,2,movement);
        %%%%%%%%%%%%%%%%%Linear regression%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        x_prediction = params_x'*[1,test_spikes]';
        y_prediction = params_y'*[1,test_spikes]';
        %%%%%%%%%%%%%%%PCR method%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %x = modelParameters.path(2,ins_time,movement);
        % r = 18;
        % [Urx,Srx,Vrx] = svds([1,test_spikes]',r);
        % x_prediction = params_x'*Urx*Srx*Vrx';
        %
        % [Ury,Sry,Vry] = svds([1,test_spikes]',r);
        % y_prediction = params_y'*Ury*Sry*Vry';
        
        if x_prediction > max_x
            x_prediction = max_x;
        end
        if y_prediction > max_y
            y_prediction = max_y;
        end
        if x_prediction < min_x
            x_prediction = min_x;
        end
        if y_prediction < min_y
            y_prediction = min_y;
        end
        
        x = x_prediction;
        y = y_prediction;
        
    end
end

end

