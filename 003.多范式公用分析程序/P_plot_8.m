function [] = P_plot(choose_ch,sign_raw,sign_lfp_raw,sign_spk_raw,refs,before,after,fs,Fs,fbandone,fbandtwo,fbandthree,fbandfour,spkdata,sign_spk_rate)
   len = length(choose_ch);
%    for m=1:len
%        mm = choose_ch(m);
%        raw = sign_raw(:,mm);
%        lfp_ch = sign_lfp_raw(:,mm);
%        spk_ch = sign_spk_raw(:,mm);
     for j=1:size(refs,1)
          for m=1:len
          mm = choose_ch(m);
          raw = sign_raw(:,mm);
          lfp_ch = sign_lfp_raw(:,mm);
          spk_ch = sign_spk_raw(:,mm);

         window = 256;
         diff = (window/2)/fs;
         Ys_sj_lfp_energe = lfp_ch(round((refs(j,1) - before-diff)*fs) + 1:round((refs(j,2) + after+diff)*fs));
         Ys_sj_lfp = lfp_ch(round((refs(j,1) - before)*fs) + 1:round((refs(j,2) + after)*fs));
         Ys_sj_spk = spk_ch(round((refs(j,1) - before)*Fs) + 1:round((refs(j,2) + after)*Fs));
         Ys_sj_raw = raw(round((refs(j,1) - before)*Fs) + 1:round((refs(j,2) + after)*Fs));
         Ys_sj_spk_rate = sign_spk_rate(round((refs(j,1) - before)*fs) + 1:round((refs(j,2) + after)*fs),:);
         freq = [1,100];             % 时频分析的频率范围
         step = 1;
         [s,F,T] = spectrogram(Ys_sj_lfp_energe,window,window-step,freq(1):freq(2),fs);  
         s=abs(s*2/window*2);
         F=round(F);
         F_one=F(F<=fbandone(2) & F>=fbandone(1));
         respones_on_one  = s(F_one,:);
           F_two=F(F<=fbandtwo(2) & F>=fbandtwo(1));
         respones_on_two  = s(F_two,:);
           F_three=F(F<=fbandthree(2) & F>=fbandthree(1));
         respones_on_three  = s(F_three,:);
           F_four=F(F<=fbandfour(2) & F>=fbandfour(1));
         respones_on_four  = s(F_four,:);

% 采样率
Fs_high = Fs; % 原始信号和高频信号的采样率
Fs_low = fs; % 低频信号的采样率

% 计算时间向量
numPoints_high = length(Ys_sj_raw);
numPoints_low = length(Ys_sj_lfp);
numPoints_energe = size(respones_on_one, 2);
numPoints_spkrate = size(Ys_sj_spk_rate, 1);

time_high = (0:numPoints_high-1) / Fs_high; % 高频信号时间向量，单位为秒
time_low = (0:numPoints_low-1) / Fs_low; 
time_energe = (0:numPoints_energe-1) / Fs_low; 
time_spkrate = (0:numPoints_spkrate-1) / Fs_low; 

% 创建图形窗口
figure('units','normalized','outerposition',[0 0 1 1])
sgtitle(strcat('trial-',num2str(j),'ch-',num2str(mm),'-',num2str(refs(j,3))));

% 绘制原始信号
subplot(8,1,1);
plot(time_high, Ys_sj_raw);
hold on;
xline(before, 'r', 'LineWidth', 2); % 在1秒时刻画红线
xline(before+(refs(j,2)-refs(j,1)), 'r', 'LineWidth', 2); 
hold off;
% xlabel('Time (seconds)');
ylabel('Amplitude');
title('Original Signal');
axis tight;

% 绘制原始信号
subplot(8,1,2);
plot(time_low, Ys_sj_lfp);
hold on;
xline(before, 'r', 'LineWidth', 2); % 在1秒时刻画红线
xline(before+(refs(j,2)-refs(j,1)), 'r', 'LineWidth', 2); 
hold off;
% xlabel('Time (seconds)');
ylabel('Amplitude');
title('Low Frequency Signal');
axis tight;

% 绘制高频信号
subplot(8,1,3);
plot(time_high, Ys_sj_spk);
hold on;
xline(before, 'r', 'LineWidth', 2); % 在1秒时刻画红线
xline(before+(refs(j,2)-refs(j,1)), 'r', 'LineWidth', 2); 

spk_thre_ch=spkdata{3,mm};
yline(spk_thre_ch, 'r', 'LineWidth', 0.5); % 在1秒时刻画红线

hold off;
% xlabel('Time (seconds)');
ylabel('Amplitude');
title('High Frequency Signal');
axis tight;

% 绘制spk发放率图
subplot(8,1,4);
sign_spk_rate_ch=Ys_sj_spk_rate(:,mm);
plot(time_spkrate, sign_spk_rate_ch);
hold on;
xline(before, 'r', 'LineWidth', 2); % 在1秒时刻画红线
xline(before+(refs(j,2)-refs(j,1)), 'r', 'LineWidth', 2); 
hold off;
% xlabel('Time (seconds)');
ylabel('Spike rate');
title('single trail Spike rate');
axis tight;



% 绘制低频60-80Hz信号的能量值
subplot(8,1,5);
imagesc(time_energe, F_four, respones_on_four);
ylim([fbandfour(1) fbandfour(2)])
set(gca,'ydir','normal')
hold on;
xline(before, 'r', 'LineWidth', 2); % 在1秒时刻画红线
xline(before+(refs(j,2)-refs(j,1)), 'r', 'LineWidth', 2); 
hold off;
% xlabel('Time (seconds)');
ylabel('Frequency Bins');
title(strcat('LFP Energy -',num2str(fbandfour(1)),'~',num2str(fbandfour(2)),'Hz'));
axis tight;
% 绘制colorbar并调整其位置
h = colorbar;
set(h, 'Position', [0.93, 0.42, 0.01, 0.06]); % 手动调整colorbar位置
colormap;

% 绘制低频30-45Hz信号的能量值
subplot(8,1,6);
imagesc(time_energe, F_three, respones_on_three);
ylim([fbandthree(1) fbandthree(2)])
set(gca,'ydir','normal')
hold on;
xline(before, 'r', 'LineWidth', 2); % 在1秒时刻画红线
xline(before+(refs(j,2)-refs(j,1)), 'r', 'LineWidth', 2); 
hold off;
% xlabel('Time (seconds)');
ylabel('Frequency Bins');
title(strcat('LFP Energy -',num2str(fbandthree(1)),'~',num2str(fbandthree(2)),'Hz'));
axis tight;
% 绘制colorbar并调整其位置
h = colorbar;
set(h, 'Position', [0.93, 0.32, 0.01, 0.06]); % 手动调整colorbar位置
colormap;

% 绘制低频12-30Hz信号的能量值
subplot(8,1,7);
imagesc(time_energe, F_two, respones_on_two);
ylim([fbandtwo(1) fbandtwo(2)])
set(gca,'ydir','normal')
hold on;
xline(before, 'r', 'LineWidth', 2); % 在1秒时刻画红线
xline(before+(refs(j,2)-refs(j,1)), 'r', 'LineWidth', 2); 
hold off;
% xlabel('Time (seconds)');
ylabel('Frequency Bins');
title(strcat('LFP Energy -',num2str(fbandtwo(1)),'~',num2str(fbandtwo(2)),'Hz'));
axis tight;
% 绘制colorbar并调整其位置
h = colorbar;
set(h, 'Position', [0.93, 0.21, 0.01, 0.06]); % 手动调整colorbar位置
colormap;

% 绘制低频1-12Hz信号的能量值
subplot(8,1,8);
imagesc(time_energe, F_one, respones_on_one);
ylim([fbandone(1) fbandone(2)])
set(gca,'ydir','normal')
hold on;
xline(before, 'r', 'LineWidth', 2); % 在1秒时刻画红线
xline(before+(refs(j,2)-refs(j,1)), 'r', 'LineWidth', 2); 
hold off;
xlabel('Time (seconds)');
ylabel('Frequency Bins');
title(strcat('LFP Energy -',num2str(fbandone(1)),'~',num2str(fbandone(2)),'Hz'));
axis tight;
% 绘制colorbar并调整其位置
h = colorbar;
set(h, 'Position', [0.93, 0.11, 0.01, 0.06]); % 手动调整colorbar位置
colormap;




% 
% % 绘制colorbar并调整其位置
% h = colorbar;
% set(h, 'Position', [0.93, 0.11, 0.02, 0.18]); % 手动调整colorbar位置


     end
   end
   