    % 生成示例数据
for i=1:10    

    num_samples = 16;

    data_set1 = all_reselect_spk{1,i}';    %y轴
    data_set2 = all_reselect_spk{1,i}';   %x轴
    
    data_set1 = data_set1(:,61:90);
    data_set2 = data_set2(:,31:60);
    % 计算互相关系数
    correlation_matrix = zeros(num_samples, num_samples);
    for i = 1:num_samples
        for j = 1:num_samples
            data_length=size(data_set1,2);
            correlation_coeffs = xcorr(data_set1(i, :), data_set2(j, :), 'coeff');
            correlation_matrix(i, j) = correlation_coeffs(data_length); % 提取互相关系数中心点的值
        end
    end

    % 绘制热力图
    figure
    heatmap(correlation_matrix);
    title('互相关系数热力图');
    xlabel('转弯前1s时段的16个通道Spike发放率');
    ylabel('转弯后1s时段的16个通道Spike发放率');
    colormap('jet');
    
end
