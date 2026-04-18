%% 001.清空工作区间，添加工具箱至搜索路径
clc;clear;close all
addpath(genpath('Analyse-tools-YG'));

%% 002.读取原始信号及打标时刻（易格无线采集设备）
samfs = 30000;    % 采样频率
downfs = 1000;    % 降采样后频率
channel = 1:1:16;
Drawing = false;
% 读取plx原始数据文件
[plx_NAMEFile,filepath,plx_FILEIndex] = uigetfile('*.plx','Select the date file','E:\郑州平台\实验室迷宫数据之092_106_653\1.原始数据\092鸽原始数据(N)');
plx_FullFilename = strcat(filepath,plx_NAMEFile);
% 读取excel精确打标时刻
[xlsx_NAMEFile,xlsxpath,xlsx_FILEIndex] = uigetfile('*.xlsx','Select the date file',filepath);
xlsx_FullFilename = strcat(xlsxpath,xlsx_NAMEFile);
refs_temp = xlsread(xlsx_FullFilename);
refs = refs_temp(:,1:3);
% 获取所有通道原始数据
[allad] = readplx(plx_FullFilename,Drawing);
rawdata=[];
for k=1:length(channel)
        cha=channel(k);
        s=allad{1,cha};
        rawdata=[rawdata,s];
end
% 原始数据预处理得到Spike与LFP原始信号
Common=false;
[rawspk,rawlfp] = f_rawdata_preprocessing(rawdata,samfs, downfs, channel,Common);

%% 004.提取Spike特征
bin=200;
spk_thre_min = 2.5;                            % spike阈值下限
spk_thre_max = 8;                             % spike阈值上限
% p_spkthre(rawspk,spk_thre_min,spk_thre_max)                                  % 显示spk原始信号，确定spk阈值
spk_raster=f_read_raster(rawspk,samfs,downfs,spk_thre_min,spk_thre_max);     % 提取raster特征 
spk_rate=f_sl_binsl(spk_raster,bin,1);
before = 1;      % 往前的时间裕量，秒
after = 1;       % 往后的时间裕量，秒
p_spk_trial(spk_raster,spk_rate,channel,refs,before,after,downfs);
p_spk_raster(spk_raster,channel,refs,before,downfs);

%% 005.提取LFP特征
fband=1:80;              % 选取的子频带
lfp_stft=f_read_lfp(rawlfp,downfs,fband);
lfp0510=squeeze(mean(lfp_stft(5:10,:,:)));
lfp3045=squeeze(mean(lfp_stft(30:45,:,:)));
lfp6080=squeeze(mean(lfp_stft(60:80,:,:)));
fband=[60,80]; 
before=1;      % 往前往后的时间裕量，秒
after=3;
p_lfp_trial(lfp_stft,f,channel,refs,fband,downfs,before,after);

%% 试次内相关性计算(试次区间内)
Result_RootPath = strcat(filepath, 'results-试次内相关性');  % 可视化图片保存路径
mkdir(Result_RootPath);
% 滑窗窗长设定
window_length = 0.2;     %单位/秒
before=2;   %试次向前
after=5;
f_corr_trial(spk_rate, downfs, window_length, refs, before, after,Result_RootPath)

%% PCA降维聚类（全时长）
% 滑窗窗长设定
window_length = 0.2;     %单位/秒
f_PCA_allData(lfp6080, downfs, window_length, refs);