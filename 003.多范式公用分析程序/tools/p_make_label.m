function [] = p_make_label(data,label,ref,channel,fs,bin)
%P_MAKE_LABEL 此处显示有关此函数的摘要
%   此处显示详细说明
    figure('units','normalized','outerposition',[0 0 1 1])                      % 全屏显示
    t=tiledlayout(length(channel),1,'TileSpacing','none','padding','none');   % 三个参数：'normal', 'compact', 'none'
    title(t,'Make Label','FontSize',20)
    color_orig=[0.5 0 0 0.1;0 0.5 0 0.1];
    for ch = 1:length(channel)
        refs=ref;
        label_ch = label(:,ch);
        label_ch(1)=0;
        label_ch(end)=0;
        label_ch(label_ch<2)=0;
        label_ch(label_ch>0)=1;
        refs_t=[];
        dif=diff(label_ch)';
        refs_t(:,1)=find(dif==1)/fs;
        refs_t(:,2)=find(dif==-1)/fs;

        data_ch = data(:,ch);
        data_ch = f_sl_binsl(data_ch,bin,1);

        nexttile;
        plot(data_ch)
        hold on 
        for r = 1:length(refs)
             rectangle('Position',[refs(r,1)*fs,0,(refs(r,2)-refs(r,1))*fs,max(data_ch)],'FaceColor',color_orig(1,:),...
                'EdgeColor',color_orig(1,1:3),'LineWidth',0.2);
%              plot([refs(r,4)*fs,refs(r,4)*fs],[0,max(data_ch)],'b','LineWidth',1)  
        end
        for r = 1:length(refs_t)
             rectangle('Position',[refs_t(r,1)*fs,0,(refs_t(r,2)-refs_t(r,1))*fs,max(data_ch)],'FaceColor',color_orig(2,:),...
                'EdgeColor',color_orig(2,1:3),'LineWidth',0.2);
        end
        if ch < length(channel)
            set(gca,'XTickLabel',[]);                       % 去掉子图的x轴刻度
        end
        xlim([0,size(data_ch,1)])
        ylabel(strcat('ch-',num2str(channel(ch))))
        set(gca,'FontName','Times New Rome','FontSize',13); % 设置整体的字号大小
        set(gca,'TickLength',[0.0005,0.0035]);
    end
    xlabel('时间（ms）') 
end

