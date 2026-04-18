function [] = plot_raster(data,stim,channel,window_on,window_off,p)
    %%输入数据格式：ms×class×channel，画Raster图
    trial=size(data,2);
    class=size(data,3);
    timelength=size(data,1)/2;
    for i = 1:size(data,4)  %通道
        figure
        sgtitle(strcat('-ch',num2str(channel(i))));
        for j = 1:class
            temp=data(:,:,j,i);
            subplot(class,1,j)
            imagesc(~temp');%%每帧刺激后10ms内的spike
            hold on
            plot([timelength,timelength],[0,trial],'r','LineWidth',1)  %中间红线
            rectangle('Position',[window_on(1),0,window_on(2)-window_on(1),trial],'FaceColor',[0.5 0 0 0.1],...
            'EdgeColor',[0.5 0 0 0.1],'LineWidth',0.2);
            rectangle('Position',[window_off(1),0,window_off(2)-window_off(1),trial],'FaceColor',[0 0 0.5 0.1],...
            'EdgeColor',[0 0 0.5 0.1],'LineWidth',0.2);
            colormap('gray');
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
            grid on
        end
        xlabel('Time[ms]');
    end
end

