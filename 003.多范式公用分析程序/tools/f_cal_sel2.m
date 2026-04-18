function [sel_1,sel_2,sel_n] = f_cal_sel2(feat1,feat2,channel_sel,binedgs,titlename)
    %计算feat1和feat2的选择性
    figure('units','normalized','outerposition',[0 0 1 1])     
    sgtitle('Selectivity Index')
    sel_1=[];
    sel_2=[];
    sel_n=[];
    for ch = 1:length(channel_sel)
        data_1=feat1(:,ch);
        data_2=feat2(:,ch);
        %剔除异常值
        data_1=data_1(data_1<mean(data_1)+4*std(data_1));
        data_2=data_2(data_2<mean(data_1)+4*std(data_2));
        %直方图
        edges=floor(min([data_1;data_2])) :ceil((ceil(max([data_1;data_2]))-floor(min([data_1;data_2])))/(binedgs+1)) :ceil(max([data_1;data_2]));
        hist_1=histcounts(data_1,edges,'Normalization','probability');
        hist_2=histcounts(data_2,edges,'Normalization','probability');
        %计算选择性
        s1=sum(max([hist_1;hist_2]))-sum(hist_2);
        s2=sum(max([hist_1;hist_2]))-sum(hist_1);
        sn=sum(max([hist_1;hist_2]))-s1-s2;
        sel_1(ch)=round(s1/(s1+sn),2);
        sel_2(ch)=round(s2/(s2+sn),2);
        sel_n(ch)=round((s1+s2)/(s1+s2+sn),2);
        %画图
        subplot(4,ceil(length(channel_sel)/4),ch)
        histogram(data_1,edges,'Normalization','probability');
        hold on
        histogram(data_2,edges,'Normalization','probability');
        legend(strcat(titlename{1},':',num2str(sel_1(ch))),strcat(titlename{2},':',num2str(sel_2(ch))))
        ylabel('概率（%）')
        xlabel('发放率（spikes/s）')
        title(strcat('ch-',num2str(channel_sel(ch)),'；S-',num2str(sel_n(ch))))
%         set(gca,'FontName','Times New Rome','FontSize',13); % 设置整体的字号大小
    end
    
end

