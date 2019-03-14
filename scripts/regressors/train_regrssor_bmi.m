function param =  train_regrssor(train_in, train_out,k, width)
% obtain spread of the data
muMin = min(train_in);
muMax = max(train_in);
dimensions = size(train_in,2);
% number of basis functions along for all the dimensions
NumBasisFns = k^dimensions;

%mu = zeros(NumBasisFnsx*NumBasisFnsy, 2); % initialise means
s = (muMax - muMin)./(width); % controls bf spread

[idx, mu] = kmeans(train_in, NumBasisFns);

% calculate Theta
numBasisFncs = length(mu)+1;

%multivariate gaussian
Cov = cov(train_in);
%Cov = diag(s);
phis = zeros(length(train_in), numBasisFncs);

for ii = 1 : length(train_in)
    % add 1 more bf train_in order to include the offset
    for jj = 1 : numBasisFncs
        if jj == 1
            phis(ii,jj) = 1; % 1st bf is just an offset
        else
            phis(ii,jj) = multivar_gauss(train_in(ii,:),mu(jj-1,:),Cov);
            %  multivariate
        end
    end
end
Thetas = phis;

% pinv() gives the Moore-Penrose pseudo-inverse
param.w = pinv(Thetas)*train_out;
param.mu = mu;
param.s = Cov;%s;

end

function phi = multivar_gauss(x,mu,covar)
phi = exp(-0.5*(x-mu)*covar^-1*(x-mu)');
end
