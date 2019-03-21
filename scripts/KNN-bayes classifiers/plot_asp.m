%% plot function for ASP
function []= plot_asp(t,x,tit,tlab,xlab,varargin)
% just settings by setting t and x both equal to zero, default font size 18
if isempty(varargin)
    ft_sz = 18;
else
    ft_sz=varargin{1};
end

try
    thick = varargin{2};
    set(findall(gcf,'type','line'),'LineWidth',thick)
catch
    thick = 2;
end
if x~=0
    if t == 0
        plot(x,'Linewidth',thick)
    else
        plot(t,x,'Linewidth',thick)
    end
end
title (tit);
xlabel(tlab)
ylabel(xlab)
set(findall(gcf,'type','text'),'FontSize',ft_sz)
set(gca,'FontSize',ft_sz)
grid on