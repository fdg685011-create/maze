function [] = p_spkthre(rawspk,spk_thre_min,spk_thre_max)


    figure('units','normalized','outerposition',[0 0.05 1 0.95]); 
    t = tiledlayout(8,1,'TileSpacing','Compact','Padding','Compact');
    sgtitle(strcat('Spike阈值设定区间（倍数）:',num2str(spk_thre_min),'→→→',num2str(spk_thre_max),'        选取数据时长-(10min)'))
    for ch = 1:8
        nexttile
        % data_ch=rawspk(1:min(10*60*1000,size(rawspk,1)),ch);
        data_ch=rawspk(5*60*1000+1:7*60*1000,ch);
        thre_min = -mean(abs(data_ch))*spk_thre_min;                 % 以整段数据的平均值来定义阈值
        thre_max = -mean(abs(data_ch))*spk_thre_max;                 % 以整段数据的平均值来定义阈值
        plot(data_ch)
        hold on
        plot([1,min(10*60*1000,size(rawspk,1))],[-thre_min,-thre_min],'r','LineWidth',2)    %绘制spike阈值下线（红色）
        plot([1,min(10*60*1000,size(rawspk,1))],[-thre_max,-thre_max],'g','LineWidth',2)    %绘制spike阈值上限（蓝色）


        ylim([thre_max-80,-thre_max+80])
    end
end

