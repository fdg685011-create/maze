function [] = plot_lfpshadederrorbar(bin_spike_on,sum_on,window_on,fband,stim,channel)
    
    bin_spike_on  = squeeze(mean(bin_spike_on,1));
    bin_spike_on=bin_spike_on(window_on(1):window_on(2),:,:,:);
    
        
    figure
    for i = 1:length(channel)
        subplot(ceil(length(channel)/4),4,i)
        temp=sum_on(:,:,i);
        mean_=mean(temp,1);
        [maxVal maxInd] = max(mean_);
        [minVal minInd] = min(mean_);
        
        plotdata_max=bin_spike_on(:,:,maxInd,i);
        plotdata_min=bin_spike_on(:,:,minInd,i); 
        
        plotdata_max_mean=mean(plotdata_max,2);
        plotdata_max_std=std(plotdata_max,1,2);
        plotdata_min_mean=mean(plotdata_min,2);
        plotdata_min_std=std(plotdata_min,1,2);
         
        hold on
        b1=plot(1:size(plotdata_max_mean,1),plotdata_max_mean,'r','DisplayName',string(stim.ClassName(maxInd)));
        b2=plot(1:size(plotdata_min_mean,1),plotdata_min_mean,'b','DisplayName',string(stim.ClassName(minInd)));
        shadedErrorBar(1:size(plotdata_max_mean,1),plotdata_max_mean,plotdata_max_std,'lineprops','-r')
        shadedErrorBar(1:size(plotdata_min_mean,1),plotdata_min_mean,plotdata_min_std,'lineprops','-b')
        
        title(strcat('-ch',num2str(channel(i)),'  Æµ´ø:',num2str(fband(1)),'-',num2str(fband(2)),'hz'));
        xlabel('Time[ms]');
        ylabel('LfpPower');
        hold off
        legend([b1,b2])
    end
    
end

