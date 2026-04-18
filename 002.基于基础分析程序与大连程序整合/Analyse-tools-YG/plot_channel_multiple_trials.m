function [] = plot_channel_multiple_trials(rawspk, rawlfp, spk_rate, lfp3045, lfp6080, refs_Time, inter, fband_One, fband_Two, samfs,downfs, choose_trail, channel_index, rootpath)
    %% 基本参数选定
    before = inter(1);
    after = inter(2);
    fs = downfs;
    Fs = samfs;  % 高频信号的采样率
    refs = refs_Time;
    
    mm = channel_index;  % 选择特定通道
    spk_ch = rawspk(:, mm);
    lfp_ch = rawlfp(:, mm);
    num_trials = length(choose_trail);
    
    % 计算需要的图数
    num_figs = ceil(num_trials / 10);

    for feature_idx = 1:4  % 循环绘制四个特征
        for fig_idx = 1:num_figs
            h_Fig = figure('units', 'normalized', 'outerposition', [0 0 1 1], 'visible', 'off');
            
            switch feature_idx
                case 1
                    sgtitle(h_Fig, strcat('Channel-', num2str(mm), '- Multiple Trials - High Frequency Signal'));
                case 2
                    sgtitle(h_Fig, strcat('Channel-', num2str(mm), '- Multiple Trials - Spike Rate'));
                case 3
                    sgtitle(h_Fig, strcat('Channel-', num2str(mm), '- Multiple Trials - LFP Spectrogram (30-45Hz)'));
                case 4
                    sgtitle(h_Fig, strcat('Channel-', num2str(mm), '- Multiple Trials - LFP Spectrogram (60-80Hz)'));
            end
            
            trials_in_fig = min(10, num_trials - (fig_idx-1) * 10);  % 本图中绘制的试次数
            
            for t_idx = 1:trials_in_fig
                trial_idx = (fig_idx-1) * 10 + t_idx;
                j = choose_trail(trial_idx);  % 选择特定试次
                
                % 获取时间段数据
                start_idx = round((refs(j, 1) - before) * Fs) + 1;
                end_idx = round((refs(j, 2) + after) * Fs);
                Ys_sj_spk = spk_ch(start_idx:end_idx);
                Ys_sj_lfp = lfp_ch(round((refs(j, 1) - before) * fs) + 1:round((refs(j, 2) + after) * fs));
                Ys_sj_spk_rate = spk_rate(round((refs(j, 1) - before) * fs) + 1:round((refs(j, 2) + after) * fs), mm);
                
                % 计算时间向量
                numPoints_high = length(Ys_sj_spk);
                time_high = (0:numPoints_high-1) / Fs;  % 高频信号时间向量，单位为秒
                time_spkrate = (0:length(Ys_sj_spk_rate)-1) / fs;
                time_low = (0:length(Ys_sj_lfp)-1) / fs;
                
                % 绘制第t_idx张图
                subplot(5, 2, t_idx);
                
                switch feature_idx
                    case 1  % 绘制原始Spike高频信号
                        plot(time_high, Ys_sj_spk);
                        ylabel('Amplitude');
                        title(strcat('Trial-', num2str(j),'类别： ',num2str(refs(j,3))));
                        
                    case 2  % 绘制Spike发放率
                        plot(time_spkrate, Ys_sj_spk_rate);
                        ylabel('Spike rate');
                        title(strcat('Spike Rate - Trial-', num2str(j),'类别： ',num2str(refs(j,3))));
                        
                    case 3  % 绘制30-45Hz频带的LFP时频图
                        window = 256;
                        [s, F, T] = spectrogram(Ys_sj_lfp, window, window-1, fband_One(1):fband_One(2), fs);
                        s=abs(s*2/window*2);
                        imagesc(T, F, s);
                        set(gca, 'YDir', 'normal');
                        ylabel('Frequency (Hz)');
                        title(strcat('LFP Spectrogram - Trial-', num2str(j), ' - 30-45Hz','类别： ',num2str(refs(j,3))));
                        colorbar;
                        
                    case 4  % 绘制60-80Hz频带的LFP时频图
                        window = 256;
                        [s, F, T] = spectrogram(Ys_sj_lfp, window, window-1, fband_Two(1):fband_Two(2), fs);
                        s=abs(s*2/window*2);
                        imagesc(T, F, s);
                        set(gca, 'YDir', 'normal');
                        ylabel('Frequency (Hz)');
                        title(strcat('LFP Spectrogram - Trial-', num2str(j), ' - 60-80Hz','类别： ',num2str(refs(j,3))));
                        colorbar;
                end
                
                hold on;
                xline(before, 'r', 'LineWidth', 2);  % 在before时刻画红线
                xline(before + (refs(j, 2) - refs(j, 1)), 'r', 'LineWidth', 2);
                hold off;
                axis tight;
            end
            
            % 保存图像
            saved_rootpath = rootpath;
            switch feature_idx
                case 1
                    filename = strcat('channel-', num2str(mm), '-multiple-trials-spike-part-', num2str(fig_idx));
                    feature_folder = fullfile(saved_rootpath, 'original-spike');
                case 2
                    filename = strcat('channel-', num2str(mm), '-multiple-trials-spike-rate-part-', num2str(fig_idx));
                    feature_folder = fullfile(saved_rootpath, 'spike-rate');
                case 3
                    filename = strcat('channel-', num2str(mm), '-multiple-trials-lfp-spectrogram-30-45-part-', num2str(fig_idx));
                    feature_folder = fullfile(saved_rootpath, 'lfp-spectrogram-30-45');
                case 4
                    filename = strcat('channel-', num2str(mm), '-multiple-trials-lfp-spectrogram-60-80-part-', num2str(fig_idx));
                    feature_folder = fullfile(saved_rootpath, 'lfp-spectrogram-60-80');
            end

            % 创建特征文件夹
            if ~exist(feature_folder, 'dir')
                mkdir(feature_folder);
            end

            full_savedfile_name = fullfile(feature_folder, strcat(filename, '.jpg'));
            print(h_Fig, '-djpeg', full_savedfile_name);
            close(h_Fig);
        end
    end
end
