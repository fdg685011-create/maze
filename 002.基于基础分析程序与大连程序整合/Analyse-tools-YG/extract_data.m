function [spk_rate_subset, lfp_subset] = extract_data(spk_rate, rawlfp, start_time, end_time, downfs)
    % start_time, end_time: 试次的开始和结束时间（单位为秒）
    % downfs: 数据的降采样率 (1000 Hz)
    start_idx = round(start_time * downfs) + 1;
    end_idx = round(end_time * downfs);
    spk_rate_subset = spk_rate(start_idx:end_idx, :); % 截取spike发放率数据
    % spk_rate_subset=f_norm(spk_rate_subset);                                  %数据归一化



    lfp_subset = rawlfp(start_idx:end_idx, :); % 截取LFP信号数据
end
