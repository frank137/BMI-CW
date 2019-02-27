%% Precomp FG LCR DO
clear, clc, close all
load monkeydata_training.mat

trial1 = [trial(1,1).spikes];

[Units,T] = size(trial1);


surf(trial1)
xlabel 'time (ms)'
ylabel 'recording units'

% colormap(gray)
colorbar
shading interp

figure('units','normalized','position',[.5 .5 .7 .4])
trial1 = logical(trial1);
plotSpikeRaster(trial1,'PlotType','imagesc','AutoLabel',true);
ylabel 'Units'

%GitHub line

%% 
figure
% hold on
matrix = zeros(100,672);
for i = 1:length(trial(:,1))
        cell = trial(i,1).spikes(1,:);
        plot(cell)
%         pause(0.1)
%         length(cell)
         matrix(i,1:length(cell)) = cell;
end
%   plotSpikeRaster(matrix)
  contour(matrix)