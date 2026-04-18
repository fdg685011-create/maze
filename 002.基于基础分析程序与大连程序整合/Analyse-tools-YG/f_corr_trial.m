% function f_corr_trial(data, fs, window_length, refs, before, after, rootpath)
%     % data: 二维数组，时间序列 * 通道数
%     % fs: 采样率
%     % window_length: 窗口长度（秒）
%     % refs: 打标区间，二维数组，试次数 * [开始时刻, 结束时刻, 类别标签]
%     % before: 试次开始时刻向前多取几秒
%     % after: 试次结束时刻向后多取几秒
% 
%     % 将窗口长度从秒转换为样本点数
%     window_samples = round(window_length * fs);
% 
%     % 遍历每个试次
%     for trial = 1:size(refs, 1)
%         % 获取当前试次的开始时间、结束时间和类别标签
%         start_time = refs(trial, 1);
%         end_time = refs(trial, 2);
%         trial_label = refs(trial, 3); % 类别标签
% 
%         % 计算提取时间序列的起始和结束样本点
%         start_sample = max(1, round((start_time - before) * fs));
%         end_sample = min(size(data, 1), round((end_time + after) * fs));
% 
%         % 提取当前试次的时间序列
%         trial_data = data(start_sample:end_sample, :);
% 
%         % 计算窗口数
%         num_windows = floor(size(trial_data, 1) / window_samples);
% 
%         % 创建大图
%         h_Fig = figure('units','normalized','outerposition',[0 0 1 1],'visible','on');
%         sgtitle(sprintf('Trial %d - 类别 %d', trial, trial_label));
% 
%         % 遍历每个窗口
%         for win = 1:num_windows
%             % 提取当前窗口的数据
%             window_start = (win - 1) * window_samples + 1;
%             window_end = win * window_samples;
%             window_data = trial_data(window_start:window_end, :);
% 
%             % 计算相关性矩阵
%             corr_matrix = corrcoef(window_data);
% 
%             % 计算当前窗口的时间间隔
%             time_start = (win - 1) * window_length;
%             time_end = win * window_length;
% 
%             % 绘制相关性图
%             subplot(ceil(sqrt(num_windows)), ceil(sqrt(num_windows)), win);
%             imagesc(corr_matrix);
%             colorbar;
%             title(sprintf('%.1fs - %.1fs', time_start, time_end)); % 子图标题为时间间隔
%             xlabel('Channels');
%             ylabel('Channels');
%         end
% 
%         % 图片保存
%         saved_rootpath = rootpath;
%         filename = strcat('Trial ',num2str(trial),'-类别标签 ',num2str(trial_label));
%         full_savedfile_name = strcat(saved_rootpath,'\',filename,'.png');
%         print(h_Fig,'-dpng',full_savedfile_name);
%         close(h_Fig)
% 
% 
% 
% 
% 
%     end
% end


function f_corr_trial(data, fs, window_length, refs, before, after, rootpath)
    % data: 二维数组，时间序列 * 通道数
    % fs: 采样率
    % window_length: 窗口长度（秒）
    % refs: 打标区间，二维数组，试次数 * [开始时刻, 结束时刻, 类别标签]
    % before: 试次开始时刻向前多取几秒
    % after: 试次结束时刻向后多取几秒

    % 将窗口长度从秒转换为样本点数
    window_samples = round(window_length * fs);
    
    % 遍历每个试次
    for trial = 1:size(refs, 1)
        % 获取当前试次的开始时间、结束时间和类别标签
        start_time = refs(trial, 1);
        end_time = refs(trial, 2);
        trial_label = refs(trial, 3); % 类别标签
        
        % 计算提取时间序列的起始和结束样本点
        start_sample = max(1, round((start_time - before) * fs));
        end_sample = min(size(data, 1), round((end_time + after) * fs));
        
        % 提取当前试次的时间序列
        trial_data = data(start_sample:end_sample, :);
        
        % 计算窗口数
        num_windows = floor(size(trial_data, 1) / window_samples);
        
        % 创建大图
        h_Fig = figure('units','normalized','outerposition',[0 0 1 1],'visible','off');
        t = tiledlayout('flow'); % 使用流式布局，自动调整子图排列
        title(t, sprintf('Trial %d - 标签类别 %d', trial, trial_label)); % 大图标题
        
        % 遍历每个窗口
        for win = 1:num_windows
            % 提取当前窗口的数据
            window_start = (win - 1) * window_samples + 1;
            window_end = win * window_samples;
            window_data = trial_data(window_start:window_end, :);
            
            % 计算相关性矩阵
            corr_matrix = corrcoef(window_data);
            
            % 计算当前窗口的时间间隔
            time_start = (win - 1) * window_length;
            time_end = win * window_length;

            % 创建子图
            nexttile; % 切换到下一个子图
            imagesc(corr_matrix);
            colorbar;

            % 设置子图标题
            title_str = sprintf('%.1fs - %.1fs', time_start, time_end);
            h_title = title(title_str); % 获取标题句柄

            % 判断当前窗口是否位于 refs 区间内
            if (time_start >= before && time_end <= num_windows*window_length-after)
                % 如果位于 refs 区间内，设置标题字体颜色为红色
                set(h_title, 'Color', 'red');
            else
                % 否则设置为默认颜色（黑色）
                set(h_title, 'Color', 'black');
            end
            % title(sprintf('%.1fs - %.1fs', time_start, time_end)); % 子图标题为时间间隔
            xlabel('Channels');
            ylabel('Channels');

        end
        % 图片保存
        saved_rootpath = rootpath;
        filename = strcat('Trial ',num2str(trial),'-类别标签 ',num2str(trial_label));
        full_savedfile_name = strcat(saved_rootpath,'\',filename,'.png');
        print(h_Fig,'-dpng',full_savedfile_name);
        close(h_Fig)
    end
end