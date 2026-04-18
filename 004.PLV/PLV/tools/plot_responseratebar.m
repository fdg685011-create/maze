function [p_respones] = plot_responseratebar(respones_on,p,ClassName,channel,ylab,fband_ks)

    respones_on_mean=squeeze(mean(respones_on,1));
    respones_on_std=squeeze(std(respones_on,1));
    max_=max(max(respones_on_mean+respones_on_std));
    min_=min(min(respones_on_mean-respones_on_std));
    figure('units','normalized','outerposition',[0 0 1 1])
     sgtitle('统计类别间的显著性差异');
    x=1:size(respones_on_mean,1);
    for i = 1:size(respones_on_mean,2)
        subplot(ceil(size(respones_on_mean,2)/4),4,i)
%         respones_on_mean(:,i);
        hold on
        bar(x,respones_on_mean(:,i),0.6,'FaceColor',[.75 .75 .75],'EdgeColor','k','LineWidth',1);
        errorbar(x,respones_on_mean(:,i),respones_on_std(:,i),'LineStyle', 'none','Color','k')  %添加误差条
        for j = 1:size(respones_on_mean,1)
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
%             text(x(j), respones_on_mean(j,i)+respones_on_std(j,i)+(max_-min_)*0.03,str,'HorizontalAlignment','center','FontSize',12) 
%             text(x(j), respones_on_mean(j,i)+respones_on_std(j,i)+(max_-min_)*0.06,num2str(roundn(sensitivity(j,i),-2)),'HorizontalAlignment','center','FontSize',7) 
        end
        plot([x(j-1),x(j)],[max(respones_on_mean(1,i)+respones_on_std(j,i)+(max_-min_)*0.06,respones_on_mean(2,i)+respones_on_std(j,i)+(max_-min_)*0.06),max(respones_on_mean(1,i)+respones_on_std(j,i)+(max_-min_)*0.06,respones_on_mean(2,i)+respones_on_std(j,i)+(max_-min_)*0.06)],'-k', 'LineWidth',1);
        plot([x(j-1),x(j-1)],[max(respones_on_mean(1,i)+respones_on_std(j,i)+(max_-min_)*0.06,respones_on_mean(2,i)+respones_on_std(j,i)+(max_-min_)*0.06),max(respones_on_mean(1,i)+respones_on_std(j,i)+(max_-min_)*0.06,respones_on_mean(2,i)+respones_on_std(j,i)+(max_-min_)*0.06)-20],'-k', 'LineWidth',1)
        plot([x(j),x(j)],[max(respones_on_mean(1,i)+respones_on_std(j,i)+(max_-min_)*0.06,respones_on_mean(2,i)+respones_on_std(j,i)+(max_-min_)*0.06),max(respones_on_mean(1,i)+respones_on_std(j,i)+(max_-min_)*0.06,respones_on_mean(2,i)+respones_on_std(j,i)+(max_-min_)*0.06)-20],'-k', 'LineWidth',1)
        text((x(j)+x(j-1))/2, max(respones_on_mean(1,i)+respones_on_std(j,i)+(max_-min_)*0.06,respones_on_mean(2,i)+respones_on_std(j,i)+(max_-min_)*0.06)+4,str,'HorizontalAlignment','center','FontSize',12) 
        ylim([floor(min_/((max_-min_)*0.2))*((max_-min_)*0.2),ceil(max_/((max_-min_)*0.2))*((max_-min_)*0.2)])
        set(gca, 'xTick', x);
        set(gca,'XTickLabel',ClassName);
%         title(strcat('-ch',num2str(channel(i)),', S：',num2str(roundn(selectivity(i),-2))))
          title(strcat('-ch',num2str(channel(i))));
        ylabel(ylab);
    end
end

