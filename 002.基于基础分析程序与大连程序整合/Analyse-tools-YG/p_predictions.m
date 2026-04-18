function [ ] = p_predictions(groundth,predt)
%UNTITLED5 此处显示有关此函数的摘要
%   此处显示详细说明

%% 绘制第1张图----------------1----------------实际标签参考
subplot(2,1,1); 
stem(groundth);
t=title('目标进出通道实际标签类别（groundth）');
set(gca, 'FontSize', 18, 'LineWidth', 1.5);
set(t, 'FontSize', 24); % 修改字体大小
xlabel('预测窗口序数','FontSize', 24);
ylabel('标签类别','FontSize', 24);

%% 绘制第2张图----------------2----------------预测结果
subplot(2,1,2); 
stem(predt);
t=title('直接预测结果（predt）');
set(gca, 'FontSize', 18, 'LineWidth', 1.5);
set(t, 'FontSize', 24); % 修改字体大小
xlabel('预测窗口序数','FontSize', 24);
ylabel('标签类别','FontSize', 24);


end