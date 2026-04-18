function balanced_data = balance_svm_data(svm_traindata)
    % 获取所有标签类别
    labels = unique(svm_traindata(:, end));
    num_classes = length(labels);
    
    % 初始化一个单元数组来存储每个类别的样本
    class_samples = cell(num_classes, 1);
    
    % 遍历每个类别，提取样本
    for i = 1:num_classes
        class_samples{i} = svm_traindata(svm_traindata(:, end) == labels(i), :);
    end
    
    % 找到最小样本数
    min_samples = min(cellfun(@(x) size(x, 1), class_samples));
    
    % 初始化平衡后的数据集
    balanced_data = [];
    
    % 对每个类别进行样本平衡
    for i = 1:num_classes
        current_class_samples = class_samples{i};
        % 随机抽样
        if size(current_class_samples, 1) > min_samples
            selected_indices = randsample(size(current_class_samples, 1), min_samples);
            balanced_data = [balanced_data; current_class_samples(selected_indices, :)];
        else
            balanced_data = [balanced_data; current_class_samples]; % 直接添加
        end
    end
    
    % 打乱数据顺序
    balanced_data = balanced_data(randperm(size(balanced_data, 1)), :);
end
