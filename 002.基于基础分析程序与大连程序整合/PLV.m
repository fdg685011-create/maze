%% 001.清空工作区间，添加工具箱至搜索路径
clc;clear;close all
addpath(genpath('Analyse-tools-YG'));

%% 002.设置实验参数
fs=30000;  %%采样频率
Fs=1000;   %%降采样后频率
Before = 1;    %%打标前
After = 1;   %%打标后
window_on = [Before*Fs+1,(Before+After)*Fs]; 
window_off = [1,Before*Fs]; 
channel = 1:1:16;

%% 003.读取原始信号及打标时刻（易格无线采集设备）
dataflag=[];
bin_lfp=[];
bin_spk=[];
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
