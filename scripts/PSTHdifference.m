function [] = PSTHdifference(trial,window,movement1,movement2,plot_option,electrode)
%% Plot a peri-stimulus time histogram (psth) or spikes as spike desnity over time
%Example: PSTHdifference(trial,50,1,6,2,1:96) plot 50ms windows, for
%movements 1 and 6, using plotting option 2 and seeing all electrodes.

% This function computes the difference in PSTH for two movement and a
% given set of electrodes
%the inputs go as follow:
%trial: trial data variable loaded when you load monkeydata_training.mat
%window: your time window over which spike rate denisty will be calculated
% Movement 1 & 2: selected movement which difference will be taken
% plot_option = 1 or 2, plot option 1 will show a full screen PSTH for
% every electrode and will show the next electrode upon pressing any key.
% option 2 will show all 96 electrodes plots in a figure with 96 subplots
%electrode can be a vector of any size between 1 and 96 giving the index of
%the electrodes the user wishes to see
%
% Please note these PSTH compute the sum of spikes over a time
% 'window' over all the trials, NOT averaged over trials, though
% this could be easily implemented if desired.
movement = [movement1 movement2];
%initialise max_cell2
max_cell2 = 0;
%initialise l2, later on length of cell2
l2 = 0;
%for all electrode do this
hfig = figure('Toolbar','none',...
    'Menubar', 'none',...
    'Name','Peri-stimulus Time Histogram plotter',...
    'NumberTitle','off',...
    'IntegerHandle','off','units','normalized','outerposition',[0 0 1 1]);
spikes_overall = zeros(2, 800);

for j= electrode
    %initialise total number of spikes
    spikes_total = zeros(1,800);
    %for all trials and chosen movement
    for index_m = 1:2
        for i = 1:100
            %load spikes from electrode j for trial i and for selected movement
            cell = trial(i,movement(index_m)).spikes(j,:);
            %get time length of spike measurement
            timelength = length(cell);
            %calculate remainder of timlength to visualising window
            remainder = mod(timelength,window);
            %pad cell with zeros so as to make cell divisible into an integer
            %amount of time windows
            cell = [cell,zeros(1,window-remainder)];
            
            %initialise index of cell2, w
            w= 1;
            %for length of cell and jumping in window steps
            for i = 1:window:length(cell)
                %cell2 = sum of elements of cell from index i to i+window-1,
                %e.g. if window is equal to 5, from 1 to 5, 6 to 10...
                cell2(w) = sum(cell(i:i+window-1));
                %increase index of cell2 by 1
                w = w+1;
            end
            
            %save max length of cell2 for correct plotting later on
            if length(cell2)>l2
                l2 = length(cell2);
            end
            
            if max(cell2)>max_cell2
                max_cell2 = max(cell2);
            end
            
            %get difference between length of spikes_total and cell2
            l_difference = length(spikes_total)-length(cell2);
            %add current cell2 (padded with zeros on the right to spikes_total
            spikes_total = spikes_total + [cell2,zeros(1,l_difference)];
            %delete cell2 in case of any length mismatch between trials
            clear cell2
        end
        %spikes_total = spikes_total/100;
        
        spikes_overall(index_m,:) = spikes_total(:);
        
    end
    

    spikes_diff = spikes_overall(2,:)- spikes_overall(1,:);
    
    %spikes_std = std(spikes_overall);
    %plot option 1 is an animation, so plots will be coming on top of each
    %other for different electrodes
    if plot_option == 1
        %plot bar plot with x axis centered at the middle of each window, only
        %plot correspondent spikes_total values as rest is 0s
        hold off
        plot(window*(1-0.5:l2-0.5),spikes_diff(1:l2))%,1)
         hold on
          plot(window*(1-0.5:l2-0.5),spikes_overall(1,1:l2))%,1)
           plot(window*(1-0.5:l2-0.5),spikes_overall(2,1:l2))%,1)
           legend('Difference','Movement 1','Movement 2')
%         errorbar(window*(1-0.5:l2-0.5),spikes_diff(1:l2),spikes_std(1:l2),'+')
        grid on
        ylim([-300 600])
        %if window is too short,only plot xticks in 20s as otherwise xaxis may
        %be impossible to visualise
        if window<20
            xticks(20*(0:l2))
        else
            %if window is sufficiently large do ticks at every window edge
            xticks(window*(0:l2))
        end
        
        title({['PSTH for all movements at electrode ',num2str(j)];['with window of ',num2str(window),'ms']})
        ylabel('Spike density (spikes/ms/trial)')
        xlabel('Time(ms)')
        
        
        %default pause
        pause;
        
        
    elseif plot_option == 2
        ax(j) = subplot(10,10,j);
        %plot bar plot with x axis centered at the middle of each window, only
        %plot correspondent spikes_total values as rest is 0s
        bar(window*(1-0.5:l2-0.5),spikes_overall(1,1:l2)),1)
        hold on
        bar(window*(1-0.5:l2-0.5),spikes_overall(2,1:l2)),1)
        
        bar(window*(1-0.5:l2-0.5),spikes_diff(1:l2),1)
        %errorbar(window*(1-0.5:l2-0.5),spikes_avg(1:l2),spikes_std(1:l2))
        grid on
        %if window is too short,only plot xticks in 100s as otherwise xaxis may
        %be impossible to visualise
        if window<200
            xticks(200*(0:l2))
        else
            %if window is sufficiently large do ticks at every window edge
            xticks(window*(0:l2))
        end
        title(['Electrode ', num2str(j)])
        
        %             suptitle(['PSTHs for movement ', num2str(movement),' with window of ',num2str(window),'ms']);
    end
    
end

if plot_option == 2
    linkaxes(ax(:),'y')
    suptitle(['PSTHs for all movements with window of ',num2str(window),'ms']);
end

end
