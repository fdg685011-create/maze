function [] = p_spk_trial(sign_spk_raster,sign_spk_rate,channel,refs,inter,after,fs)
%P_SPK_RASTER 画每个试次的spike信号
%   输入sign_spk_raster：raster数据，0和1，格式为：时间×通道
%   输入sign_spk_rate：spike发放率，格式为：时间×通道
%   输入inter：打标前后再取inter秒
%   输入window：在图像中标注目标出现后和目标消失前的时间窗口
    maxtrial = max([sum(refs(:,3)),length(refs)-sum(refs(:,3))]);   % 两个方向的最大试次数
    maxtime = max(round((refs(:,2)-refs(:,1))*fs))+inter*2*fs;
    for ch = 1:length(channel)
        figure('units','normalized','outerposition',[0 0 1 1])      % 全屏显示
        sgtitle(strcat('ch-',num2str(channel(ch))),'fontsize',25)
        for ori = 0:1
            ref = refs(refs(:,3)==ori,:);
            spk_raster_trial = zeros(maxtime,length(ref));
            for r = 1:size(ref,1)
                subplot(maxtrial+1,2,r*2+ori+1)
%                 spk_rate_trial = sign_spk_rate(round((ref(r,1)-inter)*fs+1):round((ref(r,2)+inter)*fs),ch);
%                 raster_trial = sign_spk_raster(round((ref(r,1)-inter)*fs+1):round((ref(r,2)+inter)*fs),ch);
                 spk_rate_trial = sign_spk_rate(round((ref(r,1)-inter)*fs+1):round((ref(r,2)+after)*fs),ch);
                 raster_trial = sign_spk_raster(round((ref(r,1)-inter)*fs+1):round((ref(r,2)+after)*fs),ch);
%                 if ori==0
                spk_raster_trial(1:length(raster_trial),r) = raster_trial;
%                 else
%                     spk_raster_trial(end-length(raster_trial)+1:end,r) = raster_trial;
%                 end
                plot(spk_rate_trial,'LineWidth',1.2)
                hold on
                rectangle('Position',[inter*fs,0,(ref(r,2)-ref(r,1))*fs,max(spk_rate_trial)],'FaceColor',[0.5 0 0 0.1],...
                    'EdgeColor',[0.5 0 0 0.1],'LineWidth',0.2);     %标注发现并趋近目标的区间
%                 plot([(refs(r,4)-refs(r,1)+inter)*fs,(refs(r,4)-refs(r,1)+inter)*fs],[0,max(spk_rate_trial)],'b','LineWidth',1)  
                ylabel(strcat('试次-',num2str(r)))
                set(gca,'FontName','Times New Rome','FontSize',10);         % 设置整体的字号大小
                set(gca,'TickLength',[0.0005,0.0035]);
                set(gca,'xticklabel',get(gca,'xtick'));

            end
%             xlabel('时间（ms）')
%             subplot(maxtrial+1,2,ori+1)
%             yyaxis left
%             imagesc(~spk_raster_trial')
%             colormap('gray');
%             hold on
% %              rectangle('Position',[inter*fs,0,(ref(r,2)-ref(r,1))*fs,max(spk_rate_trial)+10],'FaceColor',[0.5 0 0 0.1],...
% %                     'EdgeColor',[0.5 0 0 0.1],'LineWidth',0.2);     %标注发现并趋近目标的区间
% %             if ori==0
% %                 rectangle('Position',[inter*fs,0,(window)*fs,max(spk_rate_trial)],'FaceColor',[0.5 0 0 0.1],...
% %                     'EdgeColor',[0.5 0 0 0.1],'LineWidth',0.2);     %标注目标出现的区间
%                 title(strcat('目标',num2str(ori)))
% %             else
% %                 rectangle('Position',[maxtime-2*inter*fs,0,(window)*fs,max(spk_rate_trial)],'FaceColor',[0 0 0.5 0.1],...
% %                     'EdgeColor',[0 0 0.5 0.1],'LineWidth',0.2);     %标注目标消失的区间 
% %                 title(strcat('方向-',num2str(ori)))
% %             end
%             ylabel(strcat('试次(',num2str(size(ref,1)),'次)'))
%             yyaxis right
%             spk_hist=f_sl_binsl(spk_raster_trial,200,1);
%             spk_mean=mean(spk_hist,2);
%             spk_mean=smooth(1:length(spk_mean), spk_mean, 'lowess');
%             plot(spk_mean,'Color',[0.5 0 0 0.2],'LineWidth',2);
%             ylabel(strcat('发放率'))
%             set(gca,'FontName','Times New Rome','FontSize',10);         % 设置整体的字号大小
%             set(gca,'TickLength',[0.0005,0.0035]);
%             set(gca,'xticklabel',get(gca,'xtick'));
        end
    end
end

