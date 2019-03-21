 %% Test function for robust regressor
 clear, clc, close all
addpath(['..',filesep,'KNN-bayes classifiers'])
addpath(['..'])
load monkeydata_training.mat

%start by regressing position 1
[n,k] = size(trial);
[i,t] = size(trial(1,1).spikes);

rng(2013);
ix = randperm(length(trial));
trainingData = trial(ix(1:80),:);
testData = trial(ix(81:end),:);

%% tidy data up
data_formatted_train = prepare_regressor_data_rob(trainingData,'train');
data_formatted_test = prepare_regressor_data_rob(testData,'train');

ang1_in = data_formatted_train(1).in;
Y = data_formatted_train(1).out;

ang1_in_test   = data_formatted_test(1).in;
Y_test = data_formatted_test(1).out;
% find order
%s = svd(ang1_in);
%stem(s)


%% train

r = 20; % rank
[Ur,Sr,Vr] = svds(ang1_in,r);
Xnoise_hat = Ur*Sr*Vr';


% OLS method
B_ols = (ang1_in'*ang1_in)\(ang1_in'*Y);
%B_ols = (X'*X)\(X'*Y);

Y_ols = ang1_in*B_ols;

% PCR method
B_pcr = Vr/Sr*Ur'*Y;

Y_pcr = Xnoise_hat*B_pcr;

err_ols_train = immse(Y,Y_ols)
err_pcr_train = immse(Y,Y_pcr)

%% testing
[Ur,Sr,Vr] = svds(ang1_in_test,r);
Xtest_hat = Ur*Sr*Vr';


Y_test_ols = ang1_in_test*B_ols;
Y_test_pcr = Xtest_hat*B_pcr;

err_ols = immse(Y_test,Y_test_ols)
err_pcr = immse(Y_test,Y_test_pcr)




