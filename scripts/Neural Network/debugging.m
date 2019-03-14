clear, clc
load('monkeydata_training.mat')
a = positionEstimatorTraining(trial);
[x,y] = positionEstimator(trial,a);

% for i = 1:8
% plot(a.mean_vals(i).mean_pos(1,:),a.mean_vals(i).mean_pos(2,:))
% hold on
% end