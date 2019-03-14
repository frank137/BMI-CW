function [modelParameters] = positionEstimatorTraining(training_data,endtime,learner)
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

for movement = 1:8
    %    PSTH_training = [PSTH_training;PSTHplotter(trial,movement,electrode,50,0,trials)];
    %    labelvector1((movement-1)*trials+1:trials*movement) = movement;
    %    PSTH_test = [PSTH_test;PSTHplotter(trial,movement,electrode,50,0,50+trials)];
    %    labelvector2((movement-1)*trials+1:trials*movement) = movement;
    for j = 1:length(training_data)
        for i = electrode 
            cell_tr = training_data(j,movement).spikes(i,1:endtime);
            processed_training(j,i) = sum(cell_tr);
            label_vec1(j) = movement;      
        end
        handpos = training_data(j,movement).handPos(1:2,:);
        zeropad = 1000-length(handpos);
        meanpath(:,:,movement) =  meanpath(:,:,movement)+[handpos,zeros(2,zeropad)];    
    end
    
    TR = [TR;processed_training];
    
    label_vecTR = [label_vecTR;label_vec1];
    
end
meanpath = meanpath./length(training_data);

Mdl = fitcecoc(TR,label_vecTR,'Learners',learner);

modelParameters.Mdl = Mdl;
modelParameters.path = meanpath;

end
