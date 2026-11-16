function [lfp_stft] = f_read_lfp(rawlfp,downfs,fband)
    lfp_stft=zeros([length(fband),size(rawlfp,1),size(rawlfp,2)]);
    channel=size(rawlfp,2);
    for ch = 1:channel
        disp(ch)
        raw_lfp_ch=rawlfp(:,ch);
        window_length = 128;                                    %128和512。窗长，窗口越长时间分辨率越差，频率分辨率越好。
        step=1;                                                 %每次平移的步长，最小为1。越小图像时间精度越好，但计算量大。
        [s,f,t] = spectrogram(raw_lfp_ch,window_length,window_length-step,fband,downfs); 
        s=abs(s*2/window_length*2);         
        endnm=size(rawlfp,1)-size(s,2)-window_length/2;         %自适应长度
        lfp_stft(:,window_length/2+1:end-endnm,ch)=s;

        temp=repmat(lfp_stft(:,window_length/2+1,ch),1,window_length/2);
        lfp_stft(:,1:window_length/2,ch)=temp;
        temp=repmat(lfp_stft(:,end-endnm,ch),1,endnm);
        lfp_stft(:,end-endnm+1:end,ch)=temp;                    %将首尾的0填充

    end
end

