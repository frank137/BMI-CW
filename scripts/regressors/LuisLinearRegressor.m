function b = LuisLinearRegressor(y,X,option)
% this linear regressor takes as an input your feature space, concated to a
% vector of ones as the constant term which will give the bias or
% "y-intercept"
% we consider y and X given as column vector where time is in the rows

if option == 0
b = inv(X'*X)*X'*y;
else
    r = 18;
    [Ur,Sr,Vr] = svds(X,r);
    b = Vr/Sr*Ur'*y;
end

