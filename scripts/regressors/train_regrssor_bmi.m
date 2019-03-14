function param =  train_regrssor(train_in, train_out,k, method, width)
%method = 1 is grid spaced functions, =2 is kmeans spaced
% obtain spread of the data
muMin = min(train_in);
muMax = max(train_in);
% number of basis functions along x and y axis
NumBasisFnsx = k; % number of bfs train_in x direction
NumBasisFnsy = k; % number of bfs train_in y direction

mu = zeros(NumBasisFnsx*NumBasisFnsy, 2); % initialise means
s = (muMax - muMin)./(width); % controls bf spread
if method == 1
    % equally spcaed grid
    for ii = 1 : NumBasisFnsx
        for jj = 1 : NumBasisFnsy
            % stepping train_in x direction
            mu((ii-1)*NumBasisFnsx+jj, 1) = muMin(1,1) + (ii-1)*...
                (muMax(1,1)-muMin(1,1))/(NumBasisFnsx-1);
            % stepping train_in y direction
            mu((ii-1)*NumBasisFnsy+jj, 2) = muMin(1,2) + (jj-1)*...
                (muMax(1,2)-muMin(1,2))/(NumBasisFnsy-1);
            % % or train_in one go:
            % mu((i-1)*NumBasisFnsy+j,:) = muMin + ...
            % (ii-1)*(muMax-muMin)/(NumBasisFnsx-1).*[1 0] +...
            % (jj-1)*(muMax-muMin)/(NumBasisFnsy-1).*[0 1];
        end
    end
elseif method == 2
    
    % kmeans space gaussians
    [idx,C] = kmeans(train_in,NumBasisFnsx*NumBasisFnsy);
    
    % figure
    % plot(mu(:,2),mu(:,1),'+');
    % hold on
    % plot(C(:,2),C(:,1),'o');
    % ylabel('latitude [deg]'); xlabel('longitude [deg]');
    % legend('Equally spaced centres','Kmeasn centers');
    mu = C;
    % c's are better than mus as they are concentrated where more data is
end

% calculate Theta
numBasisFncs = length(mu)+1;
% initialise the matrix of basis functions
% Thetas = zeros(length(train_in), numBasisFncs);
% for ii = 1 : length(train_in)
%     % add 1 more bf train_in order to include the offset
%     for jj = 1 : numBasisFncs
%         if jj == 1
%             Thetas(ii,jj) = 1; % 1st bf is just an offset
%         else
%             Thetas(ii,jj) = exp( -( (((train_in(ii,1)-mu(jj-1,1))^2)/...
%                 (2*(s(1,1)^2))) + ...
%                 (((train_in(ii,2)-mu(jj-1,2))^2)/...
%                 (2*(s(1,2)^2))) ) ); % Gaussian 2D
%         end
%     end
% end

%multivariate gaussian, check that for 2d case it is the same as 2D gaussian
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
