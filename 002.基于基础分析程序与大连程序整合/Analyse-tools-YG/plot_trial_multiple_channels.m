function [] = plot_trial_multiple_channels(rawspk, rawlfp, spk_rate, lfp3045, lfp6080, refs_Time, inter, fband_One, fband_Two,samfs, downfs, choose_trail, choose_ch, rootpath, trial_index)
    %% 基本参数选定
    before = inter(1);
    after = inter(2);
    fs = downfs;
    Fs = samfs;  % 高频信号的采样率
    refs = refs_Time;
    
    j = choose_trail(trial_index);  % 选择特定试次
    
    % 检查refs是否超出索引范围
    if j > size(refs, 1)
        error('Trial index exceeds the number of trials in refs.');
    end
    
    num_channels = length(choose_ch);
    num_figs = ceil(num_channels / 16);  % 计算需要的图数
    
    for fig_idx = 1:num_figs
        % 创建图形窗口
        h_Fig1 = figure('visible', 'off', 'Position', get(0, 'Screensize'));
        h_Fig2 = figure('visible', 'off', 'Position', get(0, 'Screensize'));
        h_Fig3 = figure('visible', 'off', 'Position', get(0, 'Screensize'));
        h_Fig4 = figure('visible', 'off', 'Position', get(0, 'Screensize'));
        
        start_ch = (fig_idx - 1) * 16 + 1;
        end_ch = min(fig_idx * 16, num_channels);
        current_ch = choose_ch(start_ch:end_ch);
        
        sgtitle(h_Fig1, strcat('Trial-', num2str(j), ' - Original Spike Signal - Part ', num2str(fig_idx)));
        sgtitle(h_Fig2, strcat('Trial-', num2str(j), ' - Spike Rate - Part ', num2str(fig_idx)));
        sgtitle(h_Fig3, strcat('Trial-', num2str(j), ' - LFP Spectrogram (30-45Hz) - Part ', num2str(fig_idx)));
        sgtitle(h_Fig4, strcat('Trial-', num2str(j), ' - LFP Spectrogram (60-80Hz) - Part ', num2str(fig_idx)));
        
        for m = 1:length(current_ch)
            mm = current_ch(m);
            spk_ch = rawspk(:, mm);
            lfp_ch = rawlfp(:, mm);
            
            % 获取时间段索引，确保在有效范围内
            start_idx = max(1, round((refs(j, 1) - before) * Fs) + 1);
            end_idx = min(length(spk_ch), round((refs(j, 2) + after) * Fs));
            
            % 确保索引有效
            if start_idx > end_idx || start_idx < 1 || end_idx > length(spk_ch)
                warning('Invalid indices for trial %d, channel %d. Skipping this channel.', j, mm);
                continue;
            end
            
            % 获取时间段数据
            Ys_sj_spk = spk_ch(start_idx:end_idx);
            Ys_sj_lfp = lfp_ch(round((refs(j, 1) - before) * fs) + 1 : round((refs(j, 2) + after) * fs));
            Ys_sj_spk_rate = spk_rate(round((refs(j, 1) - before) * fs) + 1 : round((refs(j, 2) + after) * fs), mm);
            
            % 计算时间向量
            numPoints_high = length(Ys_sj_spk);
            numPoints_low = length(Ys_sj_lfp);
            time_high = (0:numPoints_high-1) / Fs;  % 高频信号时间向量，单位为秒
            time_low = (0:numPoints_low-1) / fs;    % 低频信号时间向量，单位为秒
            time_spkrate = time_low;
            
            % 绘制原始Spike高频信号
            set(0, 'CurrentFigure', h_Fig1);
            subplot(8, 2, m);
            plot(time_high, Ys_sj_spk);
            hold on;
            xline(before, 'r', 'LineWidth', 2);  % 在before时刻画红线
            xline(before + (refs(j, 2) - refs(j, 1)), 'r', 'LineWidth', 2);
            hold off;
            ylabel('Amplitude');
            title(strcat('Channel-', num2str(mm),'类别： ',num2str(refs(j,3))));
            axis tight;
    
            % 绘制Spike发放率
            set(0, 'CurrentFigure', h_Fig2);
            subplot(8, 2, m);
            plot(time_spkrate, Ys_sj_spk_rate);
            hold on;
            xline(before, 'r', 'LineWidth', 2);
            xline(before + (refs(j, 2) - refs(j, 1)), 'r', 'LineWidth', 2);
            hold off;
            ylabel('Spike rate');
            title(strcat('Spike Rate - Channel-', num2str(mm),'类别： ',num2str(refs(j,3))));
            axis tight;
    
            % 绘制30-45Hz频带的LFP时频图
            set(0, 'CurrentFigure', h_Fig3);
            subplot(8, 2, m);
            window = 256;
            [s, F, T] = spectrogram(Ys_sj_lfp, window, window-1, fband_One(1):fband_One(2), fs);
            s=abs(s*2/window*2);
            imagesc(1:length(s), F, s);
            % imagesc(T, F, s);
            set(gca, 'YDir', 'normal');
            hold on;
            
            xline(before*fs, 'r', 'LineWidth', 2);
            disp(before*fs)
            xline((before + refs(j, 2) - refs(j, 1))*fs, 'r', 'LineWidth', 2);
            disp((before + refs(j, 2) - refs(j, 1))*fs)
            % hold off;
            ylabel('Frequency (Hz)');
            title(strcat('LFP Spectrogram - Channel-', num2str(mm), ' - 30-45Hz','类别： ',num2str(refs(j,3))));
            axis tight;
            colorbar;
            yyaxis right
            lfp_freq_3045fband = mean(s,1);
            lfp_freq_3045fband=f_sl_binsl(lfp_freq_3045fband,200,1);
            plot(lfp_freq_3045fband,'Color','k','LineWidth',0.5)
            ylabel('lfp rate')
            set(gca,'FontName','Times New Rome','FontSize',10);
            set(gca,'xticklabel',get(gca,'xtick'));% 设置整体的字号大小

            % 绘制60-80Hz频带的LFP时频图
            set(0, 'CurrentFigure', h_Fig4);
            subplot(8, 2, m);
            [s, F, T] = spectrogram(Ys_sj_lfp, window, window-1, fband_Two(1):fband_Two(2), fs);
             s=abs(s*2/window*2);
            % imagesc(T, F, s);
            imagesc(1:length(s), F, s);
            set(gca, 'YDir', 'normal');
            hold on;
            xline(before*fs, 'r', 'LineWidth', 2);
            xline((before + refs(j, 2) - refs(j, 1))*fs, 'r', 'LineWidth', 2);
            % hold off;
            ylabel('Frequency (Hz)');
            title(strcat('LFP Spectrogram - Channel-', num2str(mm), ' - 60-80Hz','类别： ',num2str(refs(j,3))));
            axis tight;
            colorbar;
            hold on
            yyaxis right
            lfp_freq_6080fband = mean(s,1);
            lfp_freq_6080fband=f_sl_binsl(lfp_freq_6080fband,200,1);
            plot(lfp_freq_6080fband,'Color','k','LineWidth',0.5)
            ylabel('lfp rate')
            set(gca,'FontName','Times New Rome','FontSize',10);
            set(gca,'xticklabel',get(gca,'xtick'));% 设置整体的字号大小

        end
        
        % 保存图像
        saved_rootpath = rootpath;
        filename1 = strcat('trial-', num2str(j), '-original-spike-part-', num2str(fig_idx));
        filename2 = strcat('trial-', num2str(j), '-spike-rate-part-', num2str(fig_idx));
        filename3 = strcat('trial-', num2str(j), '-lfp-spectrogram-30-45-part-', num2str(fig_idx));
        filename4 = strcat('trial-', num2str(j), '-lfp-spectrogram-60-80-part-', num2str(fig_idx));
        
        % 创建特征文件夹
        if ~exist(fullfile(saved_rootpath, 'original-spike'), 'dir')
            mkdir(fullfile(saved_rootpath, 'original-spike'));
        end
        if ~exist(fullfile(saved_rootpath, 'spike-rate'), 'dir')
            mkdir(fullfile(saved_rootpath, 'spike-rate'));
        end
        if ~exist(fullfile(saved_rootpath, 'lfp-spectrogram-30-45'), 'dir')
            mkdir(fullfile(saved_rootpath, 'lfp-spectrogram-30-45'));
        end
        if ~exist(fullfile(saved_rootpath, 'lfp-spectrogram-60-80'), 'dir')
            mkdir(fullfile(saved_rootpath, 'lfp-spectrogram-60-80'));
        end
        
        full_savedfile_name1 = fullfile(saved_rootpath, 'original-spike', strcat(filename1, '.jpg'));
        full_savedfile_name2 = fullfile(saved_rootpath, 'spike-rate', strcat(filename2, '.jpg'));
        full_savedfile_name3 = fullfile(saved_rootpath, 'lfp-spectrogram-30-45', strcat(filename3, '.jpg'));
        full_savedfile_name4 = fullfile(saved_rootpath, 'lfp-spectrogram-60-80', strcat(filename4, '.jpg'));
        
        print(h_Fig1, '-djpeg', full_savedfile_name1);
        print(h_Fig2, '-djpeg', full_savedfile_name2);
        print(h_Fig3, '-djpeg', full_savedfile_name3);
        print(h_Fig4, '-djpeg', full_savedfile_name4);
        
        close(h_Fig1);
        close(h_Fig2);
        close(h_Fig3);
        close(h_Fig4);
    end
end
