function [svm_train_x, svm_train_y] = generate_svm_train_data(spk_rate_train, lfp6080_train, lfp3045_train, lfp510_train, window_size_s, step_size_s, fs, Selected_ch)
% 参数：
% spk_rate_train, lfp6080_train, lfp3045_train, lfp510_train: 4个元胞数组
% window_size_s: 2秒的窗口长度
% step_size_s: 1秒的滑窗步长
% fs: 采样率，默认1000Hz
svm_train_x = [];
svm_train_y = [];
current_feature_data = [];
num_trials = length(spk_rate_train);  % 获取试次数量
window_size = window_size_s * fs;     % 转换窗口长度为采样点
step_size = step_size_s * fs;         % 转换步长为采样点
corr_feture_temp=[];
% 遍历每个试次
for i = 1:num_trials
    % 获取每个试次的32列数据
    spk_rate_data = spk_rate_train{i, 1};  % spike发放率数据 (时间点 * 32)
    lfp6080_data = lfp6080_train{i, 1};    % LFP 60-80Hz平均能量 (时间点 * 32)
    lfp3045_data = lfp3045_train{i, 1};    % LFP 30-45Hz平均能量 (时间点 * 32)
    lfp510_data = lfp510_train{i, 1};      % LFP 5-10Hz频带中的一列 (时间点 * 1)
    label = spk_rate_train{i, 2};          % 标签

    % 拼接数据 (时间点 * 97列)
    % concatenated_data = [spk_rate_data(:,[1:24 25 27 29 31]), lfp510_data(:,5), lfp3045_data(:,[1:24 25 27 29 31]), lfp6080_data(:,[1:24 25 27 29 31]) ];
    % concatenated_data = [spk_rate_data(:,Selected_ch), lfp3045_data(:,Selected_ch), lfp6080_data(:,Selected_ch) ];
    
concatenated_data = [lfp3045_data(:,Selected_ch), lfp6080_data(:,Selected_ch) ];
    
    % concatenated_data = [lfp6080_data(:,Selected_ch) ];   

    % 获取该试次的总时间长度（采样点数）
    total_time_points = size(concatenated_data, 1);

    % 进行2秒窗长的滑窗
    for start_idx = 1:step_size:(total_time_points - window_size + 1)
        end_idx = start_idx + window_size - 1;
        data_window = concatenated_data(start_idx:end_idx, :);  % 截取2秒的窗口数据
        data_window_mean = mean(data_window,1);
        svm_train_x = [svm_train_x;data_window_mean];
        svm_train_y = [svm_train_y,label];
    end
end
end