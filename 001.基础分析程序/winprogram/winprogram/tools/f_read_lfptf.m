function [data_lfp,f] = f_read_lfptf(data,channel,freq,fs,window,step)
%F_READ_LFPTF 使用STFT对每个通道进行时频分析
%   输入data，格式为：试次×通道
    for ch = 1:length(channel)
        data_ch = data(:,ch);
                [s,f,t] = spectrogram(data_ch,window,window-step,freq(1):freq(2),fs);  
                s=abs(s*2/window*2);
                data_lfp(:,:,ch)=s;
    end
end

