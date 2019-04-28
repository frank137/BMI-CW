%% tuning curve
hfig = figure('Name','Tuning curves for all 96 electrodes',...
    'NumberTitle','off',...
    'IntegerHandle','off');
for j = 1:98
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
    up = avg_spikes+std_spikes;
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
    
    subplot(10,10,j);
    fig(j) = errorbar(avg_spikes,std_spikes,'k');
    if j<11
        title(num2str(j))
    end
    if mod(j,10)==1
        ylabel(char(65+floor(j/10)),'fontweight','bold');
        ylh = get(gca,'ylabel');
        gyl = get(ylh);                                                         % Object Information
        ylp = get(ylh, 'Position');
        set(ylh, 'Rotation',0, 'Position',ylp, 'VerticalAlignment','middle', 'HorizontalAlignment','right')
    end
    if max(up) < 0.025
        set(gca,'Color',[0,0,0])
        fig(j).Color = [1 1 1];
        ax = gca;
        ax.GridColor = [0.9 0.9 0.9];
    elseif max(up)<0.05
          set(gca,'Color',[0.8,0.8,0.8])
        fig(j).Color = [1 1 1];  
    end
    
%     ylim([0 0.1])
    xlim([1 8])
    grid on
    
end
suptitle('Tuning curve for all 98 electrodes, x-axis is the movement and y-axis is the spike density (# of spikes/trial/ms)')

