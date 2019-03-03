function [] = PSTHplotter(trial,movement,window,plot_option)
%% Plot a peri-stimulus time histogram (psth) or spikes as spike desnity over time
%movement number
%movement = 3;
%window = 300; %time window over which spikes will be avergaed

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

    for j = 1:96
        %initialise total number of spikes
        spikes_total = zeros(1,800);
        %for all trials and movement 1
        for i = 1:100
            %load spikes from electrode j for trial i and for selected movement
            cell = trial(i,movement).spikes(j,:);
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
        
        %plot option 1 is an animation, so plots will be coming on top of each
        %other for different electrodes
        if plot_option == 1
            %plot bar plot with x axis centered at the middle of each window, only
            %plot correspondent spikes_total values as rest is 0s
            bar(window*(1-0.5:l2-0.5),spikes_total(1:l2),1)
            grid on
            %if window is too short,only plot xticks in 20s as otherwise xaxis may
            %be impossible to visualise
            if window<20
                xticks(20*(0:l2))
            else
                %if window is sufficiently large do ticks at every window edge
                xticks(window*(0:l2))
            end
            
            title({'PSTH for';['Movement ',num2str(movement),', Electrode ',num2str(j)];['with window of ',num2str(window),'ms']})
            ylabel('Spike density (spikes/ms/trial)')
            xlabel('Time(ms)')
            
            
            %default pause
            pause(0.3)
            
            
        elseif plot_option == 2
            ax(j) = subplot(10,10,j);
            %plot bar plot with x axis centered at the middle of each window, only
            %plot correspondent spikes_total values as rest is 0s
            bar(window*(1-0.5:l2-0.5),spikes_total(1:l2),1)
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
    linkaxes(ax(:),'y')
    if plot_option == 2
        suptitle(['PSTHs for movement ', num2str(movement),' with window of ',num2str(window),'ms']);
    end

end

