% 生成示例数据
data = randn(100, 5); % 生成100行5列的随机数据

% 计算相关性矩阵
corr_matrix = corr(data);

% 绘制相关性热力图
figure;
heatmap(corr_matrix, 'Colormap', jet, 'ColorLimits', [-1 1], 'XData', {'Var1', 'Var2', 'Var3', 'Var4', 'Var5'}, 'YData', {'Var1', 'Var2', 'Var3', 'Var4', 'Var5'});
title('Correlation Heatmap');