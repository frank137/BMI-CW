%% Precomp FG LCR DO
clear, clc, close all
load monkeydata_training.mat

trial1 = [trial(1,1).spikes];


%%
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
    %     plot(cell)
    %     pause(0.1)
    %         length(cell)
    matrix(i,1:length(cell)) = cell;
end
%   plotSpikeRaster(matrix)
figure
contour(matrix)
title('Spikes for one movement measured in one electrode over 100 trials')
ylabel('Trials')
xlabel('Time (ms)')

%% Plot a peri-stimulus time histogram (psth) or spikes as spike desnity over time
%movement number
movement = 3;
window = 300; %time window over which spikes will be avergaed
%for all electrode do this
for j = 1
    spikes_total = zeros(1,800);
    %for all trials and movement 1
    l2 = 0;
    for i = 1:length(trial(:,movement))
        %for electrode(neuron) 1 and trial i for all the timesteos
        cell = trial(i,movement).spikes(j,:);
        timelength = length(cell);
        remainder = mod(timelength,window);
        cell = [cell,zeros(1,window-remainder)];
        
        
        w= 1;
        for i = 1:window:length(cell)
            cell2(w) = sum(cell(i:i+window-1));
            w = w+1;
        end
        
        if length(cell2)>l2
            l2 = length(cell2);
        end
        
        l_difference = length(spikes_total)-length(cell2);
        spikes_total = spikes_total + [cell2,zeros(1,l_difference)];
        clear cell2
    end
    
    %     spikes_total = spikes_total/100;
    % histogram(713,spikes_total);
    
    %plot(1:750,(spikes_total))
    bar(window*(1-0.5:l2-0.5),spikes_total(1:l2),1)
    grid on
    if window<20
        xticks(20*(0:l2))
    else
        xticks(window*(0:l2))
    end
    ylim(window*[0 l2])
    title({'PSTH for';['Movement ',num2str(movement),', Electrode ',num2str(j)];['with window of ',num2str(window),'ms']})
    ylabel('Spike density (spikes/ms/trial)')
    xlabel('Time(ms)')
    
    pause(0.3)
end
% psth(
%%



%% Plot hand position for different trials
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


%% plot x against y
movement = 1;

xmap = zeros(100,750);
for i = 1:length(trial(:,movement)) % for the 100 trials for movement 1
    handpos = trial(i,movement).handPos; %pick spikes out of trial i for
    %electrode (neuron) 1 for all the timesteps
    
    t = length(handpos(1,:));
    plot(handpos(1,:),handpos(2,:))
    
    title(['Movement ',num2str(movement),', Trial ',num2str(i)])
    xlabel('x coordinate')
    ylabel('y coordinate')
    xlim([-70 70])
    ylim([-70 70])
    ax = gca;
    ax.XAxisLocation = 'origin';
    ax.YAxisLocation = 'origin';
    
    pause(0.1)
    
    xmap(i,1:length(handpos(1,:))) = handpos(1,:);
    ymap(i,1:length(handpos(2,:))) = handpos(2,:);
    zmap(i,1:length(handpos(3,:))) = handpos(3,:);
end


%% plot x,y and z coordinate over time for all trials
figure
subplot(1,3,1)
surf(xmap)
shading interp
axis square
title('x position over 100 trials')
subplot(1,3,2)
surf(ymap)
shading interp
axis square
title('y position over 100 trials')
subplot(1,3,3)
surf(zmap)
shading interp
axis square
title('z position over 100 trials')

%% finding angle

%finding angle
movement = 3;

for i = 1:length(trial(:,movement)) % for the 100 trials for movement 1
    handpos = trial(i,movement).handPos; %pick spikes out of trial i for
    %electrode (neuron) 1 for all the timesteps
    angle = [];
    timelength = length(handpos);
    %cos theta = a dot b /|a||b|
    for a = 1:timelength-1
        x = [handpos(1,a) handpos(1,a+1)];
        y = [handpos(2,a) handpos(2,a+1)];
        angle(a) = acos(dot(x,y)/(norm(x)*norm(y)));
        
    end
    angle = (180/pi)*angle;
    plot(angle)
    pause(0.2)
    
end

%% tuning curve
hfig = figure('Toolbar','none',...
    'Menubar', 'none',...
    'Name','Tuning curves for all 96 electrodes',...
    'NumberTitle','off',...
    'IntegerHandle','off');
for j = 1:96
    spikes_total = zeros(8,975);
    %for all movements
    for movement = 1:8
        %for all trials
        for i = 1:length(trial(:,movement))
            %for electrode(neuron) 1 and trial i for all the timesteos
            cell = trial(i,movement).spikes(j,:);
            timelength = length(cell);
            l_difference = length(spikes_total)-length(cell);
            spikes_total(movement,:) = spikes_total(movement,:) + [cell,zeros(1,l_difference)];
            
        end
        
        
    end
    
    %spikes are averaged over the number of trials (100)
    spikes_total = spikes_total/100;
    %transpose matrix
    spikes_total = spikes_total';
    % calculate average spiking rate for specific electrode cell over time (for
    % one movement, for one electrode), this yields avergae spiking rate in
    % units of spikes/ms/trial
    avg_spikes = mean(spikes_total);
    %calculate std of spikes over time
    std_spikes = std(spikes_total);
    %plot errorbar
    %     subplot(2,1,1)
    %     errorbar(avg_spikes,std_spikes)
    %     title(['Tuning curve for electrode ',num2str(j)])
    %     ylabel('Spike rate (# of spikes/ms/trial)')
    %     xlabel('Preferred direction')
    %     ylim([0 0.1])
    % xlim([1 8])
    %     subplot(2,1,2)
    %     plot(avg_spikes)
    %     title(['Tuning curve for electrode ',num2str(j)])
    %     ylabel('Spike rate (# of spikes/ms/trial)')
    %     xlabel('Preferred direction')
    %     ylim([0 0.1])
    % xlim([1 8])
    %     pause(0.2)
    
    subplot(10,10,j)
    errorbar(avg_spikes,std_spikes)
    title(num2str(j))
    ylim([0 0.1])
    xlim([1 8])
    
end
suptitle('Tuning curve for all 96 electrodes, x-axis is the movement and y axis is avg spike rate')



%% speed plot
movement = 1;
for i = 1:100
    handpos = trial(i,movement).handPos; %pick spikes out of trial i for
    for a = 1:length(handpos)-1
        dposdt(:,a) = handpos(:,a+1)-handpos(:,a);
    end
    
    subplot(2,1,1)
    hold off
    plot(handpos(1,:))
    hold on
    plot(handpos(2,:))
    plot(handpos(3,:))
    xlim([0 900])
    legend('x','y','z')
    title(['Movement ',num2str(movement),', Trial ',num2str(i)])
    ylabel('Coordinate magnitude')
    
    subplot(2,1,2)
    hold off
    plot(dposdt(1,:))
    hold on
    plot(dposdt(2,:))
    plot(dposdt(3,:))
    xlim([0 900])
    legend('dxdt','dydt','dzdt')
    title(['Movement ',num2str(movement),', Trial ',num2str(i)])
    ylabel('Speed magnitude')
    
    
    pause(0.1)
    
    
end



