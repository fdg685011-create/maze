function [] = plot_firingrate_scatter(bin_spike_on,bin_spike_off,bin,step,stim,channelname,window_on,window_off,p)
    %%以点和误差棒的形式画出响应曲线
    % 画每个试次的firingrate
    [time,trial,class,channel]=size(bin_spike_on);
    %%根据类别的平均值画出直方图
    t_bin_spike_on = f_binspike(bin_spike_on,bin,step);
    t_bin_spike_off = f_binspike(bin_spike_off,bin,step);
    %计算平均和标准差
    mean_on = squeeze(mean(t_bin_spike_on,2));
    mean_off = squeeze(mean(t_bin_spike_off,2)); 
    std_on = squeeze(std(t_bin_spike_on,1,2));
    std_off = squeeze(std(t_bin_spike_off,1,2)); 

    
    x=1:size(mean_on,1);
    for i = 1:channel
        maxmean=max(max(max(mean_on(:,:,i)+std_on(:,:,i))),max(max(mean_off(:,:,i)+std_off(:,:,i))));
        minmean=min(min(min(mean_on(:,:,i)-std_on(:,:,i))),min(min(mean_off(:,:,i)-std_off(:,:,i))));
        figure
        sgtitle(strcat('-ch',num2str(channelname(i))));
        for j = 1:class
            subplot(class,1,j)
            hold on 
            errorbar(x,mean_on(:,j,i),std_on(:,j,i),'-k')  %添加误差条
            scatter(x,mean_on(:,j,i),20,'k')  %'filled'
            errorbar(x+length(x),mean_off(:,j,i),std_off(:,j,i),'-k')  %添加误差条
            scatter(x+length(x),mean_off(:,j,i),20,'k')  %'filled'
            plot([size(mean_on,1)+1,size(mean_on,1)+1],[0,ceil(maxmean/30)*30],'r','LineWidth',1)
            rectangle('Position',[ceil(window_on(1)/step),0,ceil((window_on(2)-window_on(1))/step),ceil(maxmean/30)*30],'FaceColor',[0.5 0 0 0.1],...
            'EdgeColor',[0.5 0 0 0.1],'LineWidth',0.2);
%             rectangle('Position',[ceil(window_off(1)/step)+size(x,2)+1,0,ceil((window_off(2)-window_off(1))/step),ceil(maxmean/30)*30],'FaceColor',[0 0 0.5 0.1],...
%             'EdgeColor',[0 0 0.5 0.1],'LineWidth',0.2);
            rectangle('Position',[ceil(window_off(1)/step)+1,0,ceil((window_off(2)-window_off(1))/step),ceil(maxmean/30)*30],'FaceColor',[0 0 0.5 0.1],...
            'EdgeColor',[0 0 0.5 0.1],'LineWidth',0.2);
            ylim([floor(minmean/30)*30,max(ceil(maxmean/30)*30,30)])
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
            grid on
        end
        xlabel('Time[ms]');
    end
end

