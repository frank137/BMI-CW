function data_out = prepare_regressor_data(data_to_format, train_or_test)
% train_or_test = 'train' prepares training data, train_or_test = 'test'
% prepares test data
[n,k] = size(data_to_format);
[i,t] = size(data_to_format(1,1).spikes);

dimensions = 1:i;
%[3,4,7,18,27,31,33,34,36,41,55,68,69,75,81,90,92,98];
%[3,4,18,34,36,96];%1:i; %electrodes used, some are useless so we shouldn't use them
end_time = 540; %ms
start_time = 320; %ms
step_time = 10; %ms
times = start_time:step_time:end_time;
dim_reducer = 3;%14; % final dimensions will be initial dimensions / dim_reducer
if strcmp(train_or_test,'train')
    % .in(20,30) contains the sum of the spikes up to time 320ms of
    % electrode number 30 from trial 20. .in(120,30) contains the sum of
    % the spikes up to time 340ms (if step_time = 20) electrode 30 for trial 20
    % .out(20,:) contains the x and y position for trial 20 at time stamp
    % 320ms, .out(120,:) contains the x and y for trial 20 at time stamp
    % 340 ms and so on.
    for a = 1:k
        data_formatted(a).in = zeros(n*length(times),length(dimensions)); %cumulative sums
        %data_formatted(a).out = zeros(length(times),2); %x,y
        %data_out(a).in = zeros(n*length(times),reduced_dimensions);
        data_out(a).out = zeros(length(times),2); %x,y
        count = 1;
        for tim = times
            for t = 1:n % number of trials
                data_out(a).out(count,:) = data_to_format(t,a).handPos(1:2,tim);
                for el = dimensions
                    data_formatted(a).in(count,el==dimensions) = sum(data_to_format(t,a).spikes(el,1:tim));
                end
                count = count +1;
            end
        end
        % reduce data
         %data_out(a).in = reduce_feat_dim(data_formatted(a).in,dim_reducer);%data_formatted(a).in;%
         [data_out(a).in, coeff_pca] = reduce_feat_dim(data_formatted(a).in, 9);
         data_out(a).coeff_pca=coeff_pca;
    end
elseif strcmp(train_or_test,'test')
    data_formatted = zeros(1,length(dimensions));
    for el = dimensions
        data_formatted(el==dimensions) = sum(data_to_format.spikes(el,:));
    end
    % reduce data
    %data_out = reduce_feat_dim(data_formatted,dim_reducer);%data_formatted;%reduce_feat_dim(data_formatted,0.65);
    data_out = data_formatted;
else
    warning('Insert either train or test')
end
end

% function reduced_features = reduce_feat_dim(features,sum_int)
%     %features is a obervations x dimensions vector and the dimensions are
%     %reduced by summing over dimensions sum_int by sum_int
%     new_dim = size(features,2)/sum_int;
%     reduced_features = zeros(size(features,1),new_dim);
%     start_idx = 1;
%     for i = 1:new_dim
%         reduced_features(:,i)= sum(features(:,start_idx:start_idx+sum_int-1),2);  
%         start_idx = start_idx+sum_int;
%     end 
%     
% end

function [reduced_features, best_coeff] = reduce_feat_dim(features, M_pca)
% examples:
%features = reduce_feat_dim(features,0.99); does PCA with 99% variance kept.

[coeff,score,latent,tsquared,explained,mu] = pca(features);
sum_eig = sum(explained(1:M_pca))
%perc_accepted = 0.95; % 144


best_coeff = coeff(:,1:M_pca);
reduced_features = score(:,1:M_pca);

end

