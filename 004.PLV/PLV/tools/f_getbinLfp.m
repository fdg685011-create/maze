function [bin_lfp, channel] = f_getbinLfp(PATHFile,lfp_inter,DownsampFs,powerfrequency)

    %%返回bin_lfp和对应的channel，bin_spike格式为[ms,trial,channel]。
    NsxFile = dir(fullfile(PATHFile,'*.ns5'));   %读取nev文件
    NSX = openNSx('read',fullfile(PATHFile,NsxFile.name),'p:int16');%读入Nsx文件
    NevFile = dir(fullfile(PATHFile,'*.nev'));   %读取nev文件
    NEV=openNEV('read',fullfile(PATHFile,NevFile.name),'nosave','noparse');
    
    [LFPData,tsevs,svStrobed,Fs] = readplx(PATHFile);

    Refs = NEV.Data.SerialDigitalIO.TimeStamp;
    channel=NSX.MetaTags.ChannelID;
    %取打标后的数据
    [b1,a1] = butter(2,[1 250]/(Fs/2));  %带通滤波器，阶数为8，通带为1-250Hz，用来得到LFP信号
    if powerfrequency
        wp = [1 999]/(Fs/2);%陷波器通带频率归一化处理
        ws = [49 51]/(Fs/2);%陷波器阻带频率归一化处理 ， 中心陷波频率为 50Hz
        rp = 3;%通带衰减取 3dB
        rs = 20;%阻带衰减取 20dB
        [n,wn]  = buttord(wp,ws,rp,rs);% 确定巴特沃斯滤波器的最低阶数和截止频率
        [b3,a3] = butter(n,wn,'stop');%确定巴特沃斯陷波器
    end
    bin_lfp = zeros((lfp_inter(2)-lfp_inter(1))*DownsampFs,length(Refs),length(channel));
    for r = 1:length(Refs)
        datatrial=LFPData(:,Refs(r):Refs(r)+(lfp_inter(2)-lfp_inter(1))*Fs-1);   %截取试次
        for i = 1:length(channel)
            datachannel=double(datatrial(i,:));    %截取通道
            if powerfrequency
                datachannel = filter(b3,a3,datachannel);%% 去除工频
            end
            rfdata(i,:)=filtfilt(b1,a1,datachannel);      %滤波
        end   
%         rbdata = detrend(rfdata');                 %去基线
%         rbdata=rbdata';
        rsdata = resample(rfdata',DownsampFs,Fs);   %降采样
        bin_lfp(:,r,:) = rsdata;
%         hold on 
%         plot(1:30000,rfdata(1,:))
%         plot(1:30000,rbdata(1,:))
%         plot(1:30:30000,rsdata(:,1))
%         plot(1:30:30000,rrdata(:,1))
    end

end

