%% SVM separator
%This function will make up to 96 dimensions "plot"/matrix with the
%electrodes PSTH (later on PSTH in the -100-300 ms window) and each
%movement will be a different label
%
%
electrode = 1:98;
PSTH_training = [];
PSTH_test = [];
labelvector1 = zeros(400,1);
labelvector2 = zeros(400,1);
trials = 1:50;


for movement = 1:8
%    PSTH_training = [PSTH_training;PSTHplotter(trial,movement,electrode,50,0,trials)];
%    labelvector1((movement-1)*trials+1:trials*movement) = movement; 
%    PSTH_test = [PSTH_test;PSTHplotter(trial,movement,electrode,50,0,50+trials)];
%    labelvector2((movement-1)*trials+1:trials*movement) = movement;
for i = electrode
        %initialise total number of spikes
        spikes_total = zeros(1,800);
        %for all trials and movement 1
        for j = trialvector 
end
% plot3(PSTHmovement(1,:,1),PSTHmovement(2,:,1),PSTHmovement(3,:,1),'+')
% hold on
% plot3(PSTHmovement(1,:,2),PSTHmovement(2,:,2),PSTHmovement(3,:,2),'o')


Mdl = fitcecoc(PSTH_training,labelvector);

