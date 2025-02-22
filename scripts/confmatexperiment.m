clear all

load monkeydata_training.mat

% Set random number generator
rng(2013);
ix = randperm(length(trial));

%addpath(teamName);

% Select training and testing data (you can choose to split your data in a different way if you wish)
trainingData = trial(ix(1:50),:);
testData = trial(ix(51:end),:);

% endtime = 600;
count =1;
% learners = {'svm','discriminant', 'knn', 'linear','naivebayes', 'tree'};
%     for
times = [320 400 540];%320:20:560;

w_it = 1;
count = 1;
for w = times
fprintf('Testing the continuous position estimator...')

meanSqError = 0;
n_predictions = 0;
% Train fitecoc Model
% modelParameters = positionEstimatorTraining(trainingData,380,"svm");
%train final model made by Francesco
modelParameters = positionEstimatorTraining(trainingData,w);
t_it = 1;
for t = times
    count = 1;
    %for the 50 trials
    for tr=1:size(testData,1)
%         display(['Decoding block ',num2str(tr),' out of ',num2str(size(testData,1))]);
%         pause(0.001)
        for direc=1:8%randperm(8)
            decodedHandPos = [];
            
            past_current_trial.trialId = testData(tr,direc).trialId;
            past_current_trial.spikes = testData(tr,direc).spikes(:,1:t);
            past_current_trial.decodedHandPos = decodedHandPos;
            
            past_current_trial.startHandPos = testData(tr,direc).handPos(1:2,1);
            
            if nargout('positionEstimator') == 3
                [decodedPosX, decodedPosY, newParameters] = positionEstimator(past_current_trial, modelParameters,w);
                %                 modelParameters = newParameters;
            elseif nargout('positionEstimator') == 2
                [decodedPosX, decodedPosY] = positionEstimator(past_current_trial, modelParameters,w);
            end
            
            decodedPos = [decodedPosX; decodedPosY];
            decodedHandPos = [decodedHandPos decodedPos];
            
            meanSqError = meanSqError + norm(testData(tr,direc).handPos(1:2,t) - decodedPos)^2;
            
            % create confusion matrix
            trueMov(count) = direc;
            predMov(count) = newParameters.test_label;
            count = count + 1;
            
             n_predictions = n_predictions+length(times);
%             hold on
%             plot(decodedHandPos(1,:),decodedHandPos(2,:),'r','LineWidth',2);
%             plot(testData(tr,direc).handPos(1,times),testData(tr,direc).handPos(2,times),'b')
            
            % create confusion matrix
            %             trueMov(count) = direc;
            %             predMov(count) = newParameters;
            %             count = count + 1;
        end
    end
    confMat(:,:,t_it,w_it) = confusionmat(trueMov,predMov);
    correct = 0;
        for a = 1:length(trueMov)
            if trueMov(a) == predMov(a)
                correct = correct+1;
            end
        end
    acc(t_it,w_it) = correct/length(trueMov);
    t_it = t_it + 1;
    
end
w_it = w_it +1
end
% for a = 1:t_it-1
% subplot(4,4,a)
% heatmap(confMat(:,:,a))
% colormap default
% colorbar('off')
% title(num2str(320+20*(a-1)))
% end
