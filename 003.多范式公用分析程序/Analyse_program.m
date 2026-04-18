clc;clear;close all
addpath(genpath('tools'));
%% 读取原始信号
samfs = 30000;    % 采样频率
downfs = 1000;    % 降采样后频率
[plx_NAMEFile,filepath,plx_FILEIndex] = uigetfile('*.plx','Select the date file','E:\郑州平台\实验室迷宫数据之092_106_653\1.原始数据\092鸽原始数据(N)');
plx_FullFilename = strcat(filepath,plx_NAMEFile);
[xlsx_NAMEFile,xlsxpath,xlsx_FILEIndex] = uigetfile('*.xlsx','Select the date file',filepath);
channel=1:1:16;
Drawing=false;
Common=false; %选择是否共模参考
[sign_raw,sign_lfp_raw,sign_spk_raw] = f_read_rawdata_lfp(plx_FullFilename,samfs,downfs,channel,Common,Drawing);  % 读取原始信号并筛选通道

%% 读取打标时刻
xlsx_FullFilename = strcat(xlsxpath,xlsx_NAMEFile);
refs = xlsread(xlsx_FullFilename);% 读取打标 

%% 提取lfp响应 
fband=1:80;              % 选取的子频带
lfp_stft=f_read_lfp(sign_lfp_raw,downfs,fband);
lfp6080=squeeze(mean(lfp_stft(60:80,:,:)));

%% 提取spk响应
bin=100;
spk_thre = 2.5; % spk的阈值 可调
sorting=false; %选择是否sorting
[spkdata,sign_spk_raster,all_ch_thre] = f_read_wirelessspk(filepath,sign_spk_raw,channel,spk_thre,samfs,downfs,sorting); % 读取无线spk
sign_spk_rate = f_sl_binsl(sign_spk_raster,bin,1);

%%