function [lfp6080, lfp3045, lfp510] = process_lfp(rawlfp, downfs)
% fs: 采样率 (1000Hz)
    fband = 1:80; % 频率范围
    lfp_stft=zeros([length(fband),size(rawlfp,1),size(rawlfp,2)]);
    channel=size(rawlfp,2);
    for ch = 1:channel
        raw_lfp_ch=rawlfp(:,ch);
        window_length = 128; % 窗长
        step = 1; % 步长
        % 进行短时傅里叶变换 (STFT)
        [s,f,t] = spectrogram(raw_lfp_ch,window_length,window_length-step,fband,downfs); 
        s = abs(s*2/window_length*2);
        endnm=size(rawlfp,1)-size(s,2)-window_length/2;         %自适应长度
        lfp_stft(:,window_length/2+1:end-endnm,ch)=s;

        temp=repmat(lfp_stft(:,window_length/2+1,ch),1,window_length/2);
        lfp_stft(:,1:window_length/2,ch)=temp;
        temp=repmat(lfp_stft(:,end-endnm,ch),1,endnm);
        lfp_stft(:,end-endnm+1:end,ch)=temp;                    %将首尾的0填充

    end
    % 提取不同频带的平均能量
    lfp3045=squeeze(mean(lfp_stft(30:45,:,:)));
    lfp6080=squeeze(mean(lfp_stft(60:80,:,:)));
    lfp510=squeeze(mean(lfp_stft(5:10,:,:)));

    amp_thre=3;                                 % 限幅用阈值
    lfp3045 = f_limitamp(lfp3045,amp_thre);
    lfp6080 = f_limitamp(lfp6080,amp_thre);
    lfp510 = f_limitamp(lfp510,amp_thre);

    % lfp3045=f_norm(lfp3045);                                    %数据归一化
    % lfp6080=f_norm(lfp6080);                                    %数据归一化
    % lfp510=f_norm(lfp510);                                    %数据归一化


end
