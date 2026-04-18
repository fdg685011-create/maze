function [] = plot_spikebin(bin_spike_on,bin_spike_off,bin,step,stim,channelname,window_on,window_off,p)

    [time,trial,class,channel]=size(bin_spike_on);
    %%根据类别的平均值画出直方图
    t_bin_spike_on = f_binspike(bin_spike_on,bin,step);
    t_bin_spike_off = f_binspike(bin_spike_off,bin,step);
    %计算平均和标准差
    mean_on = squeeze(mean(t_bin_spike_on,2));
    mean_off = squeeze(mean(t_bin_spike_off,2));
    maxmean=max(max(max(max(mean_on))),max(max(max(mean_off)))); %求取最大神经元响应，用于画图的上限
    
    for i = 1:channel
        figure
        sgtitle(strcat('-ch',num2str(channelname(i))));
        for j = 1:class
            subplot(class,1,j)
            temp_mean=[mean_on(:,j,i);mean_off(:,j,i)];
            hold on
            bar(1:size(temp_mean,1),temp_mean,0.6,'FaceColor',[.5 .5 .5],'EdgeColor',[.5 .5 .5],'LineWidth',1);
            plot(1:size(temp_mean,1),temp_mean,'k')
            plot([size(temp_mean,1)/2+1,size(temp_mean,1)/2+1],[0,ceil(maxmean/30)*30],'r','LineWidth',1)
            rectangle('Position',[ceil(window_on(1)/step),0,ceil((window_on(2)-window_on(1))/step),ceil(maxmean/30)*30],'FaceColor',[0.5 0 0 0.1],...
            'EdgeColor',[0.5 0 0 0.1],'LineWidth',0.2);
            rectangle('Position',[ceil(window_off(1)/step)+1,0,ceil((window_off(2)-window_off(1))/step),ceil(maxmean/30)*30],'FaceColor',[0 0 0.5 0.1],...
            'EdgeColor',[0 0 0.5 0.1],'LineWidth',0.2);
            set(gca, 'xTick', 200/step:200/step:size(temp_mean,1));
            set(gca,'XTickLabel',(200/step:200/step:size(temp_mean,1))*step);
            ylim([0,ceil(maxmean/30)*30])
            p_=p(i,j);
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
            ylabel(strcat(stim.ClassName(j),'[',num2str(stim.TrialTime),str,']'));
            grid on
        end
        xlabel('Time[ms]');
    end
end

