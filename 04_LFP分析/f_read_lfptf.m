function [data_sz,f] = f_read_lfptf(data,channel,freq,fs,window,step,refs,before,after)
%F_READ_LFPTF 使用STFT对每个通道进行时频分析
%   输入data，格式为：试次×通道
data_sz={};
    for ch = 1:length(channel)
        disp(channel(ch))
        data_ch = data(:,ch);
            for ori = 0:1
            ref = refs(refs(:,3)==ori,:);
            for r = 1:size(ref,1)
                data_ch_ref=data_ch(round((ref(r,1)-before)*fs+1):round((ref(r,2)+after)*fs),:);
                [s,f,t] = spectrogram(data_ch_ref,window,window-step,freq(1):freq(2),fs);  
                s=abs(s*2/window*2);
                data_sz{r+ori*size((refs(refs(:,3)==0,:)),1),ch}=s;
            end
            end
    end
end

