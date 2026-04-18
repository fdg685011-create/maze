
function [] = p_showtrial(rawdata,rawspk,rawlfp,spk_rate,lfp0510,lfp3045,lfp6080,refs_Time, inter,fband_Zero, fband_One,fband_Two,samfs,downfs,choose_trail,choose_ch,rootpath,Channel_choose,Trail_choose)
%% 程序说明
%输入包括

% 原始:
% 原始spk:
% 原始lfp;
% spk发放率;
% 30-45hz的时频;
% 30-45的平均lfp能量;
% 60-80hz的时频:
% 60-80的平均lfp能量;
%需要由先前预处理的数据得到rawdata、rawspk、rawlfp
%基本参数选定
        before=inter(1);
        after=inter(2);
        fs = downfs;
        Fs = samfs;
        refs=refs_Time;


if Trail_choose                                          %若未选定试次筛选，默认选取全部试次；
    len_choose_trail = length(choose_trail);
else
    choose_trail = 1:size(refs,1);
    len_choose_trail = length(choose_trail);
end


if Channel_choose                                        %若未选定通道筛选，暂定选取32个通道
    len_choose_ch = length(choose_ch);
else
    choose_ch = 1:16;
    len_choose_ch = length(choose_ch);
end



%    for m=1:len
%        mm = choose_ch(m);
%        raw = sign_raw(:,mm);
%        lfp_ch = sign_lfp_raw(:,mm);
%        spk_ch = sign_spk_raw(:,mm);
     for jj=1:len_choose_trail
            
          j = choose_trail(jj);

          for m=1:len_choose_ch
          mm = choose_ch(m);
          raw = rawdata(:,mm);
          lfp_ch = rawlfp(:,mm);
          spk_ch = rawspk(:,mm);
            
         window = 128;
         diff = (window/2)/fs;
         Ys_sj_lfp_energe = lfp_ch(round((refs(j,1) - before-diff)*fs) + 1:round((refs(j,2) + after+diff)*fs));
         Ys_sj_lfp = lfp_ch(round((refs(j,1) - before)*fs) + 1:round((refs(j,2) + after)*fs));
         Ys_sj_spk = spk_ch(round((refs(j,1) - before)*Fs) + 1:round((refs(j,2) + after)*Fs));
         Ys_sj_raw = raw(round((refs(j,1) - before)*Fs) + 1:round((refs(j,2) + after)*Fs));
         Ys_sj_spk_rate = spk_rate(round((refs(j,1) - before)*fs) + 1:round((refs(j,2) + after)*fs),:);
         Mean_sj_lfp0510 = lfp0510(round((refs(j,1) - before)*fs) + 1:round((refs(j,2) + after)*fs),:);
         Mean_sj_lfp3045 = lfp3045(round((refs(j,1) - before)*fs) + 1:round((refs(j,2) + after)*fs),:);
         Mean_sj_lfp6080 = lfp6080(round((refs(j,1) - before)*fs) + 1:round((refs(j,2) + after)*fs),:);



         
         freq = [1,100];             % 时频分析的频率范围
         step = 1;
         [s,F,T] = spectrogram(Ys_sj_lfp_energe,window,window-step,freq(1):freq(2),fs);  
         s=abs(s*2/window*2);
         % s=mapminmax(s,0,1);
         F=round(F);
         F_zero=F(F<=fband_Zero(2) & F>=fband_Zero(1));
         respones_on_zero  = s(F_zero,:);
         F_one=F(F<=fband_One(2) & F>=fband_One(1));
         respones_on_one  = s(F_one,:);
         F_two=F(F<=fband_Two(2) & F>=fband_Two(1));
         respones_on_two  = s(F_two,:);
   

% 采样率
Fs_high = Fs; % 原始信号和高频信号的采样率
Fs_low = fs; % 低频信号的采样率

% 计算时间向量
numPoints_high = length(Ys_sj_raw);
numPoints_low = length(Ys_sj_lfp);
numPoints_energe = size(respones_on_one, 2);
numPoints_spkrate = size(Ys_sj_spk_rate, 1);
numPoints_lfprate = size(Mean_sj_lfp3045, 1);

time_high = (0:numPoints_high-1) / Fs_high; % 高频信号时间向量，单位为秒
time_low = (0:numPoints_low-1) / Fs_low; 
time_energe = (0:numPoints_energe-1) / Fs_low; 
time_spkrate = (0:numPoints_spkrate-1) / Fs_low; 
time_lfprate = (0:numPoints_lfprate-1) / Fs_low;

% 创建图形窗口
h_Fig = figure('units','normalized','outerposition',[0 0 1 1],'visible','off');
sgtitle(strcat('trial-',num2str(j),'ch-',num2str(mm),'-',num2str(refs(j,3))));

%% 绘制第1张图----------------1----------------原始信号
subplot(10,1,1);
plot(time_high, Ys_sj_raw);
hold on;
xline(before, 'r', 'LineWidth', 2); % 在1秒时刻画红线
xline(before+(refs(j,2)-refs(j,1)), 'r', 'LineWidth', 2); 
hold off;
% xlabel('Time (seconds)');
ylabel('Amplitude');
title('Original Signal');
axis tight;

%% 绘制第2张图----------------2--------------原始LFP低频信号
subplot(10,1,2);
plot(time_low, Ys_sj_lfp);
hold on;
xline(before, 'r', 'LineWidth', 2); % 在1秒时刻画红线
xline(before+(refs(j,2)-refs(j,1)), 'r', 'LineWidth', 2); 
hold off;
% xlabel('Time (seconds)');
ylabel('Amplitude');
title('Low Frequency Signal');
axis tight;

%% 绘制第3张图---------------3---------------原始Spike高频信号
subplot(10,1,3);
plot(time_high, Ys_sj_spk);
hold on;
xline(before, 'r', 'LineWidth', 2); % 在1秒时刻画红线
xline(before+(refs(j,2)-refs(j,1)), 'r', 'LineWidth', 2); 

% spk_thre_ch=spkdata{3,mm};
% yline(spk_thre_ch, 'r', 'LineWidth', 0.5); % 在1秒时刻画红线

hold off;
% xlabel('Time (seconds)');
ylabel('Amplitude');
title('High Frequency Signal');
axis tight;

%% 绘制第4张图---------------4--------------Spike发放率
subplot(10,1,4);
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


%% 绘制第5张图-----------------5-------------60-80Hz频带的LFP时频图
subplot(10,1,5);
imagesc(time_energe, F_two, respones_on_two);
ylim([fband_Two(1) fband_Two(2)])
set(gca,'ydir','normal')
hold on;
xline(before, 'r', 'LineWidth', 2); % 在1秒时刻画红线
xline(before+(refs(j,2)-refs(j,1)), 'r', 'LineWidth', 2); 
hold off;
% xlabel('Time (seconds)');
ylabel('Frequency Bins');
title(strcat('LFP Energy -',num2str(fband_Two(1)),'~',num2str(fband_Two(2)),'Hz'));
axis tight;
% 绘制colorbar并调整其位置
h = colorbar;
set(h, 'Position', [0.93, 0.52, 0.01, 0.06]); % 手动调整colorbar位置
colormap;



%% 绘制第6张图-----------------6--------------60-80Hz频带的平均lfp能量
subplot(10,1,6);
Mean_sj_lfp6080_ch = mean(respones_on_two,1);
Mean_sj_lfp6080_ch=f_sl_binsl(Mean_sj_lfp6080_ch,200,1);
plot(time_low, Mean_sj_lfp6080_ch(1,1:end-1)');
hold on;
xline(before, 'r', 'LineWidth', 2); % 在1秒时刻画红线
xline(before+(refs(j,2)-refs(j,1)), 'r', 'LineWidth', 2); 
hold off;
ylabel('60-80 lfp rate');
title('single trail 60 80 Hz mean LFP rate');
axis tight;


%% 绘制第7张图-----------------7--------------30-45Hz频带的LFP时频图
subplot(10,1,7);
imagesc(time_energe, F_one, respones_on_one);
ylim([fband_One(1) fband_One(2)])
set(gca,'ydir','normal')
hold on;
xline(before, 'r', 'LineWidth', 2); % 在1秒时刻画红线
xline(before+(refs(j,2)-refs(j,1)), 'r', 'LineWidth', 2); 
hold off;
% xlabel('Time (seconds)');
ylabel('Frequency Bins');
title(strcat('LFP Energy -',num2str(fband_One(1)),'~',num2str(fband_One(2)),'Hz'));
axis tight;
% 绘制colorbar并调整其位置
h = colorbar;
set(h, 'Position', [0.93, 0.35, 0.01, 0.06]); % 手动调整colorbar位置
colormap;



%% 绘制第8张图-----------------8--------------30-45Hz频带的平均lfp能量
subplot(10,1,8);
Mean_sj_lfp3045_ch = mean(respones_on_one,1);
Mean_sj_lfp3045_ch=f_sl_binsl(Mean_sj_lfp3045_ch,200,1);
plot(time_lfprate, Mean_sj_lfp3045_ch(1,1:end-1)');
hold on;
xline(before, 'r', 'LineWidth', 2); % 在1秒时刻画红线
xline(before+(refs(j,2)-refs(j,1)), 'r', 'LineWidth', 2); 
hold off;
ylabel('30-45 lfp rate');
title('single trail 30 45 Hz mean LFP rate');
axis tight;


%% 绘制第9张图-----------------9--------------05-10Hz频带的LFP时频图
subplot(10,1,9);
imagesc(time_energe, F_zero, respones_on_zero);
ylim([fband_Zero(1) fband_Zero(2)])
set(gca,'ydir','normal')
hold on;
xline(before, 'r', 'LineWidth', 2); % 在1秒时刻画红线
xline(before+(refs(j,2)-refs(j,1)), 'r', 'LineWidth', 2); 
hold off;
% xlabel('Time (seconds)');
ylabel('Frequency Bins');
title(strcat('LFP Energy -',num2str(fband_Zero(1)),'~',num2str(fband_Zero(2)),'Hz'));
axis tight;
% 绘制colorbar并调整其位置
h = colorbar;
set(h, 'Position', [0.93, 0.19, 0.01, 0.06]); % 手动调整colorbar位置
colormap;



%% 绘制第10张图-----------------10--------------05-10Hz频带的平均lfp能量
subplot(10,1,10);
Mean_sj_lfp0510_ch = mean(respones_on_zero,1);
Mean_sj_lfp0510_ch=f_sl_binsl(Mean_sj_lfp0510_ch,200,1);
plot(time_lfprate, Mean_sj_lfp0510_ch(1,1:end-1)');
hold on;
xline(before, 'r', 'LineWidth', 2); % 在1秒时刻画红线
xline(before+(refs(j,2)-refs(j,1)), 'r', 'LineWidth', 2); 
hold off;
ylabel('5-10 lfp rate');
title('single trail 5 10 Hz mean LFP rate');
axis tight;






















%% 单试次图像保存及关闭
saved_rootpath = rootpath;
filename = strcat('trial-',num2str(j),'ch-',num2str(mm),'-',num2str(refs(j,3)));
full_savedfile_name = strcat(saved_rootpath,'\',filename,'.jpg');
print(h_Fig,'-djpeg',full_savedfile_name);
close(h_Fig)

          end
     end
   