%% Population encoding hypothesis plotter
% This script allows you to obesrve in parallel for a movement of your choice
%; spikes from the 96 electrodes for every trial, x,y and z movement of the
%monkey's arm, angle between u and v vector over time and the movement in
%the x and y coordinates

% I believe this shows that trying to correlate the signals from all the
% electrodes to the hand position is useless as there doesn't seem to be
% any relationship there


%% load file 
clear, clc, close all
load monkeydata_training.mat
%% total plotting
hfig = figure('Toolbar','none',...
              'Menubar', 'none',...
              'Name','Tuning curves for all 96 electrodes',...
              'NumberTitle','off',...
              'IntegerHandle','off','units','normalized','outerposition',[0 0 1 1]);
movement = 3;
for i = 1:100
    %     for movement = 1:8
%     figure
    handpos = trial(i,movement).handPos; %pick spikes out of trial i for
    %electrode (neuron) 1 for all the timesteps
    cell = trial(i,1).spikes;
    hold off
    subplot(4,1,2)
    plot(handpos(1,:))
    hold on
    plot(handpos(2,:))
    plot(handpos(3,:))
    xlim([0 900])
    legend('x','y','z')
    hold off
    title(['Movement ',num2str(movement),', Trial ',num2str(i)])
    ylabel('Coordinate magnitude')
    
    
    subplot(4,1,3)
    angle = [];
    timelength = length(handpos);
    %cos theta = a dot b /|a||b|
    for a = 1:timelength-1
        u = [handpos(1,a) handpos(2,a)];
        v = [handpos(1,a+1) handpos(2,a+1)];
        angle(a) = acos(dot(u,v)/(norm(u)*norm(v)));
    end
    angle = (180/pi)*angle;
    plot(angle)
    title('Angle between vector u and v')
    ylabel('Angle')
    xlabel('Time (ms)')
    
    subplot(4,1,4)
    plot(handpos(1,:),handpos(2,:))
    
    title(['Movement ',num2str(movement),', Trial ',num2str(i)])
    xlabel('x coordinate')
    ylabel('y coordinate')
    xlim([-70 70])
    ylim([-70 70])
    ax = gca;
    ax.XAxisLocation = 'origin';
    ax.YAxisLocation = 'origin';
    
    subplot(4,1,1)
    contour(cell)
    title(['Electrodes spikes over time, Trial: ', num2str(i)])
    xlim([0 900])
    ylabel('Electrode index')
    
         pause(0.05)
    %     end
end
