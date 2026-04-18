function smoothed_predictions = sliding_window_mode_conv(predict_svm, window_len)
    % sliding_window_mode_conv 使用卷积计算滑动窗口内的众数
    % 输入：
    %   predict_svm - SVM预测的类别序列
    %   window_len - 滑动窗口的长度
    % 输出：
    %   smoothed_predictions - 使用滑动窗口后的平滑预测序列
    
    unique_classes = unique(predict_svm);  % 获取所有唯一的类别
    n = length(predict_svm);  % 预测序列的长度
    count_matrix = zeros(length(unique_classes), n);  % 初始化计数矩阵
    
    % 逐类计算窗口内的出现次数
    for i = 1:length(unique_classes)
        class_indicator = (predict_svm == unique_classes(i));  % 指示矩阵
        count_matrix(i, :) = conv(class_indicator, ones(1, window_len), 'same');  % 卷积操作
    end
    
    % 找到每个位置对应窗口内出现次数最多的类别
    [~, max_idx] = max(count_matrix, [], 1);  % 找到每列中的最大值索引
    smoothed_predictions = unique_classes(max_idx);  % 将索引转换为类别
end