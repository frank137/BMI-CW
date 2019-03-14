function [ prediction ] = test_regressor(in, param)
mu = param.mu;
s = param.s;
% feed the testing data through Theta matrix
numBasisFncs = length(mu)+1;
Thetas = zeros(length(in), numBasisFncs); % matrix of basis functions
for ii = 1 : size(in,1)
    for jj = 1 : numBasisFncs 
        if jj == 1
            Thetas(ii,jj) = 1; 
        else
            Thetas(ii,jj) = multivar_gauss(in(ii,:),mu(jj-1,:),s);
%             Thetas(ii,jj) = exp( -( (((in(ii,1)-mu(jj-1,1))^2)/...
%                 (2*(s(1,1)^2))) + ...
%                 (((in(ii,2)-mu(jj-1,2))^2)/...
%                 (2*(s(1,2)^2))) ) ); % Gaussian 2D
        end
    end
end
prediction = Thetas * param.w;
end

function phi = multivar_gauss(x,mu,covar)
phi = exp(-0.5*(x-mu)*covar^-1*(x-mu)');
end