function [] = P_plot(choose_ch,sign_raw,sign_lfp_raw,sign_spk_raw,refs,before,after,fs,Fs,fband)
   len = length(choose_ch);
   for m=1:len
       mm = choose_ch(m);
       raw = sign_raw(:,mm);
       lfp_ch = sign_lfp_raw(:,mm);
       spk_ch = sign_spk_raw(:,mm);
     for j=1:length(refs)
         window = 256;
         diff = (window/2)/fs;
         Ys_sj_lfp_energe = lfp_ch(round((refs(j,1) - before-diff)*fs) + 1:round((refs(j,2) + after+diff)*fs));
         Ys_sj_lfp = lfp_ch(round((refs(j,1) - before)*fs) + 1:round((refs(j,2) + after)*fs));
         Ys_sj_spk = spk_ch(round((refs(j,1) - before)*Fs) + 1:round((refs(j,2) + after)*Fs));
         Ys_sj_raw = raw(round((refs(j,1) - before)*Fs) + 1:round((refs(j,2) + after)*Fs));
         freq = [1,100];             % 时频分析的频率范围
         step = 1;
         [s,F,T] = spectrogram(Ys_sj_lfp_energe,window,window-step,freq(1):freq(2),fs);  
         s=abs(s*2/window*2);
         F=round(F);
         F_=F(F<=fband(2) & F>=fband(1));
         respones_on_  = s(F(F<=fband(2) & F>=fband(1)),:);

% 采样率
Fs_high = Fs; % 原始信号和高频信号的采样率
Fs_low = fs; % 低频信号的采样率

% 计算时间向量
numPoints_high = length(Ys_sj_raw);
numPoints_low = length(Ys_sj_lfp);
numPoints_energe = size(respones_on_, 2);

time_high = (0:numPoints_high-1) / Fs_high; % 高频信号时间向量，单位为秒
time_low = (0:numPoints_low-1) / Fs_low; 
time_energe = (0:numPoints_energe-1) / Fs_low; 

% 创建图形窗口
figure('units','normalized','outerposition',[0 0 1 1])
sgtitle(strcat('trial-',num2str(j)));

% 绘制原始信号
subplot(4,1,1);
plot(time_high, Ys_sj_raw);
hold on;
xline(before, 'r', 'LineWidth', 2); % 在1秒时刻画红线
xline(before+(refs(j,2)-refs(j,1)), 'r', 'LineWidth', 2); 
hold off;
xlabel('Time (seconds)');
ylabel('Amplitude');
title('Original Signal');
axis tight;

% 绘制原始信号
subplot(4,1,2);
plot(time_low, Ys_sj_lfp);
hold on;
xline(before, 'r', 'LineWidth', 2); % 在1秒时刻画红线
xline(before+(refs(j,2)-refs(j,1)), 'r', 'LineWidth', 2); 
hold off;
xlabel('Time (seconds)');
ylabel('Amplitude');
title('Low Frequency Signal');
axis tight;

% 绘制高频信号
subplot(4,1,3);
plot(time_high, Ys_sj_spk);
hold on;
xline(before, 'r', 'LineWidth', 2); % 在1秒时刻画红线
xline(before+(refs(j,2)-refs(j,1)), 'r', 'LineWidth', 2); 
hold off;
xlabel('Time (seconds)');
ylabel('Amplitude');
title('High Frequency Signal');
axis tight;

% 绘制低频信号的能量值
subplot(4,1,4);
imagesc(time_energe, F_, respones_on_);
ylim([fband(1) fband(2)])
set(gca,'ydir','normal')
hold on;
xline(before, 'r', 'LineWidth', 2); % 在1秒时刻画红线
xline(before+(refs(j,2)-refs(j,1)), 'r', 'LineWidth', 2); 
hold off;
xlabel('Time (seconds)');
ylabel('Frequency Bins');
title('LFP Energy');
axis tight;
colormap;

% 绘制colorbar并调整其位置
h = colorbar;
set(h, 'Position', [0.93, 0.11, 0.02, 0.18]); % 手动调整colorbar位置


     end
   end
   