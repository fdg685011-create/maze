function [sign_spk_raw,sign_lfp_raw] = f_rawdata_preprocessing(sign_raw,samfs, downfs, channel,Common)
%UNTITLED4 此处显示有关此函数的摘要
%   此处显示详细说明
% 使用FIR滤波器设计，替代IIR滤波器

% FIR滤波器设计参数
filterOrder = 100;  % 滤波器阶数
cutoffFreqLFP = [1 250];  % LFP信号的截止频率（Hz）
cutoffFreqSPK = [300 5000];  % Spike信号的截止频率（Hz）

% 设计FIR滤波器
b_lfp = fir1(filterOrder, cutoffFreqLFP/(samfs/2), 'bandpass');
b_spk = fir1(filterOrder, cutoffFreqSPK/(samfs/2), 'bandpass');

% 工频陷波滤波器设计
notch50 = fir1(filterOrder, [49 51]/(samfs/2), 'stop');
notch100 = fir1(filterOrder, [99 101]/(samfs/2), 'stop');
notch150 = fir1(filterOrder, [149 151]/(samfs/2), 'stop');

%% 循环每个通道进行滤波
sign_lfp_raw = zeros(size(sign_raw));
sign_spk_raw = zeros(size(sign_raw));

for ch = 1 : length(channel)
    data_ch = sign_raw(:, ch); % 单个通道的原始数据
    
    % 依次应用陷波滤波器
    data_ch = filter(notch50, 1, data_ch);
    data_ch = filter(notch100, 1, data_ch);
    data_ch = filter(notch150, 1, data_ch);
    
    % 应用带通滤波器，得到LFP和spike信号
    sign_lfp_raw(:, ch) = filter(b_lfp, 1, data_ch);
    sign_spk_raw(:, ch) = filter(b_spk, 1, data_ch);
end

% 对LFP信号进行降采样
sign_lfp_raw = resample(sign_lfp_raw, downfs, samfs);

% 共模参考去除（可选）
if Common
    common_mode_reference = mean(sign_lfp_raw, 2); % 计算所有通道的平均值
    for ch = 1 : length(channel)
        sign_lfp_raw(:, ch) = sign_lfp_raw(:, ch) - common_mode_reference;
    end
end
end