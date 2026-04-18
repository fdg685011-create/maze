function [] = plot_lfpsumfreq(meanfreq_on,T,fband,channel)
    meanfreq_on  = squeeze(mean(meanfreq_on,1));
    [ms,trial,channel_]=size(meanfreq_on);
    
    figure('units','normalized','outerposition',[0 0 1 1])
    sgtitle(strcat('-ch',num2str(channel(1)),'-',num2str(channel(channel_/2)),'  频带:',num2str(fband(1)),'-',num2str(fband(2)),'hz'));
    for i = 1:channel_/2
        subplot(2,channel_/2/2,i)
        imagesc(T,1:trial,meanfreq_on(:,:,i)');
        set(gca,'ydir','normal')
        colorbar;
        xlim([T(1),T(end)])
        xlabel('时间（ms）')
        ylabel('试次（次）')
        title(strcat('通道',num2str(i)))
    end

    figure('units','normalized','outerposition',[0 0 1 1])
    sgtitle(strcat('-ch',num2str(channel(end/2+1)),'-',num2str(channel(end)),'  频带:',num2str(fband(1)),'-',num2str(fband(2)),'hz'));
    for i = channel_/2+1:channel_
        subplot(2,channel_/2/2,i-channel_/2)
        imagesc(T,1:trial,meanfreq_on(:,:,i)');
        set(gca,'ydir','normal')
        colorbar;
        xlim([T(1),T(end)])
        xlabel('时间（ms）')
        ylabel('试次（次）')
        title(strcat('通道',num2str(i)))
    end
end

