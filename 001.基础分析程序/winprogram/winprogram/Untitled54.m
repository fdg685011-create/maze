% 假设 data1 和 data2 是两组100行16列的数据  
% 这里我们使用随机数据作为示例  
data1 = randn(100, 16); % 第一组数据，100x16矩阵  
data2 = randn(100, 16); % 第二组数据，100x16矩阵  
  
% 初始化相关系数矩阵  
R = zeros(16, 16);  
  
% 计算两组数据每对列之间的相关系数  
for i = 1:16  
    for j = 1:16  
        R(i, j) = corr(data1(:, i), data2(:, j)); % 计算第i列和第j列的相关系数  
    end  
end  
  
% 绘制相关性热力图  
imagesc(R); % 使用imagesc绘制矩阵图像  
colorbar; % 显示颜色条  
title('Correlation Heatmap'); % 设置图标题  
xlabel('Column of Data 2'); % 设置x轴标签  
ylabel('Column of Data 1'); % 设置y轴标签  
  
% 添加坐标轴标签  
set(gca, 'XTickLabel', arrayfun(@num2str, 1:16, 'UniformOutput', false));  
set(gca, 'YTickLabel', arrayfun(@num2str, 1:16, 'UniformOutput', false));  
set(gca, 'XTick', 1:16);  
set(gca, 'YTick', 1:16);  
grid on;  
  
% 旋转x轴标签以便阅读  
xticklabels = get(gca,'XTickLabel');  
set(gca,'XTickLabel',xticklabels,'XTickLabelRotation',45);