clear, clc, close all
load monkeydata_training.mat
figure
% hold on
movement = 4;



%Calculate avergae movement over 100 trials
handpos_tt = zeros(3,900);
speed_tt = zeros(3,900);
xall = zeros(100,900);
yall = zeros(100,900);
for j = 1:100
    curr_pos = trial(j,movement).handPos;
    l_diff = length(handpos_tt)-length(curr_pos);
    handpos_tt = handpos_tt+[curr_pos,zeros(3,l_diff)];
    xall(j,:) = xall(j,:)+[curr_pos(1,:),zeros(1,l_diff)];
    yall(j,:) = yall(j,:)+[curr_pos(2,:),zeros(1,l_diff)];
%     speed_tt = speed_tt +[speedplot(trial,movement,j,0),zeros(3,l_diff)];
end
handpos_tt = handpos_tt/100;
xAvg = mean(xall);
yAvg = mean(yall);
xSTD = std(xall);
ySTD = std(yall);
% speed_tt = speed_tt/100;
range = 1:600;
% Plot average movement over 100 trials
hold off
subplot(2,1,2)
hold on
plot(handpos_tt(1,range))
shadedErrorBar(range,xAvg(range),xSTD(range),'lineProps','r')
hold on
plot(handpos_tt(2,range))
shadedErrorBar(range,yAvg(range),ySTD(range),'lineProps','b')
line([ 300 300],[-100 50],'Color','k')
ylim([-100 50])
%plot(handpos_tt(3,:))
xlim([0 length(range)])
xlabel('Time (ms)')
legend('x','y','z')
hold off
title('Average movement over 100 trials')
ylabel('Coordinate magnitude')
hold off
grid on

matrix = zeros(100,length(range));
% 
% Find and plot spike map at simgle electrode level
for electrode = 1:98
    for i = 1:length(trial(:,movement)) % for the 100 trials for selected movement
        cell = trial(i,1).spikes(electrode,:); %pick spikes out of trial i for all electrode
        
        matrix(i,1:593) = cell(1:593);
    end
    
    %   plotSpikeRaster(matrix)
    subplot(2,1,1)
%     hold off
%     line([300 300],[-0 100],'Color','k')
%     hold on
    contour(matrix)
    ylim([0 100])
    title({['Spikes for movement ',num2str(movement)];
        [' recorded at electrode ',num2str(electrode),' over 100 trials']})
    ylabel('Trials')
    xlabel('Time (ms)')
    pause;
end


%%
% figure
% plot(xAvg(range),yAvg(range))
% shadedErrorBar(xAvg(range),yAvg(range),ySTD(range),'lineProps','b')
% 
% ylim([0 60])
