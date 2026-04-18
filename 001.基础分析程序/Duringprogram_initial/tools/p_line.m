function [] = p_line(data,channel,refs,titlename,fs)
%P_LINE 绘制多通道数据，线条图
%   输入：data，数据，格式为时间×通道
%   输入：channel，选择后的通道
%   输入：refs，打标数据，起始点、中止点、方向（两个方向）
%   输入：titlename，title显示的字符串
%   输入：fs，数据的采样频率
    figure('units','normalized','outerposition',[0 0 1 1])                      % 全屏显示
    t=tiledlayout(length(channel),1,'TileSpacing','none','padding','none');   % 三个参数：'normal', 'compact', 'none'
    title(t,titlename,'FontSize',20)
    color_orig=[0.5 0 0 0.1;0 0.5 0 0.1];
    for ch = 1:length(channel)
        nexttile;
        plot(data(:,ch),'LineWidth',1.3);
        hold on
        for r =1:length(refs)
%            plot([refs(r,1)*fs,refs(r,1)*fs],[min(data(:,ch)),max(data(:,ch))],color_orig{refs(r,3)+1},'LineWidth',1)  %中间红线
             rectangle('Position',[refs(r,1)*fs,min(data(:,ch)),(refs(r,2)-refs(r,1))*fs,max(data(:,ch))-min(data(:,ch))],'FaceColor',color_orig(refs(r,3)+1,:),...
                'EdgeColor',color_orig(refs(r,3)+1,1:3),'LineWidth',0.2);
        end
        if ch < length(channel)
            set(gca,'XTickLabel',[]);                       % 去掉子图的x轴刻度
        end
        xlim([0,size(data,1)])
        ylabel(strcat('ch-',num2str(channel(ch))))
        set(gca,'FontName','Times New Rome','FontSize',13); % 设置整体的字号大小
        set(gca,'TickLength',[0.0005,0.0035]);
    end
    xlabel('时间(ms)')
%     linkaxes(ax,'xy')                                       % x轴同步
end

