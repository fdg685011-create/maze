function [outputArg1,outputArg2] = p_lfp_trial(data_sz,f,channel,refs,fband,fs,before,after)
%P_LFP_TRIAL 此处显示有关此函数的摘要
%   此处显示详细说明
%     for i=1:16
%         data_choose=data_freq(:,:,i);
%         data_mean=mean(data_choose,1);
%         data_freq(:,:,i)=data_choose-data_mean;
%     end

  

    f=f(f>=fband(1) & f<=fband(2));
    maxtrial = max([sum(refs(:,3)),length(refs)-sum(refs(:,3))]);   % 两个方向的最大试次数
    for ch = 1:length(channel)
        figure('units','normalized','outerposition',[0 0 1 1])      % 全屏显示
        sgtitle(strcat('ch-',num2str(channel(ch)),', fband：',num2str(fband(1)),'~',num2str(fband(2))),'fontsize',25)
        for ori = 0:1
            ref = refs(refs(:,3)==ori,:);
%             for r = 1+ori*size(refs(refs(:,3)==0,:),1):length(ref)+ori*size(refs(refs(:,3)==0,:),1)
            for r=1:size(ref,1)
                subplot(maxtrial,2,(r*2+ori-1))
                data_freq=data_sz{r+ori*size(refs(refs(:,3)==0,:),1),ch};
                lfp_freq_trial=data_freq(f(f>=fband(1) & f<=fband(2)),:);
%               lfp_freq_trial=mapminmax(lfp_freq_trial,0,1);
                yyaxis left
                imagesc(1:length(lfp_freq_trial),f,lfp_freq_trial)
                colorbar;

 

                hold on
                plot([before*fs,before*fs],fband,'r-','LineWidth',1)  %中间红线
%                 plot([(interp-0.5)*fs,(interp-0.5)*fs],fband,'r-','LineWidth',1)  %中间红线
                plot([(ref(r,2)-ref(r,1)+before)*fs,(ref(r,2)-ref(r,1)+before)*fs],fband,'r-','LineWidth',1)  %中间红线  
                ylabel('频率（hz）')
                set(gca,'FontName','Times New Rome','FontSize',10);         % 设置整体的字号大小
                yyaxis right
                lfp_freq_fband = mean(lfp_freq_trial,1);
                lfp_freq_fband=f_sl_binsl(lfp_freq_fband,200,1);
                plot(lfp_freq_fband,'Color','k','LineWidth',0.5)
                ylabel('lfp rate')
                set(gca,'FontName','Times New Rome','FontSize',10);    
                set(gca,'xticklabel',get(gca,'xtick'));% 设置整体的字号大小
            end
        end
    end
end

