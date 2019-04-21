function [] = PSTHoverall(trial,window,movement,electrode,plot_option)
%% Plot a peri-stimulus time histogram (psth) or spikes as spike desnity over time
% This codes gives you the average PSTH for a set of movements including
% one single movement and up to 8 movement. PSTH stands for peri-stimulus
% time histogram and gives you spike density over time where spike density
% is measured as the sum of spikes within a time window averaged over the
% number of trials. For example if we had 50 spikes in 20 ms over 100
% trials this will yield a value of 0.025. In this script we have not
% averaged the spikes neither over time nor trials, though this is simple
% to implement.

% Input description:
%   - trial: struct matrix containing spike data and recorded handposition
%   - window: time window over which spikes will be counted, if 50 ms, sum
%   of spikes will be calculated every 50ms.
%   - movement: this is a vector of any length between 1 and 8, it will
%   tell the code to compute the average PSTH for the specified movements
%   - electrode: this is a vector of any length between 1 and 98, it will
%   tell the code to compute the average PSTH for each specified electrode
%   - plot_option: two options are available, plot_option = 1 or 2, if the
%   first is chosen, the function will output the PSTH plot of each
%   electrode one at a time and will go to the next electrode upon pressing
%   of any key from the user. Option number two will give a set of subplots
%   of all chosen electrodes and their respective PSTHs.
%   
%
% Examples to run the code:
% PSTHoverall(trial,50,1:8,1:98,2), 50ms windows, for movement 1 to 8, for
% all electrodes (1:98) and plotting option 2
%


%initialise max_cell2
max_cell2 = 0;
%initialise l2, later on length of cell2, for plotting aesthetics
l2 = 0;

if (plot_option == 1 || plot_option == 2) == 1
   figure('Name','Peri-stimulus Time Histogram plotter',...
        'NumberTitle','off',...
        'IntegerHandle','off','units','normalized','outerposition',[0 0 1 1]);
end

%length of spikes related variables for optimal computational use, 1000 is
%chosen as some recordings have around 900 time points, although these are
%not plotted at the end
length_vs = round(1000/window);
for electrode_it = electrode
    % initialize/reset variable storing processed spikes for every selected
    % movement, do this for each electrode iteration
    spikes_overall = zeros(length(movement), length_vs);

    %iterate through chosen movements
    for movement_it = movement
        %initialise total number of spikes
        spikes_total = zeros(1,length_vs);
        %initialise avg spikes
        spikes_avg = zeros(1,length_vs);
        %initialise std of spikes
        spikes_std = zeros(1,length_vs);
        
        %iterate through all trials
        for trial_number = 1:100
            %initialise cell2, which will be the vector containing the sum
            %of spikes over time windows
            cell2 = 0;
            %load spikes from electrode electrode_it for trial trial_number
            %and for selected movement movement_it
            cell = trial(trial_number,movement_it).spikes(electrode_it,:);
            %get time length of spike measurement
            timelength = length(cell);
            %calculate remainder of timlength to visualising window
            remainder = mod(timelength,window);
            %pad cell with zeros so as to make cell divisible into 
            %an integer amount of time windows
            cell = [cell,zeros(1,window-remainder)];
            
            %initialise index of cell2, w
            w= 1;
            %for length of cell and jumping in window steps
            for a = 1:window:length(cell)
                %cell2 = sum of elements of cell from index i to i+window-1,
                %e.g. if window is equal to 5, from 1 to 5, 6 to 10...
                cell2(w) = sum(cell(a:a+window-1));
                %increase index of cell2 by 1
                w = w+1;
            end
            
            %save max length of cell2 for aesthetic plotting later on
            if length(cell2)>l2
                l2 = length(cell2);
            end
            
            %this bit is not really necessary
            if max(cell2)>max_cell2
                max_cell2 = max(cell2);
            end
            
            %get difference between length of spikes_total and cell2
            l_difference = length(spikes_total)-length(cell2);
            %add current cell2 (padded with zeros) on the right to spikes_total
            spikes_total = spikes_total + [cell2,zeros(1,l_difference)];
            %delete cell2 in case of any length mismatch between trials
            clear cell2
        end
        %implement this if you want spikes to be averaged over trials and
        %time, so as to give spikes per trial per ms
        spikes_total = spikes_total/(100*window);
        
        %store spikes_total for every movement selected
        spikes_overall(movement_it,:) = spikes_total(:);
        
    end
    
    % if there is more than one movement calculaate spikes_std as usual if
    % not keep it as 0 as initialised previously and calculate spikes_avg
    % as usual.
    if length(movement) > 1
        spikes_std = std(spikes_overall);
        spikes_avg = mean(spikes_overall);
    % if there is only one movement spikes_avg is same as spikes_overall
    else
        spikes_avg = spikes_overall;
    end
    %plot option 1 is an animation, so plots will be coming on top of each
    %other for different electrodes. Plots will change upon pressing any
    %key
    if plot_option == 1
        %plot bar plot with x axis centered at the middle of each window, only
        %plot correspondent spikes_total values as rest is 0s
        hold off
        % the window*(1-0.5:l2-0.5) bit is like that to have each bar
        % centered at window/2 and spanning window limits, i.e. 0 and
        % window, window and 2*window ...
        bar(window*(1-0.5:l2-0.5),spikes_avg(1:l2),1)
        hold on
        errorbar(window*(1-0.5:l2-0.5),spikes_avg(1:l2),spikes_std(1:l2),'+')
        grid on
        ylim([0 600])
        xlim([0 800])
        %if window is too short,only plot xticks in 20s as otherwise xaxis may
        %be impossible to visualise
        if window<20
            xticks(20*(0:l2))
        else
            %if window is sufficiently large do ticks at every window edge
            xticks(window*(0:l2))
        end
        
        title({['PSTHs for movements: ',num2str(movement),'.'];['Spike window of ',num2str(window),'ms']})
        ylabel('Spike density (spikes/ms/trial)')
        xlabel('Time(ms)')
        
        
        %default pause
        pause;
        
        
    elseif plot_option == 2
        %we wish to make a square set of subplots, hence we calculate the
        %square root of the number of electrodes enquired
        side_sub = ceil(sqrt(length(electrode)));
        %make a bunch of axes to laterr on link them
        ax(electrode_it) = subplot(side_sub,side_sub,electrode_it);
        %plot bar plot with x axis centered at the middle of each window, 
        %only plot correspondent spikes_total values as rest is 0s
        hold on
        fig = bar(window*(1-0.5:l2-0.5),spikes_avg(1:l2),1);
        up = spikes_avg(1:l2)+spikes_std(1:l2);
        set(fig,'FaceColor', [0 0 0]);
        set(fig,'EdgeColor', [1 1 1]);
        %don't plot errorbar here as it looks too messy
%         errorbar(window*(1-0.5:l2-0.5),spikes_avg(1:l2),spikes_std(1:l2))
        grid on
        %if window is too short,only plot xticks in 200s as otherwise xaxis may
        %be impossible to visualise
        if window<200
            xticks(200*(0:l2))
%             xtickangle(45)
        else
            %if window is sufficiently large do ticks at every window edge
            xticks(window*(0:l2))
        end
        title([num2str(electrode_it)])
        
         if max(up) < 0.025
        set(gca,'Color',[0,0,0])
        set(fig,'FaceColor', [1 1 1]);
        set(fig,'EdgeColor', [0 0 0]);
        ax2 = gca;
        ax2.GridColor = [0.9 0.9 0.9];
%     elseif max(up)<0.05
%           set(gca,'Color',[0.8,0.8,0.8])
%         fig.Color = [1 1 1];  
    end
    
        

    end
    
end

if plot_option == 2
    linkaxes(ax(:),'x')
    ax(1).XLim = [0,800];
    %xtickangle(ax(:),45)
    suptitle({['PSTHs for movements: ',num2str(movement),'.'];['Spike window of ',num2str(window),'ms']});
end

end

