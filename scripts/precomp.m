%% Precomp FG LCR DO
clear, clc, close all
load monkeydata_training.mat

trial1 = [trial(1,1).spikes];

[Units,T] = size(trial1); 


surf(trial1)
xlabel 'time (ms)'
ylabel 'recording units'

colormap(gray)
colorbar

figure('units','normalized','position',[.5 .5 .7 .4])
trial1 = logical(trial1);
plotSpikeRaster(trial1,'PlotType','imagesc','AutoLabel',true);
ylabel 'Units'