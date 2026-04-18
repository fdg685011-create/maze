% 示例数据
response_on = randn(50, 5, 10);       % 50个样本，5个类别，10个通道的数据
response_baseline = randn(50, 5, 10); % 同样的维度

stim.ClassName = {'Class A', 'Class B', 'Class C', 'Class D', 'Class E'};

% 假设 f_ttest 函数返回一些随机的统计显著性结果
pp = randi([0 1], 10, 1); % 随机生成0和1的数组，表示统计显著性


hold on;
str={' ','*','**'};
for ch = 1:10
    figure;
    data1 = squeeze(response_on(:,:,ch));
    data2 = squeeze(response_baseline(:,:,ch));
    
    p1 = 0.9:1:length(stim.ClassName)+0.5;
    p2 = 1.2:1:length(stim.ClassName)+0.5;
    
    % 绘制盒须图
    b1 = boxplot(data1, 'positions', p1, 'Colors', [255,5,87]/255, 'Widths', 0.2, 'Symbol', '');
    b2 = boxplot(data2, 'positions', p2, 'Colors', [0, 80, 255]/255, 'Widths', 0.2, 'Symbol', '');
    
    % 标记显著性
    for ii = 1:size(data1, 2)
        text(p1(ii)+0.1, -1, str{pp(ii)+1}, 'HorizontalAlignment', 'center', 'FontSize', 12);
    end
    
    % 填充颜色
    fillcolor1 = [0, 80, 255]/255; % 蓝色
    fillcolor2 = [255, 5, 87]/255; % 红色
    [t, ~] = size(data1');
    fillcolors = [repmat(fillcolor1, t, 1); repmat(fillcolor2, t, 1)];
    
    boxobj = findobj(gca, 'Tag', 'Box');
    for j = 1:length(boxobj)
        hx = patch(get(boxobj(j), 'XData'), get(boxobj(j), 'YData'), fillcolors(j, :), 'FaceAlpha', 0.5);
    end
    
    set(gca, 'XTickLabel', stim.ClassName);
    title(['Boxplot Comparison - Channel ' num2str(ch)]);
    ylim([-10, inf]);
    %legend([b1(1), b2(1)], {'Response On', 'Response Baseline'}, 'Location', 'best');
    hold off;
end


