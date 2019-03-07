%% Precomp FG LCR DO
clear, clc, close all
load monkeydata_training.mat

trial1 = [trial(1,1).spikes];

[num_trials, num_angles] = size(trial);
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

figure
plot(trial(1,1).handPos(1,:))
hold on
plot(trial(1,1).handPos(2,:))
plot(trial(1,1).handPos(3,:))

%% part 2
% chose plots
h1 = figure(1);
h1.Units = 'normalized';
h1.Position = [.3 .5 .7 .4];

h2 = figure(2);
h2.Units = 'normalized';
h2.Position = [.3 0 .7 .4];

for el_cell = 1:98
    ang = 2;
    figure(1);
    
    hold off
    for i = 1:num_trials
        if i ~= 1, hold on, end
        trial_plot = trial(i,ang).spikes(el_cell,:);
        plot(i*trial_plot,'.','MarkerSize',10);
        
    end
    title(['Angle ',num2str(ang),', Cell ',num2str(el_cell)]);
    
    figure(2);
    hold off
    plot(trial(i,ang).handPos(1,:))
    hold on
    plot(trial(i,ang).handPos(2,:))
    plot(trial(i,ang).handPos(3,:))
    title(['Angle ',num2str(ang)]);
    xlim([0 1000])
    pause(0.3)
end

%%
% chosen single plots

el_cell = [96, 91, 54, 44, 25, 22,8 ,10];
for el_cell = el_cell
    figure
    hold on
    for i = 1:num_trials
        trial_plot = trial(i,1).spikes(el_cell,:);
        plot(i*trial_plot,'.','MarkerSize',10);
        
    end
    title(['Angle ',num2str(ang),', Cell ',num2str(el_cell)])
end


%% 3
% PSTH
close all

el_cell = 1;
ang = 1;
dt = 20; %ms
padded_size = 800; %ms to zero pad

h1 = figure(1);
h1.Units = 'normalized';
h1.Position = [.3 .5 .7 .4];

bins_psth = floor(padded_size/dt);
ro_psth = zeros(bins_psth,dt,num_trials);
for i = 1:num_trials
    
    x = trial(i,ang).spikes(el_cell,:);
    tot_ms = size(x,2);
    x = [x, zeros(1,padded_size-tot_ms)];
    
    for idx = 0:bins_psth-1
       ro_psth(idx+1,:,i) = x(idx*dt+1:(idx+1)*dt);     
    end
    
end

density = mean(mean(ro_psth,3),2); % activity per ms

plot(0:dt:padded_size-1, density)
title(['density for all tirals angle ',num2str(ang),', cell ',num2str(el_cell)])
ylabel('density spikes/ms/trial')
