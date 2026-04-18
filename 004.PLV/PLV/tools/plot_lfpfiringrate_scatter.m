function [] = plot_lfpfiringrate_scatter(bin_lfp_on,channelname,fband,window_on,window_off,p,st)
    
    bin_lfp_on  = squeeze(mean(bin_lfp_on,1));
    % 画每个试次的firingrate
    [time,trial,channel]=size(bin_lfp_on);
    %计算平均和标准差
    mean_on = squeeze(mean(bin_lfp_on,2));
    std_on = squeeze(std(bin_lfp_on,1,2));
    
    x=1:st:size(mean_on,1);
    mean_on=mean_on(1:st:size(mean_on,1),:);
    std_on=std_on(1:st:size(std_on,1),:);
    for i = 1:channel
        maxmean=max(max(mean_on(:,i)+std_on(:,i)));
        minmean=min(min(mean_on(:,i)-std_on(:,i)));
        figure
        sgtitle(strcat('-ch',num2str(channelname(i)),'  频带:',num2str(fband(1)),'-',num2str(fband(2)),'hz'));
            hold on 
            errorbar(x,mean_on(:,i),std_on(:,i),'-k')  %添加误差条
            scatter(x,mean_on(:,i),20,'k')  %'filled'
            rectangle('Position',[window_on(1),0,window_on(2)-window_on(1),ceil(maxmean/30)*30],'FaceColor',[0.5 0 0 0.1],...
            'EdgeColor',[0.5 0 0 0.1],'LineWidth',0.2);
            rectangle('Position',[window_off(1)+1,0,window_off(2)-window_off(1),ceil(maxmean/30)*30],'FaceColor',[0 0 0.5 0.1],...
            'EdgeColor',[0 0 0.5 0.1],'LineWidth',0.2);
            p_=p(1,i);
            if p_>0.05
                str=' ';
            end
            if isnan(p_)
                str=' ';
            end
            if p_<0.05
                str='*';
                if p_<0.01
                    str='**';
                end
            end
            ylabel(strcat('[',str,']'));
%             set(gca, 'xTick', 200/step:200/step:size(mean_on,1)*2);
%             set(gca,'XTickLabel',(200/step:200/step:size(mean_on,1)*2)*step);
            ylim([floor(minmean/30)*30,ceil(maxmean/30)*30])
            grid on
        xlabel('Time[ms]');
     end

end

