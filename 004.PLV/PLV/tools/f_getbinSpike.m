function [bin_spike,channel] = f_getbinSpike(PATHFile,spk_inter,commonmode)
    %%输出文件地址(只能读取文件中的第一个nev文件)，截取信号的区间。
    %%返回的spike bin化为1秒1000个点，每1ms只能有1个spike。
    %%返回bin_spike和对应的channel，bin_spike格式为[ms,trial,channel]。

    NevFile = dir(fullfile(PATHFile,'*.nev'));   %读取nev文件
    [SPIKEData, PathFile, PVCSRand, refs] = getSpikeDatal(fullfile(PATHFile,NevFile.name));   
    channel = cell2mat(SPIKEData(4,:));	%通道，返回有spike信号的通道
    nchannel = length(channel);	%通道数量 
    bin_spike=zeros((spk_inter(2)-spk_inter(1))*1000,length(refs),nchannel);
    %bin_spike返回500*1600*16，刺激出现后500ms，1600个打标点，16个通道
    for id = 1:nchannel %%循环每一个有用的通道
        k = SPIKEData{4,id}; %%选择当前循环的通道
        spiketim = SPIKEData{1,channel==k}; %%选择spike的时间
        if  length(spiketim)/(refs(end)-refs(1))>0.01       %相当于一个筛选，选择平均发放率大于0.01的通道     
            for m = 1:size(refs,1) %%所有刺激帧数
                sk = spiketim(spiketim>refs(m)+spk_inter(1) & spiketim<refs(m)+spk_inter(2));	%spike时间在打标时间范围内的挑选出来   
                [bin_spike_temp mt] = binspikes(sk-refs(m),1000,spk_inter);  %1ms一个spike,返回spike的时序
                if isempty(bin_spike_temp)%%加这是为了防止有些通道没有spike
                   bin_spike_temp = 0;
                end
                bin_spike(:,m,id)=bin_spike_temp;
            end
        end
    end
    bin_spike(bin_spike>0)=1;  %1ms最多对应一个spike
    
    %%共模参考   
    if commonmode
        bin_spike=f_commonmode(bin_spike);
    end
end

