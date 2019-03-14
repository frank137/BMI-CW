% Test Script to give to the students, March 2015
%% Continuous Position Estimator Test Script
% This function first calls the function "positionEstimatorTraining" to get
% the relevant modelParameters, and then calls the function
% "positionEstimator" to decode the trajectory.

%function RMSE = testFunction_for_students_MTb(teamName)
clear, close all
load monkeydata_training.mat

% Set random number generator
rng(2013);
ix = randperm(length(trial));

%addpath(teamName);

% Select training and testing data (you can choose to split your data in a different way if you wish)
trainingData = trial(ix(1:80),:);
testData = trial(ix(81:end),:);

fprintf('Testing the continuous position estimator...')

meanSqError = 0;
n_predictions = 0;

figure
hold on
axis square
grid
% NNmodels = {'trainlm';'trainbr';'trainbfg';'traincgb';'traincgf';'traincgp';...
%     'traingd';'traingda';'traingdm';'traingdx';'trainoss';'trainrp';...
%     'trainscg';'trainb';'trainc';'trainr';'trains'};
%for i = 1:length(NNmodels)
% Train Model
tic
%     meanSqError = 0;
%     n_predictions = 0;
modelParameters = positionEstimatorTraining(trainingData); %positionEstimatorTraining(trainingData, NNmodels{i})
count = 1;
for tr=1:size(testData,1)
    %     display(['Decoding block ',num2str(tr),' out of ',num2str(size(testData,1))]);
    pause(0.001)
    for direc=1:8%randperm(8)
        decodedHandPos = [];
        
        times=320:20:size(testData(tr,direc).spikes,2);
        
        for t=times
            past_current_trial.trialId = testData(tr,direc).trialId;
            past_current_trial.spikes = testData(tr,direc).spikes(:,1:t);
            past_current_trial.decodedHandPos = decodedHandPos;
            
            past_current_trial.startHandPos = testData(tr,direc).handPos(1:2,1);
            
            if nargout('positionEstimator') == 3
                [decodedPosX, decodedPosY, newParameters] = positionEstimator(past_current_trial, modelParameters);
                modelParameters = newParameters;
            elseif nargout('positionEstimator') == 2
                [decodedPosX, decodedPosY] = positionEstimator(past_current_trial, modelParameters);
            end
            
            decodedPos = [decodedPosX; decodedPosY];
            decodedHandPos = [decodedHandPos decodedPos];
            
            meanSqError = meanSqError + norm(testData(tr,direc).handPos(1:2,t) - decodedPos)^2;
            
        end
        n_predictions = n_predictions+length(times);
        hold on
        plot(decodedHandPos(1,:),decodedHandPos(2,:), 'r');
        plot(testData(tr,direc).handPos(1,times),testData(tr,direc).handPos(2,times),'b')
        
        % create confusion matrix
        true_lab(count) = direc;
        NN_lab(count) = newParameters.label;
        count = count + 1;
    end
end

legend('Decoded Position', 'Actual Position')

RMSE = sqrt(meanSqError/n_predictions); %RMSE(i)
display(['RSME is ', num2str(RMSE)]);

%rmpath(genpath(teamName))
%end

conf_mat = confusionmat(true_lab, NN_lab);

figure;
heatmap(conf_mat);
ylabel('True class');
xlabel('Predicted class');

correct = 0;
for a = 1:length(true_lab)
    if true_lab(a) == NN_lab(a)
        correct = correct+1;
    end
end
accuracy = correct/length(true_lab); %accuracy(i)
display(['accuracy is ',num2str(accuracy)]);
time = toc/60
%disp(['for ', NNmodels{i}, ', RSME is ', num2str(RMSE(i)), ', accuracy is ', num2str(accuracy(i)), ' and time is ', num2str(time(i)/60)])
%end

