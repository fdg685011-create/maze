function [SPIKEData] = f_Getspikefromorig(InitData,Fs,threshold,channel)  

%%从原始信号中提取spike信号
    [b2,a2] = butter(2,2*[250 5000]/Fs);  %%滤波得到高频信号
%     m       = Fs/2;%给定折叠频率 Fs/2
%     wp      = [1 999]/m;%陷波器通带频率归一化处理
%     ws      = [49 51]/m;%陷波器阻带频率归一化处理 ， 中心陷波频率为 50Hz
%     rp      = 3;%通带衰减取 3dB
%     rs      = 20;%阻带衰减取 20dB
%     [n,wn]  = buttord(wp,ws,rp,rs);% 确定巴特沃斯滤波器的最低阶数和截止频率
%     [b3,a3] = butter(n,wn,'stop');%确定巴特沃斯陷波器
    for k = 1:length(channel)
        s   = double(InitData(:,k));
%         s   = filtfilt(b3,a3,s);    
        demodata = filtfilt(b2,a2,s);  
        thre = -mean(abs(demodata))*threshold;              %以整段数据的平均值来定义阈值
        b        = find(diff(sign(diff(demodata)))>0)+1;    % 找波谷
        trw      = b(demodata(b)<=thre);                    %找超过阈值的波谷位置
        newid    = trw(trw>20 & trw<(length(demodata)-40)); %删除前段和后端的位置
        newid(find(diff(newid)<(0.0016*Fs))+1)=[];          %删除离得太近的波谷

        if length(newid)>0
            trw  = repmat(newid,1,round(0.0016*Fs))+repmat(-1*round(0.0016*Fs)*1/4+1:round(0.0016*Fs)*3/4,length(newid),1);%获得spk采样点
        else
            trw  = [];
        end
        waveform = demodata(trw); % 获得spk

        SPIKEData{1,k} = newid/Fs;% 获得spk发放时刻，单位为s
        SPIKEData{2,k} = waveform;
        SPIKEData{3,k} = thre;
        SPIKEData{4,k} = channel(k);

    end
end

