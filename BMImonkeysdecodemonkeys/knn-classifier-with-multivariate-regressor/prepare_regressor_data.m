function data_out = prepare_regressor_data(data_to_format, train_or_test)
% train_or_test = 'train' prepares training data, train_or_test = 'test'

% get data size: n: trials(100), k: movements/angles(8), i: electrodes (98), t:
% time (variable length)
[n,k] = size(data_to_format);
[i,t] = size(data_to_format(1,1).spikes);

%use only "useful" electrodes
dimensions = 1:i;%[3,4,7,18,27,31,33,34,36,41,55,68,69,75,81,90,92,98];
%[3,4,7,18,27,31,33,34,36,41,55,68,69,75,81,90,92,98];
%[3,4,18,34,36,96];%1:i; %electrodes used, some are useless so we shouldn't use them

end_time = 540; %ms
start_time = 320; %ms
step_time = 20; %ms
%time vector over which spikes will be calculated, they will be calculated
%in the form: sum(spikes(1:320)), sum(spikes(1:340))...
times = start_time:step_time:end_time;
% dim_reducer "combines" electrodes by adding the spikes of every
% consecutive 3, dim_reducer MUST BE A FACTOR OF THE NUMBER OF ELECTRODES
% WE ARE USING, OTHERWISE TROUBLE
dim_reducer = 14; % final dimensions will be initial dimensions / dim_reducer
if strcmp(train_or_test,'train')
    % .in(20,30) contains the sum of the spikes up to time 320ms of
    % electrode number 30 for trial 20.
    % .in(120,30) contains the sum of the spikes up to time 340ms
    % (if step_time = 20) electrode 30 for trial 20
    % .out(20,:) contains the x and y position for trial 20 at time stamp
    % 320ms, .out(120,:) contains the x and y for trial 20 at time stamp
    % 340 ms and so on.
    % I BELIEVE WHAT IS ABOVE IS WRONG, I propose
    % .in(1,1) contains the sum of the spikes up to time 320 ms for
    % movement 1 ??????
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %       PLEASE FRAN CHANGE THIS
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                    Electrode 1 | Electrode 2 | Electrode 3 ...
    %Trial 1 - 1:320ms  | sum(spikes)|
    %Trial 2 - 1:320ms  |
    %Trial 3 - 1:320ms
    %       .
    %       .
    %       .
    %Trial 100 - 1:320ms
    %Trial 1 - 1:340ms
    %Trial 2 - 1:340ms
    %       .
    %       .
    %       .
    %Trial 100 - 1:540ms
    
    for a = 1:k
        %cumulative sums: initialise with 100 (# of trials)*12 (recording
        %times for every trial) rows and as many columns as you are using
        %electrodes
        data_formatted(a).in = zeros(n*length(times),length(dimensions));
        %data_formatted(a).out = zeros(length(times),2); %x,y
        %data_out(a).in = zeros(n*length(times),reduced_dimensions);
        %output is the x,y trajectories over time
        data_out(a).out = zeros(length(times),2); %x,y
        count = 1;
        %for all times (every 20 ms)
        for tim = times
            for t = 1:n % number of trials
                %store handposition for every trial and every movement at
                %precised time (320, 340, 360 ... 540)
                data_out(a).out(count,:) = data_to_format(t,a).handPos(1:2,tim);
                
                %for all electrodes sum input data (data_to_format) from 1
                %to tim (1 to 320, 1 to 340, 1 to 360...)
                for el = dimensions
                    data_formatted(a).in(count,el==dimensions) = sum(data_to_format(t,a).spikes(el,1:tim));
                end
                %increase handpos storage vector
                count = count +1;
            end
        end
        % reduce data by combining data for every consecutive electrodes,
        % this will be part of the function output along with the x and y
        % positions. reduce_feat_dim takes as input the formatted data for
        % all original dimensions and the dim_reducer factor
        data_out(a).in = reduce_feat_dim(data_formatted(a).in,dim_reducer);
        
        %[data_out(a).in, coeff_pca] = reduce_feat_dim(data_formatted(a).in, 8);
        %data_out(a).coeff_pca=coeff_pca;
        data_out(a).coeff_pca=0;
    end
    
    %if only preparing data for testing regressor then just sum spikes over
    %dimensions (# of electrodes) and then reduce dimensions
elseif strcmp(train_or_test,'test')
    data_formatted = zeros(1,length(dimensions));
    for el = dimensions
        data_formatted(el==dimensions) = sum(data_to_format.spikes(el,:));
    end
    % reduce data
    data_out = reduce_feat_dim(data_formatted,dim_reducer);%data_formatted;%reduce_feat_dim(data_formatted,0.65);
    %data_out = data_formatted;
else
    warning('Insert either train or test')
end
end

function reduced_features = reduce_feat_dim(features,sum_int)
%features is a obervations x dimensions vector and the dimensions are
%reduced by summing over dimensions sum_int by sum_int
new_dim = size(features,2)/sum_int;
%reduced feature space is created
reduced_features = zeros(size(features,1),new_dim);
start_idx = 1;
for i = 1:new_dim
    reduced_features(:,i)= sum(features(:,start_idx:start_idx+sum_int-1),2);
    %index changes every sum_int (in example case = 3),in this case
    %new_dimension(1) = old_dimension(1)+old_dimension(2)+old(dimension(3)
    start_idx = start_idx+sum_int;
end

end

% function [reduced_features, best_coeff] = reduce_feat_dim(features, M_pca)
% % examples:
% %features = reduce_feat_dim(features,0.99); does PCA with 99% variance kept.
%
% [coeff,score,latent,tsquared,explained,mu] = pca(features);
% sum_eig = sum(explained(1:M_pca))
% %perc_accepted = 0.95; % 144
%
%
% best_coeff = coeff(:,1:M_pca);
% reduced_features = score(:,1:M_pca);
%
% end

