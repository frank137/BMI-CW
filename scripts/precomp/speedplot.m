function dposdt = speedplot(trial,movement,trial_index,plot_switch)
%% speed plot
%movement = 1;
for i = trial_index
    handpos = trial(i,movement).handPos; %pick spikes out of trial i for
    for a = 1:length(handpos)-1
        dposdt(:,a) = handpos(:,a+1)-handpos(:,a);
    end
    
%     subplot(2,1,1)
%     hold off
%     plot(handpos(1,:))
%     hold on
%     plot(handpos(2,:))
%     plot(handpos(3,:))
%     xlim([0 900])
%     legend('x','y','z')
%     title(['Movement ',num2str(movement),', Trial ',num2str(i)])
%     ylabel('Coordinate magnitude')
%     
%     subplot(2,1,2)
if plot_switch == 1
    hold off
    plot(dposdt(1,:))
    hold on
    plot(dposdt(2,:))
    plot(dposdt(3,:))
    xlim([0 900])
    legend('dxdt','dydt','dzdt')
    title(['Movement ',num2str(movement),', Trial ',num2str(i)])
    ylabel('Speed magnitude')

    
    pause(0.1)
    end
    
    
end

end

