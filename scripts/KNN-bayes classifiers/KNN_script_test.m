% Test Script to give to the students, March 2015
%% Continuous Position Estimator Test Script
% This function first calls the function "positionEstimatorTraining" to get
% the relevant modelParameters, and then calls the function
% "positionEstimator" to decode the trajectory.

%function RMSE = testFunction_for_students_MTb(teamName)
clear, clc, close all
load monkeydata_training.mat
addpath knn-linear-regrs
%addpath knn-multivariate-regrs
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

% Train Model
modelParameters = positionEstimatorTraining(trainingData,r);
%%
count = 1;
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
                modelParameters = newParameters;
            elseif nargout('positionEstimator') == 2
                [decodedPosX, decodedPosY] = positionEstimator(past_current_trial, modelParameters);
            end
            
            decodedPos = [decodedPosX; decodedPosY];
            decodedHandPos = [decodedHandPos decodedPos];
            
            meanSqError = meanSqError + norm(testData(tr,direc).handPos(1:2,t) - decodedPos)^2;
            true_lab(count) = direc;
            knn_lab(count) = newParameters.test_label;
            count = count + 1;
            
        end
        n_predictions = n_predictions+length(times);
        hold on
        plot(decodedHandPos(1,:),decodedHandPos(2,:), 'r','LineWidth',2);
        plot(testData(tr,direc).handPos(1,times),testData(tr,direc).handPos(2,times),'b')
        
        % create confusion matrix
        %         true_lab(count) = direc;
        %         knn_lab(count) = newParameters.test_label;
        %         count = count + 1;
    end
end

legend('Decoded Position', 'Actual Position')

RMSE = sqrt(meanSqError/n_predictions)
figure
[acc, f1, conf_mat] = calc_conf(true_lab, knn_lab)

confusionchart(true_lab,knn_lab);
title(['KNN, accuracy: ',num2str(acc*100),'%, f1 score: ',num2str(f1)])
%rmpath(genpath(teamName))
%end

% manually calcualte confusion matrix
function [acc, f1, conf_mat] = calc_conf(original, predicted )
class_numb = max(original);
conf_mat = zeros(class_numb);
for i = 1:class_numb
    for j = 1:class_numb
        temp = (original==i & predicted==j);
        conf_mat(i,j) = sum(temp);
    end
end

for c = 1:class_numb
    tp(c) = conf_mat(c,c);
    fp(c) = sum(conf_mat(:,c))-tp(c);
    fn(c) = sum(conf_mat(c,:))-tp(c);
    tn(c) = sum(conf_mat(:))-tp(c)-fp(c)-fn(c);
end
p = tp+fn;
n = fp+tn;
N = n+p;
Recall = tp./p; % sensitivity
Precision = tp./(tp+fp);
f1=mean(( 2*(Recall.*Precision) ) ./ ((Precision+Recall) ));
acc = sum(tp./N);
end

% manual plot confusion chart
function plot_confusion(acc, f1, conf,method)
s = surf(conf);
xlabel('Predicted Class')
ylabel('True Class')
grid off
axis([1 8 1 8])
view(0,-90)
title([method, ' Accuracy: ', num2str(acc,2),', F1 score: ',num2str(f1,2)]);
set(gca,'fontsize', 14);
end


