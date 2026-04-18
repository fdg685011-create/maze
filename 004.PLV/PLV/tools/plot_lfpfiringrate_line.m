function [I] = plot_lfpfiringrate_line(respones_on_,channelname,fband,window_on,window_off,p,ZUTD)
    respones_on_  = squeeze(mean(respones_on_,1));
    [time,trial,channel]=size(respones_on_);
    respones  = respones_on_(:,:,ZUTD);
    on=respones(window_on(1):window_on(2),:);
    off=respones(window_off(1):window_off(2),:);
    p=[];
    h=[];
    P=[];
    for v=1:trial
        onn=on(:,v);
        offf=off(:,v);
        [h_,p_,ci]=ttest2(onn,offf);
        p=[p,p_];
        h=[h,h_];
    end
    [B,I] = mink(p,3,'ComparisonMethod','auto');
    % 画每个试次的firingrate
    %计算平均和标准差
    mean_on = squeeze(mean(respones_on_,2));
    x = 1:size(respones_on_,1);
    for i = 1:4
        figure('units','normalized','outerposition',[0 0 1 1])
        sgtitle(strcat('-ch',num2str(channelname((i-1)*4+1)),'-',num2str(channelname(i*4)),'  频带:',num2str(fband(1)),'-',num2str(fband(2)),'hz'));
        for j = 1:channel/4
            iindex=(i-1)*4+j;
            subplot(2,2,j)
            maxmean=max(max(respones_on_(:,:,iindex)));
            minmean=min(min(respones_on_(:,:,iindex)));
            for k = 1:trial
                hold on
                y=respones_on_(:,k,iindex);
                y=smooth(x, y, 'lowess');
                plot(x,y,'Color',[.5 .5 .5]);
            end
            y=mean_on(:,iindex);
            y=smooth(x, y, 'lowess');
            plot(x,y,'Color',[.5 0 0]);
    %             xlim([T(1),T(end)*2])
            rectangle('Position',[window_on(1),0,window_on(2)-window_on(1),ceil(maxmean/30)*30],'FaceColor',[0.5 0 0 0.1],...
            'EdgeColor',[0.5 0 0 0.1],'LineWidth',0.2);
            rectangle('Position',[window_off(1)+1,0,window_off(2)-window_off(1),ceil(maxmean/30)*30],'FaceColor',[0 0 0.5 0.1],...
            'EdgeColor',[0 0 0.5 0.1],'LineWidth',0.2);
            p_=p(1,iindex);
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
            ylabel(strcat('power',str));
    %             set(gca, 'xTick', 200/step:200/step:size(mean_on,1)*2);
    %             set(gca,'XTickLabel',(200/step:200/step:size(mean_on,1)*2)*step);
            ylim([floor(minmean/30)*30,ceil(maxmean/30)*30])
            grid on
            xlabel('Time[ms]');
            title(strcat('通道',num2str(iindex)))
        end
    end
end

