% 假设 data1 和 data2 是两个 16xN 的矩阵，其中 N 是每个数据集的点数  
% 这里我们创建一些示例数据  
%rng('default'); % 为了可重复性  
%N = 100; % 假设每个数据集有100个点  

for i=1:10

    lfp=all_reselect_spk{1,i};
    spk=all_reselect_lfp{1,i};

    data1 = spk(60:90,:)'; % 16个随机数据集  
    data2 = spk(60:90,:)'; % 另外16个随机数据集  

    % 初始化一个 16x16 的矩阵来存储互相关系数  
    corr_matrix = zeros(16, 16);  

    % 计算每对数据集之间的互相关系数  
    for i = 1:16  
        for j = 1:16  
            % 计算无偏估计的互相关系数  
            [coeff, lags] = xcorr(data1(i,:), data2(j,:), 'unbiased');  
            % 提取零延迟处的互相关系数（即没有时间偏移的系数）  
            corr_matrix(i, j) = coeff(lags == 0);  
        end  
    end  

    % 绘制热力图  
    figure;  
    imagesc(corr_matrix); % 使用 imagesc 绘制图像  
    colorbar; % 显示颜色条  
    title('互相关系数热力图');  
    xlabel('数据集 2 的索引');  
    ylabel('数据集 1 的索引');  


end
  
% 如果想使用 heatmap 而不是 imagesc（需要 Statistics and Machine Learning Toolbox）  
% heatmap(corr_matrix);  
% colorbar;  
% title('互相关系数热力图');  
% xlabel('数据集 2 的索引');  
% ylabel('数据集 1 的索引');