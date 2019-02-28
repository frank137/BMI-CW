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
for i = 1:length(trial(:,1)) % for the 100 trials for movement 1
        cell = trial(i,1).spikes(1,:); %pick spikes out of trial i for 
        %electrode (neuron) 1 for all the timesteps
        plot(cell)
    pause(0.1)
%         length(cell)
         matrix(i,1:length(cell)) = cell;
end
%   plotSpikeRaster(matrix)
figure
  contour(matrix)
  title('Spikes for one movement measured in one electrode over 100 trials')
  ylabel('Trials')
  xlabel('Time (ms)')
  
  %%
  dt = 2; %delta t = 1ms, over which spike density will be evaluated
  % for the 100 trials for movement 1
  t = 1;
%   spiketimes = zeros(100,30);
  for i = 1:length(trial(:,1))
      %for electrode(neuron) 1 and trial i for all the timesteos
      cell = trial(i,1).spikes(1,:);
      timelength = length(cell);
%       spike_count = zeros(100,timelength);
      
%       spiketimes(i,1:length(find(cell))) = find(cell);
%       psth(
    spikes_total = spikes_total + cell;
%       while t<timelength
%           for t = t:t+dt
%               spike_count(i,t) = sum(cell(t:t+dt));
% %               t = t+dt;
%           end
%       end
      
  end


% psth(
  
  