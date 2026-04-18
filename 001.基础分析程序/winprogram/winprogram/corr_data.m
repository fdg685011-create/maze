
for d=1:9
    data_spk_ch=[];
    temp_data_spk_ch=[];
    temp_data_spk_ch=all_reselect_all_decode_data{1,d};
    data_spk_ch_before=temp_data_spk_ch(1:105,1:16);
    
    % 计算相关性矩阵
    corr_matrix = corr(data_spk_ch);

    % 绘制相关性热力图
    figure;
    heatmap(corr_matrix, 'Colormap', jet, 'ColorLimits', [-1 1], 'XData', {'ch1', 'ch2', 'ch3', 'ch4', 'ch5','ch6', 'ch7', 'ch8', 'ch9', 'ch10','ch11', 'ch12', 'ch13', 'ch14', 'ch15', 'ch16'}, 'YData', {'ch1', 'ch2', 'ch3', 'ch4', 'ch5','ch6', 'ch7', 'ch8', 'ch9', 'ch10','ch11', 'ch12', 'ch13', 'ch14', 'ch15', 'ch16'});
    title('Correlation Heatmap');
end




