function [] = plot_lfpsumtrial(sumtrials_on,F__,T,fband,channel,colornorm)
    sumtrials_on  = squeeze(mean(sumtrials_on,3));
    [f,ms,channel_]=size(sumtrials_on);
    figure('units','normalized','outerposition',[0 0 1 1])
    for i = 1:channel_/2
        minpower=min(min(sumtrials_on(:,:,i)));
        maxpower=max(max(sumtrials_on(:,:,i)));
        subplot(2,channel_/2/2,i)
        sgtitle(strcat('-ch',num2str(channel(1)),'-',num2str(channel(channel_/2)),'  频带:',num2str(fband(1)),'-',num2str(fband(2)),'hz'));
            temp = sumtrials_on(:,:,i);
            imagesc(T,F__,temp);
            if colornorm
                caxis([minpower,maxpower]);
            end
            ymin=min(F__);
            ymax=max(F__);
%             set(gca,'ylim',[ymin,ymax])
            set(gca,'YDir','normal')
            colorbar;
            xlim([T(1),T(end)])
            xlabel('时间（ms）')
            ylabel('频率（hz）')     
            title(strcat('通道',num2str(i)))
    end
    figure('units','normalized','outerposition',[0 0 1 1])
    for i = channel_/2+1:channel_
        minpower=min(min(sumtrials_on(:,:,i)));
        maxpower=max(max(sumtrials_on(:,:,i)));
        subplot(2,channel_/2/2,i-channel_/2)
        sgtitle(strcat('-ch',num2str(channel_/2+1),'-',num2str(channel_),'  频带:',num2str(fband(1)),'-',num2str(fband(2)),'hz'));
            temp = sumtrials_on(:,:,i);
            imagesc(T,F__,temp);
            if colornorm
                caxis([minpower,maxpower]);
            end
            ymin=min(F__);
            ymax=max(F__);
%             set(gca,'ylim',[ymin,ymax])
            set(gca,'YDir','normal')
            colorbar;
            xlim([T(1),T(end)])
            xlabel('时间（ms）')
            ylabel('频率（hz）')      
            title(strcat('通道',num2str(i)))
    end
end

