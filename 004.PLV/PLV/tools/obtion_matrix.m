function [bin_lfp,bin_spike] = obtion_matrix(allad,fs,Fs,refs,cha,befo_STI,befo_door,thre,commonmode,flag)
    %% 设置去噪滤波参数
    if strcmp(flag,'lfp') || strcmp(flag,'all')
        % [b1,a1] = butter(2,2*250/fs,'low');
        [b1,a1] = butter(2,[1 250]/(fs/2));  %带通滤波器，阶数为8，通带为1-250Hz，用来得到LFP信号
        m = fs/2;
        wp  = [1 999]/m;%陷波器通带频率归一化处理
        ws1 = [49 51]/m;%陷波器阻带频率归一化处理 ， 中心陷波频率为 50Hz
        ws2 = [99 101]/m;%陷波器阻带频率归一化处理 ， 中心陷波频率为 50Hz
        rp = 3;%通带衰减取 3dB
        rs = 20;%阻带衰减取 20dB
        [n,wn]  = buttord(wp,ws1,rp,rs);% 确定巴特沃斯滤波器的最低阶数和截止频率
        [n1,wn1]  = buttord(wp,ws2,rp,rs);% 确定巴特沃斯滤波器的最低阶数和截止频率
        [b3,a3] = butter(n,wn,'stop');%确定巴特沃斯陷波器
        [b4,a4] = butter(n1,wn1,'stop');%确定巴特沃斯陷波器
         %% 数据截断,构造bin_lfp
        bin_lfp = zeros((befo_STI+befo_door)*Fs,length(refs),length(cha));
        for r=1:length(refs)
            datalfp=[];
            dataspk=[];
            for k=1:length(cha)  
               s=allad{1,k}';
               datays = s(round((refs(r) - befo_STI)*fs) + 1:round((refs(r) + befo_door)*fs));
               ss= filtfilt(b3,a3,datays);
               ss= filtfilt(b4,a4,ss);
               lfpdata=resample(filtfilt(b1,a1,ss),Fs,fs); %降采样
        %        lfpdata=detrend(lfpdata);
               datalfp=[datalfp;lfpdata];
            end
            bin_lfp(:,r,:) = datalfp';
            if strcmp(flag,'lfp')
                bin_spike=[];
            end
        end
    end
    if strcmp(flag,'spike') || strcmp(flag,'all')
        InitData=cell2mat(allad);
        [SPIKEData] = f_Getspikefromorig(InitData,fs,thre,cha); 
        channel = cha;
        nchannel = length(channel);	%通道数量 
        bin_spike=zeros((befo_STI+befo_door)*1000,length(refs),nchannel);
        %bin_spike返回500*1600*16，刺激出现后500ms，1600个打标点，16个通道
        for id = 1:nchannel %%循环每一个有用的通道
            k = SPIKEData{4,id}; %%选择当前循环的通道
            spiketim = SPIKEData{1,channel==k}; %%选择spike的时间
            if  length(spiketim)/(refs(end)-refs(1))>0.01       %相当于一个筛选，选择平均发放率大于0.01的通道     
                for m = 1:size(refs,1) %%所有刺激帧数
                    sk = spiketim(spiketim>refs(m)-befo_STI & spiketim<refs(m)+befo_door);	%spike时间在打标时间范围内的挑选出来   
                    [bin_spike_temp mt] = binspikes(sk-refs(m),1000,[-befo_STI,befo_door]);  %1ms一个spike,返回spike的时序
                    if isempty(bin_spike_temp)%%加这是为了防止有些通道没有spike
                       bin_spike_temp = 0;
                    end
                    bin_spike(:,m,id)=bin_spike_temp;
                end
            end
        end
        bin_spike(bin_spike>0)=1;  %1ms最多对应一个spike
        if strcmp(flag,'spike')
            bin_lfp=[];
        end
        %%共模参考   
        if commonmode
            bin_spike=f_commonmode(bin_spike);
        end
    end
end

