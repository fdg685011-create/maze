function []=plot_shadederrorbar(bin_spike_on_,respones_on,window_on,bin,step,stim,channel)
    bin_spike_on=bin_spike_on_(window_on(1):window_on(2),:,:,:);
    binSpike=f_binspike(bin_spike_on,bin,step);
%     meann=f_calSpikerate(bin_spike_on_,window_on_sub);
%     t(1,:,:,:)=meann;
%     t=repmat(t,size(binSpike,1),1);
%     binSpike=binSpike-t;   %¼õÈ¥»ùÏß
    
    figure
    for i = 1:length(channel)
        subplot(ceil(length(channel)/4),4,i)
        temp=respones_on(:,:,i);
        mean_=mean(temp,1);
        [maxVal maxInd] = max(mean_);
        [minVal minInd] = min(mean_);
        
        plotdata_max=binSpike(:,:,maxInd,i);
        plotdata_min=binSpike(:,:,minInd,i); 
        
        plotdata_max_mean=mean(plotdata_max,2);
        plotdata_max_std=std(plotdata_max,1,2);
        plotdata_min_mean=mean(plotdata_min,2);
        plotdata_min_std=std(plotdata_min,1,2);
         
        hold on
        b1=plot(1:size(plotdata_max_mean,1),plotdata_max_mean,'r','DisplayName',string(stim.ClassName(maxInd)));
        b2=plot(1:size(plotdata_min_mean,1),plotdata_min_mean,'b','DisplayName',string(stim.ClassName(minInd)));
        shadedErrorBar(1:size(plotdata_max_mean,1),plotdata_max_mean,plotdata_max_std,'lineprops','-r')
        shadedErrorBar(1:size(plotdata_min_mean,1),plotdata_min_mean,plotdata_min_std,'lineprops','-b')
        
        set(gca, 'xTick', 50/step:50/step:size(plotdata_max_mean,1));
        set(gca,'XTickLabel',(50/step:50/step:size(plotdata_max_mean,1))*step);
        grid on
        title(strcat('-ch',num2str(channel(i))));
        xlabel('Time[ms]');
        ylabel('Firingrate[spikes/s]');
        hold off
        legend([b1,b2])
        
    end
    
    

end

