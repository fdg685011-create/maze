function [refs_train, refs_test] = split_refs(refs, train_ratio)
% train_ratio: 训练集所占的比例，0.5表示50%训练集和50%测试集
% 假设 refs 是你的矩阵
% refs(refs(:, 1) > 4200 | refs(:, 2) > 4200, :) = [];
% 假设 refs 是你的矩阵
refs(refs(:, 3) > 10, 3) = floor(refs(refs(:, 3) > 10, 3) / 10);

unique_labels = unique(refs(:, 3)); % 提取所有的类别标签
refs_train = [];
refs_test = [];

for i = 1:length(unique_labels)
    label = unique_labels(i);
    label_rows = refs(refs(:, 3) == label, :); % 获取该标签的所有行
    num_trials = size(label_rows, 1);
    num_train = round(train_ratio * num_trials); % 训练集数量
    % 将前 num_train 行作为训练集，剩余部分作为测试集
    refs_train = [refs_train; label_rows(1:num_train, :)];
    refs_test = [refs_test; label_rows(num_train+1:end, :)];
end
end
