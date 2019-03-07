clear, clc, close all
load monkeydata_training.mat
figure
% hold on
movement = 4;

matrix = zeros(100,672);

%Calculate avergae movement over 100 trials
handpos_tt = zeros(3,900);
speed_tt = zeros(3,900);
for j = 1:100
    curr_pos = trial(j,movement).handPos;
    l_diff = length(handpos_tt)-length(curr_pos);
    handpos_tt = handpos_tt+[curr_pos,zeros(3,l_diff)];
%     speed_tt = speed_tt +[speedplot(trial,movement,j,0),zeros(3,l_diff)];
end
handpos_tt = handpos_tt/100;
% speed_tt = speed_tt/100;

% Plot average movement over 100 trials
hold off
subplot(2,1,2)
plot(handpos_tt(1,:))
hold on
plot(handpos_tt(2,:))
plot(handpos_tt(3,:))
xlim([0 900])
xlabel('Time (ms)')
legend('x','y','z')
hold off
title('Average movement over 100 trials')
ylabel('Coordinate magnitude')

% Find and plot spike map at simgle electrode level
for electrode = 1:96
    for i = 1:length(trial(:,movement)) % for the 100 trials for selected movement
        cell = trial(i,1).spikes(electrode,:); %pick spikes out of trial i for all electrode
        
        matrix(i,1:length(cell)) = cell;
    end
    
    %   plotSpikeRaster(matrix)
    subplot(2,1,1)
    contour(matrix)
    title({['Spikes for movement ',num2str(movement)];
        [' recorded at electrode ',num2str(electrode),' over 100 trials']})
    ylabel('Trials')
    xlabel('Time (ms)')
    pause(0.3)
end
