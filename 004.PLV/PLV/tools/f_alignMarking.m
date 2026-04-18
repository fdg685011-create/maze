function [bin_spike_on_,bin_spike_off_,channel] = f_alignMarking(bin_spike,channel,stim)
    %%打标信号与神经信号对应，对刺激无发放的通道筛除

    t_bin_spike_on = bin_spike(:,1:2:length(stim.StimulateOrder)*2,:);%%取出刺激帧
    t_bin_spike_off = bin_spike(:,2:2:length(stim.StimulateOrder)*2,:);%%取出休息帧
    bin_spike_on=[];  
    bin_spike_off=[];
    index=repmat([0],length(stim.ClassName),1);
    for i = 1 : length(stim.StimulateOrder)
        index(stim.StimulateOrder(i))=index(stim.StimulateOrder(i))+1;
        bin_spike_on(:,(stim.StimulateOrder(i)-1)*stim.TrialTime+index(stim.StimulateOrder(i)),:)=t_bin_spike_on(:,i,:);
        bin_spike_off(:,(stim.StimulateOrder(i)-1)*stim.TrialTime+index(stim.StimulateOrder(i)),:)=t_bin_spike_off(:,i,:);
    end
    %如果某一通道全为0，删除该通道
%     nindex=squeeze(~(sum(sum(bin_spike_on,1))==0)); %检索全为0的通道
%     channel=channel(nindex);  %筛选后的通道
%     bin_spike_on=bin_spike_on(:,:,nindex);
%     bin_spike_off=bin_spike_off(:,:,nindex);
    %更改为ms,trial,class,channel
    bin_spike_on_=[];
    bin_spike_off_=[];
    for i = 1:length(stim.ClassName)
        bin_spike_on_(:,:,i,:)=bin_spike_on(:,(i-1)*stim.TrialTime+1:i*stim.TrialTime,:);
        bin_spike_off_(:,:,i,:)=bin_spike_off(:,(i-1)*stim.TrialTime+1:i*stim.TrialTime,:);
    end
    
end

