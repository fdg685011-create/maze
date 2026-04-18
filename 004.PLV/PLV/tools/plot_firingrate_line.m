function [] = plot_firingrate_line(bin_spike_on,bin_spike_off,bin,step,stim,channelname,window_on,window_off,p)
    % 画每个试次的firingrate
    [time,trial,class,channel]=size(bin_spike_on);
    %%根据类别的平均值画出直方图
    t_bin_spike_on = f_binspike(bin_spike_on,bin,step);
    t_bin_spike_off = f_binspike(bin_spike_off,bin,step);
    %计算平均和标准差
    mean_on = squeeze(mean(t_bin_spike_on,2));
    mean_off = squeeze(mean(t_bin_spike_off,2)); 

    
    x = 1:size(t_bin_spike_on,1);
    for i = 1:channel
        maxmean=max(max(max(max(t_bin_spike_on(:,:,:,i)))),max(max(max(t_bin_spike_off(:,:,:,i)))));
        minmean=min(min(min(min(t_bin_spike_on(:,:,:,i)))),min(min(min(t_bin_spike_off(:,:,:,i)))));

        figure
        sgtitle(strcat('-ch',num2str(channelname(i))));
        for j = 1:class
            subplot(size(stim.ClassName,2),1,j)
            for k = 1:trial
                hold on
                y=t_bin_spike_on(:,k,j,i);
                y=smooth(x, y, 'lowess');
                plot(x,y,'Color',[.5 .5 .5]);
                y=t_bin_spike_off(:,k,j,i);
                y=smooth(x, y, 'lowess');
                plot(x+length(x),y,'Color',[.5 .5 .5]);
            end
            y=mean_on(:,j,i);
            y=smooth(x, y, 'lowess');
            plot(x,y,'Color',[.5 0 0]);
            y=mean_off(:,j,i);
            y=smooth(x, y, 'lowess');
            plot(x+length(x),y,'Color',[.5 0 0]);
            
            plot([size(t_bin_spike_on,1)+1,size(t_bin_spike_on,1)+1],[0,ceil(maxmean/30)*30],'r','LineWidth',1)
            rectangle('Position',[ceil(window_on(1)/step),0,ceil((window_on(2)-window_on(1))/step),ceil(maxmean/30)*30],'FaceColor',[0.5 0 0 0.1],...
            'EdgeColor',[0.5 0 0 0.1],'LineWidth',0.2);
            rectangle('Position',[ceil(window_off(1)/step)+1,0,ceil((window_off(2)-window_off(1))/step),ceil(maxmean/30)*30],'FaceColor',[0 0 0.5 0.1],...
            'EdgeColor',[0 0 0.5 0.1],'LineWidth',0.2);
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
            ylabel(strcat(stim.ClassName(j),'[',num2str(trial),str,']'));
            set(gca, 'xTick', 200/step:200/step:size(mean_on,1)*2);
            set(gca,'XTickLabel',(200/step:200/step:size(mean_on,1)*2)*step);
            ylim([floor(minmean/30)*30,max(ceil(maxmean/30)*30,30)])
            grid on
        end
        xlabel('Time[ms]');
    end
end

