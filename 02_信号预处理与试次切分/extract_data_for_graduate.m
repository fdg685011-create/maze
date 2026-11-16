%% 001.清空工作区间，添加工具箱至搜索路径
clc;clear;close all
addpath(genpath('Analyse-tools-YG'));

% 002.读取原始信号及打标时刻（易格无线采集设备）
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

Common=false;

[rawdata,rawlfp,rawspk] = f_read_rawdata_lfp(plx_FullFilename,samfs,downfs,channel,Common,Drawing);  % 读取原始信号并筛选通道

%% 计算
before = 1.5;
after = 1.5;

rawlfp_0529_trial = {};
for i = 1:size(refs,1)
    current_trial_start =  round((refs(i,1)-before)*downfs)+1;
    current_trial_end = round((refs(i,1) + after)*downfs);
    rawlfp_0529_trial{i,1} = rawlfp(current_trial_start:current_trial_end,:);
    rawlfp_0529_trial{i,2} = refs(i,3);
end

save(fullfile('data','0529_data.mat'),'rawlfp_0529_trial','-v7.3');     