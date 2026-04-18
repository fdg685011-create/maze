function [] = plot_powerspectrum(bin_lfp_on,bin_lfp_off,DownsampFs,frequencies,channel)
    %输入[ms,trial,class,channel]
    power_spectrum_on = f_calpowerspectrum(bin_lfp_on,DownsampFs,frequencies);
    power_spectrum_off = f_calpowerspectrum(bin_lfp_off,DownsampFs,frequencies);
    %计算平均和标准差
    mean_on = squeeze(mean(power_spectrum_on,2));
    mean_off = squeeze(mean(power_spectrum_off,2)); 
    [time,trial,channel_]=size(power_spectrum_on);
    for i = 1:channel_
        figure('units','normalized','outerposition',[0 0 1 1])
%         sgtitle(strcat('-ch',num2str(channel(i))));
        maxmean=max(max(max(power_spectrum_on(:,:,i))),max(max(power_spectrum_off(:,:,i))));
            for k = 1:trial
                hold on
                subplot(1,2,1);
                plot(frequencies, power_spectrum_off(:,k,i),'Color',[.5 .5 .5]);% 绘制功率谱
            end
%             subplot(trial+1,1,trial+1)
            plot(frequencies, mean_off(:,i),'Color',[.5 0 0]);% 绘制功率谱
%             plot([size(power_spectrum_on,1)+1,size(power_spectrum_on,1)+1],[0,ceil(maxmean/10)*10],'r','LineWidth',1)
            xlabel('频率（Hz）');
            ylabel('功率谱密度');
            title(strcat('ch',num2str(channel(i)),'打标前信号功率谱'));
            for k = 1:trial
                hold on
                subplot(1,2,2);
                plot(frequencies,power_spectrum_on(:,k,i),'Color',[.5 .5 .5]);
            end
            plot(frequencies,mean_on(:,i),'Color',[.5 0 0]);
%             plot([size(power_spectrum_on,1)+1,size(power_spectrum_on,1)+1],[0,ceil(maxmean/10)*10],'r','LineWidth',1)
            xlabel('频率（Hz）');
            ylabel('功率谱密度');
            title(strcat('ch',num2str(channel(i)),'打标后信号功率谱'));
       end
   end


