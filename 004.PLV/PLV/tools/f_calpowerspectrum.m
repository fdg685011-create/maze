function power_spectrum = f_calpowerspectrum(bin_lfp_on,DownsampFs,frequencies)
    [signal_length,trial,channel]=size(bin_lfp_on);
    power_spectrum=zeros(length(frequencies),trial,channel);
    for i = 1:channel
            for k = 1:trial
                time = (0:signal_length-1) / DownsampFs;
                % 计算频率向量
%                 frequencies = (0:signal_length/2) * DownsampFs / signal_length;
                signal=bin_lfp_on(:,k,i);
                fft_result = fft(signal);
                single_sided_spectrum = abs(fft_result / signal_length);
                % 取前一半数据（去除对称部分）
                single_sided_spectrum = single_sided_spectrum(1:signal_length/2+1);
                % 计算功率谱密度
                temp = (single_sided_spectrum).^2;
                power_spectrum(:,k,i) = temp(frequencies+1);
            end
        end
    end


