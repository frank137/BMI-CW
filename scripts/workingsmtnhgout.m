%initialise max_cell2
max_cell2 = 0;
%initialise l2, later on length of cell2
l2 = 0;
movement = 1:2;
electrode = 1:10;
window = 50;

length_vs = round(1000/window);
for electrode_it = electrode
    spikes_overall = zeros(length(movement), length_vs);
    
    
    %for all trials and chosen movement
    for movement_it = movement
        %initialise total number of spikes
        spikes_total = zeros(1,length_vs);
        spikes_avg = zeros(1,length_vs);
        spikes_std = zeros(1,length_vs);
        
        for trial_number = 1:100
            cell2 = 0;
            %load spikes from electrode j for trial i and for selected movement
            cell = trial(trial_number,movement_it).spikes(electrode_it,:);
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
            for a = 1:window:length(cell)
                %cell2 = sum of elements of cell from index i to i+window-1,
                %e.g. if window is equal to 5, from 1 to 5, 6 to 10...
                cell2(w) = sum(cell(a:a+window-1));
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
            %add current cell2 (padded with zeros) on the right to spikes_total
            spikes_total = spikes_total + [cell2,zeros(1,l_difference)];
            %delete cell2 in case of any length mismatch between trials
            %clear cell2
        end
        %spikes_total = spikes_total/100;
        
        spikes_overall(movement_it,:) = spikes_total(:);
        
    end
    
    spikes_avg = mean(spikes_overall);
    if length(movement) > 1
        spikes_std = std(spikes_overall);
    end
end