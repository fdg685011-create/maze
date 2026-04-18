function [] = plot_heatmap(p_respones,stim,channel)
    %%绘制热力图
    figure
    mincolor = [191,54,12]; % 最大值颜色
    maxcolor = [255,255,255]; % 最小值颜色
    mymap = [linspace(mincolor(1)/255,maxcolor(1)/255,64)',...
             linspace(mincolor(2)/255,maxcolor(2)/255,64)',...
             linspace(mincolor(3)/255,maxcolor(3)/255,64)'];
    colormap(mymap)
    colorbar()
    xlabel_name = stim.ClassName;
    ylabel_name = stim.ClassName;
    for i=1:size(p_respones,1)
        subplot(ceil(size(p_respones,1)/4),4,i)
        
        hot_figure = heatmap(xlabel_name,ylabel_name,squeeze(p_respones(i,:,:)),'FontSize',10);
        hot_figure.GridVisible = 'off';
        % 设置坐标区名字与图的大标题
        title(strcat('-ch',num2str(channel(i))))
    end   
    
end

