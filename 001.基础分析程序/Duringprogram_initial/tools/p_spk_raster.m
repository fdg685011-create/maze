function [] = p_spk_raster(sign_spk_raster,channel,refs,inter,fs)
%P_SPK_RASTER 画每个试次的spike信号
%   输入sign_spk_raster：raster数据，0和1，格式为：时间×通道
%   输入sign_spk_rate：spike发放率，格式为：时间×通道
%   输入inter：打标前后再取inter秒
%   输入window：在图像中标注目标出现后和目标消失前的时间窗口
    maxtrial = max([sum(refs(:,3)),length(refs)-sum(refs(:,3))]);   % 两个方向的最大试次数
    maxtime = max(round((refs(:,2)-refs(:,1))*fs))+inter*2*fs;
    for ch = 1:length(channel)
        figure('units','normalized','outerposition',[0 0 1 1])      % 全屏显示
        sgtitle(strcat('ch-',num2str(channel(ch))),'fontsize',30)
        for ori = 0:1
            ref = refs(refs(:,3)==ori,:);
            spk_raster_trial = zeros(maxtime,length(ref));
            raster=[];
            for r = 1:size(ref,1)
                raster_trial = sign_spk_raster(round((ref(r,1)-inter)*fs+1):round((ref(r,2))*fs),ch);
%                 if ori==0
                spk_raster_trial(1:length(raster_trial),r) = raster_trial;
%                 else
%                     spk_raster_trial(end-length(raster_trial)+1:end,r) = raster_trial;
%                 end      
            end
                subplot(2,1,ori+1)
                imagesc(~spk_raster_trial');%%每帧刺激后10ms内的spike
                colormap('gray');
                hold on
                plot([inter*fs,inter*fs],length(ref),'r-','LineWidth',1)  %中间红线
                rectangle('Position',[inter*fs,0,max(ref(:,2)-ref(:,1))*fs,size(ref,1)+1],'FaceColor',[0.5 0 0 0.1],...
                    'EdgeColor',[0.5 0 0 0.1],'LineWidth',0.2);     %标注发现并趋近目标的区间
%                 plot([(refs(r,4)-refs(r,1)+inter)*fs,(refs(r,4)-refs(r,1)+inter)*fs],[0,max(spk_rate_trial)],'b','LineWidth',1)  
                ylabel(strcat('试次'))
                title(strcat('目标-',num2str(ori)),'fontsize',25)
                set(gca,'FontName','Times New Rome','FontSize',10);         % 设置整体的字号大小
                set(gca,'TickLength',[0.0005,0.0035]);
                set(gca,'xticklabel',get(gca,'xtick'));
        end
    end
end

