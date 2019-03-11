%% SVM separator
%This function will make up to 96 dimensions "plot"/matrix with the
%electrodes PSTH (later on PSTH in the -100-300 ms window) and each
%movement will be a different label
%
%
clear all
electrode = 1:98;

load monkeydata_training.mat
ix = randperm(length(trial));
split = 70;
trainingData = trial(ix(1:split),:);
testData = trial(ix(split+1:end),:);
TR = [];
TEST = [];
% label_tr =zeros(800,1);
% label_test = zeros(800,1);
label_vecTR =[];label_vecTST =[];
label_vec1 = zeros(split,1);
label_vec2 = zeros(100-split,1);

for movement = 1:8
    %    PSTH_training = [PSTH_training;PSTHplotter(trial,movement,electrode,50,0,trials)];
    %    labelvector1((movement-1)*trials+1:trials*movement) = movement;
    %    PSTH_test = [PSTH_test;PSTHplotter(trial,movement,electrode,50,0,50+trials)];
    %    labelvector2((movement-1)*trials+1:trials*movement) = movement;
    for i = electrode
        for j = 1:split
            cell_tr = trainingData(j,movement).spikes(i,:);
            processed_training(j,i) = sum(cell_tr);
            label_vec1(j) = movement;
        end
        for j = 1:100-split
            cell_test = testData(j,movement).spikes(i,:);
            processed_test(j,i) = sum(cell_test);
            label_vec2(j) = movement;
        end
    end
    TR = [TR;processed_training];
    TEST = [TEST;processed_test];
    label_vecTR = [label_vecTR;label_vec1];
    label_vecTST = [label_vecTST;label_vec2];
%     label_test = [label_test;label_vec2];
end


Mdl = fitcecoc(TR,label_vecTR);

[y,score] = predict(Mdl,TEST);

%% Verification step

correct = 0;
for a = 1:length(y)
    if y(a) == label_vecTST(a)
        correct = correct+1;
    end
end

heatmap(confusionmat(label_vecTST,y));
ylabel('True class')
xlabel('Predicted class')
% 
% figure
% hold on
% for movement = 1:8
%     [X,Y] = perfcurve(label_vecTST,score(:,movement),num2str(movement));
%     plot(X,Y)
%     
% end
% 
% legend('Movement 1','Movement 2','Movement 3', 'Movement 4', 'Movement 5','Movement 6', 'Movement 7', 'Movement 8')
% 
