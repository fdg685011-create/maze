function [S,F,T] = f_caltimefrequency_maze(bin_lfp_on,fscale,Fs,timefrequencyflag,summean)
    %输入[ms,trial,class,channel]，输出[f,ms,trial,class,channel]
    if strcmp(class(timefrequencyflag),'double')
        %%短时傅里叶变换时频分析
        window = timefrequencyflag;  %窗长。窗口越长时间分辨率越差，频率分辨率越好。
        hop=1;%每次平移的步长，最小为1。越小图像时间精度越好，但计算量大。
        [time,trial,channel_]=size(bin_lfp_on);
        S=zeros(length(fscale),time-window+1,trial,channel_);  %[f,time,trial,class,channel]
        for i = 1:channel_
            disp(i)
            for k = 1:trial
                [Stemp,F,T]=spectrogram(bin_lfp_on(:,k,i),window,window-hop,fscale,Fs);
                S(:,:,k,i)=abs(Stemp*2/window*2);
            end
        end
        T=T*Fs;
    else
        %%小波时频分析
        wavename=timefrequencyflag;
        totalscal=Fs/2;%尺度序列的长度，即scal的长度
        wcf=centfrq(wavename);%小波的中心频率
        cparam=2*wcf*totalscal;%为得到合适的尺度所求出的参数
        a=totalscal:-1:1;
        scal=cparam./a;
        F=scal2frq(scal,wavename,1/Fs);%将尺度转换为频率

        [time,trial,channel_]=size(bin_lfp_on);
        S=zeros(length(fscale),time,trial,channel_);  %[f,time,trial,class,channel]
        for i = 1:channel_
            disp(i)
            for k = 1:trial
                coefs=cwt(bin_lfp_on(:,k,i),scal,wavename);%得到小波系数
                Stemp=abs(coefs);
                S(:,:,k,i)=Stemp(length(fscale)+1:end,:);
            end
        end
        F=F(length(fscale)+1:end);
        T=1:time;
    end
    if summean
        common_mode_reference = mean(S, 2); 
        common_mode_reference=repmat(common_mode_reference,[1,size(S,2),1,1]);
        % 应用共模参考
        S = S - common_mode_reference;
    end
    
    % imagesc(T,F,S(:,:,1,1,1));
    % set(gca,'ydir','normal')
end

