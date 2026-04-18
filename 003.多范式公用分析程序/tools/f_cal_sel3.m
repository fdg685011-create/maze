function [sel_1,sel_2,sel_3,sel_n] = f_cal_sel3(feat1,feat2,feat3,channel_sel,binedgs,titlename)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
    figure('units','normalized','outerposition',[0 0 1 1])     
    sgtitle('Selectivity Index')
    %计算选择性
    sel_1=[];
    sel_2=[];
    sel_3=[];
    sel_n=[];
    for ch = 1:length(channel_sel)
        data_1=feat1(:,ch);
        data_2=feat2(:,ch);
        data_3=feat3(:,ch);
        %剔除异常值
        data_1=data_1(data_1<mean(data_1)+4*std(data_1));
        data_2=data_2(data_2<mean(data_1)+4*std(data_2));
        data_3=data_3(data_3<mean(data_3)+4*std(data_3));
        %直方图
        edges=floor(min([data_1;data_2;data_3])) :ceil((ceil(max([data_1;data_2;data_3]))-...
            floor(min([data_1;data_2;data_3])))/(binedgs+1)) :ceil(max([data_1;data_2;data_3]));
        hist_1=histcounts(data_1,edges,'Normalization','probability');
        hist_2=histcounts(data_2,edges,'Normalization','probability');
        hist_3=histcounts(data_3,edges,'Normalization','probability');
        %计算选择性
        s1=sum(max([hist_1;hist_2;hist_3]))-sum(max([hist_2;hist_3]));
        s2=sum(max([hist_1;hist_2;hist_3]))-sum(max([hist_1;hist_3]));
        s3=sum(max([hist_1;hist_2;hist_3]))-sum(max([hist_1;hist_2]));
        sn=sum(max([hist_1;hist_2;hist_3]))-s1-s2-s3;
        sel_1(ch)=round(s1/sum(hist_1),2);
        sel_2(ch)=round(s2/sum(hist_2),2);
        sel_3(ch)=round(s3/sum(hist_3),2);
        sel_n(ch)=round((s1+s2+s3)/(s1+s2+s3+sn),2);
        %画箱线图
        subplot(4,ceil(length(channel_sel)/4),ch)
        x = [data_1; data_2; data_3];
        g1 = repmat({strcat(titlename{1},'(',num2str(sel_1(ch)),')')},length(data_1),1);
        g2 = repmat({strcat(titlename{2},'(',num2str(sel_2(ch)),')')},length(data_2),1);
        g3 = repmat({strcat(titlename{3},'(',num2str(sel_3(ch)),')')},length(data_3),1);
        g = [g1; g2; g3];
        boxplot(x,g)
        ylabel('发放率(spikes/s)')
        title(strcat('ch-',num2str(channel_sel(ch)),'；S-',num2str(sel_n(ch))))
    end
end

