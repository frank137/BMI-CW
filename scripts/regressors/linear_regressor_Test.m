%% Luis linear regressor test
close all
x = [1:100];
x = x';
y = x+20.*rand(100,1);
plot(x,y,'+')
hold on
grid on
xlength = 100;
x_to_regress = [ones(100,1),x];


b = LuisLinearRegressor(y,x_to_regress);
c = regress(y,x_to_regress);


y_pred1 = b(1)+b(2)*x;
y_pred2 = c(1)+c(2)*x;
plot(x,y_pred1)
plot(x,y_pred2)

RSME1 = sqrt((sum(y-y_pred1).^2)/xlength)
RSME2 = sqrt((sum(y-y_pred2).^2)/xlength)

