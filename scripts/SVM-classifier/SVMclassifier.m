clear all
close all

load monkeydata_training.mat

% Set random number generator
rng(2013);
ix = randperm(length(trial));

%addpath(teamName);

% Select training and testing data (you can choose to split your data in a different way if you wish)
trainingData = trial(ix(1:80),:);
testData = trial(ix(81:end),:);



% figure
% hold on
% axis square
% grid

for endtime = 320:20:560
    fprintf('Testing the continuous position estimator...')

meanSqError = 0;
n_predictions = 0;  
% Train Model
modelParameters = positionEstimatorTraining(trainingData,endtime);
count =1;
%for the 50 trials
for tr=1:size(testData,1)
    display(['Decoding block ',num2str(tr),' out of ',num2str(size(testData,1))]);
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
%                 modelParameters = newParameters;
            elseif nargout('positionEstimator') == 2
                [decodedPosX, decodedPosY] = positionEstimator(past_current_trial, modelParameters);
            end
            
            decodedPos = [decodedPosX; decodedPosY];
            decodedHandPos = [decodedHandPos decodedPos];
            
            meanSqError = meanSqError + norm(testData(tr,direc).handPos(1:2,t) - decodedPos)^2;
            
        end
        n_predictions = n_predictions+length(times);
%          hold on
%          plot(decodedHandPos(1,:),decodedHandPos(2,:), 'ro');
%         plot(testData(tr,direc).handPos(1,times),testData(tr,direc).handPos(2,times),'b')

  % create confusion matrix
        trueMov(count) = direc;
        predMov(count) = newParameters;
        count = count + 1;
    end
end

%legend('Decoded Position', 'Actual Position')

RMSE(endtime) = sqrt(meanSqError/n_predictions); 

% confMat = confusionmat(trueMov,predMov);
% 
% figure
% heatmap(confMat)
% ylabel('True class')
% xlabel('Predicted class')

correct = 0;
for a = 1:length(trueMov)
    if trueMov(a) == predMov(a)
        correct = correct+1;
    end
end

accuracy(endtime) = correct/length(trueMov);

end
%rmpath(genpath(teamName))
%% 
RMSE = nonzeros(RMSE);
ACC = nonzeros(accuracy);
yyaxis left
plot(320:20:560,RMSE,'b')
ylabel('RMSE')
yyaxis right
plot(320:20:560,ACC,'r')
ylabel('Accuracy')
xlabel('End time of training data')
title('Effect on end time of training data on accuracy and RMSE')
grid on
legend('RMSE','Accuracy')
