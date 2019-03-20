%% Test the test
% here we run the full test and plot RMSE for different parameters

for r = 1:98
    KNN_script_test
    RMS_all(r) = RMSE
    save test_test RMS_all
end
%%
figure
plot(RMS_all);
plot_asp(0,0,'Principal Componet Regression','Principal Components kept','RMSE',14,2)





