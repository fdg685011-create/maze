function [all_trial_data] = f_pca_trial(data, fs, window_length, refs)
    % data: 二维矩阵，一维是时间序列，二维是通道数
    % refs: 二维矩阵，一维是试次数，二维是试次开始时刻、结束时刻和标签类别
    % window_length: 滑窗窗长（秒）
    % fs: 采样率（Hz）
    

    % 拼接所有试次目标数据
    all_trial_data=[];

    % 初始化元胞数组用于存储每个试次的PCA结果
    pca_results = cell(size(refs, 1), 1);
    
    % 将窗口长度从秒转换为样本点数
    window_samples = round(window_length * fs);
    
    % 遍历每个试次
    for trial_idx = 1:size(refs, 1)
        % 获取当前试次的开始和结束时间点
        start_time = refs(trial_idx, 1);
        end_time = refs(trial_idx, 2);
        
        % 将时间点转换为样本点索引
        start_sample = round(start_time * fs);
        end_sample = round(end_time * fs);
        
        % 截取当前试次的数据
        trial_data = data(start_sample:end_sample, :);

        % 拼接每个试次
        all_trial_data=[all_trial_data;trial_data];


        % 初始化存储PCA结果的矩阵
        pca_coeffs = [];
        
        % 滑动窗口处理
        for window_start = 1:window_samples:size(trial_data, 1) - window_samples + 1
            window_end = window_start + window_samples - 1;
            
            % 截取当前窗口的数据
            window_data = trial_data(window_start:window_end, :);

            % 对窗口数据进行PCA降维
            [coeff, ~, ~] = pca(window_data);
            
            % 取前两个主成分
            pca_coeffs = [pca_coeffs; coeff(:, 1:2)'];
        end
        
        % 将PCA结果存储在元胞数组中
        pca_results{trial_idx} = pca_coeffs;
        
        % 绘制PCA结果
        figure;
        scatter(pca_coeffs(:, 1), pca_coeffs(:, 2));
        title(sprintf('Trial %d PCA Scatter Plot', trial_idx));
        xlabel('PC1');
        ylabel('PC2');
    end
end