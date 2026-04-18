clc;clear;close all
addpath(genpath('tools'));
%% 读取原始信号
samfs = 30000;    % 采样频率
downfs = 1000;    % 降采样后频率
FS=30000;
fs=1000;
% filepath = 'F:\Data\ou056\20231030\datal';                    % nsx文件地址
[plx_NAMEFile,filepath,plx_FILEIndex] = uigetfile('*.plx','Select the date file','G:\大连信号分析相关'); 
plx_FullFilename = strcat(filepath,plx_NAMEFile);
% xlsxpath = 'F:\Data\ou056\20231030\datal\056_1030_l.xlsx';                % 打标xlsx文件地址
[xlsx_NAMEFile,xlsxpath,xlsx_FILEIndex] = uigetfile('*.xlsx','Select the date file',filepath);
xlsx_FullFilename = strcat(xlsxpath,xlsx_NAMEFile);
channel=1:1:16;
Drawing=false;
refs = xlsread(xlsx_FullFilename);% 读取打标 
% 视频打标起始时刻每次需要调整
video_start= 81.8;
refs(:,[1 2]) =refs(:,[1 2])-video_start;
Common=false; %选择是否共模参考
[sign_raw,sign_lfp_raw,sign_spk_raw] = f_read_rawdata_lfp(plx_FullFilename,samfs,downfs,channel,Common,Drawing);  % 读取原始信号并筛选通道
% 全时段原始信号图
% filesavepath = strcat(filepath,'figures\');
% p_line(sign_raw,channel,refs,'sign raw',samfs);
% print(strcat(filesavepath,'sign_raw1.emf'),'-dmeta')
% p_line(sign_lfp_raw,channel,refs,'sign lfp raw',downfs);
% print(strcat(filesavepath,'sign_lfp_raw1.emf'),'-dmeta')
% p_line(sign_spk_raw,channel,refs,'sign spk raw',samfs);
% print(strcat(filesavepath,'sign_spk_raw1.emf'),'-dmeta')
%% 提取lfp响应 
freq = [1,150];             % 时频分析的频率范围
window=256;
step=1;
before=1;      % 往前往后的时间裕量，秒
after=1;
[data_sz,f]=f_read_lfptf(sign_lfp_raw,channel,freq,downfs,window,step,refs,before,after);
% lfp发放率，全时间段
fband=[60,80];              % 选取的子频带
%  sign_lfp_rate = squeez1e(mean(sign_lfp_tf(f(f>=fband(1) & f<=fband(2)),:,:),1));
%  sign_lfp_rate=f_sl_binsl(sign_lfp_rate,200,1);
% p_line(sign_lfp_rate,channel,refs,'sign lfp rate',downfs);
% print(strcat(filesavepath,'sign_lfp_rate.emf'),'-dmeta')
% 计算每个试次的lfp，分为两个方向
all_trails_lfp_intreval_60_80_mean_rate={};
object_trails=size(refs,1);
for i=channel
    for j=1:object_trails
        data_freq=data_sz{j,i};
        lfp_freq_trial=data_freq(f(f>=fband(1) & f<=fband(2)),:);
        lfp_freq_fband = mean(lfp_freq_trial,1);
        lfp_freq_fband_mean_rate=sum(lfp_freq_fband,2)*1000/(size(lfp_freq_fband,2));
        all_trails_lfp_intreval_60_80_mean_rate{j,i}=lfp_freq_fband_mean_rate;
        
        
    end
end


%% 提取spk响应
spk_thre = 4.25; % spk的阈值 可调
sorting=false; %选择是否sorting
[spkdata,sign_spk_raster] = f_read_wirelessspk(filepath,sign_spk_raw,channel,spk_thre,samfs,downfs,sorting); % 读取无线spk
% [spkdata,sign_spk_raster1refs,time] = f_read_wirespk(filepath,channel_sel,samfs,downfs);        % 读取有线spk

all_trails_spk_intreval_time_mean_rate={};
    for ch=channel
        for jj=1:object_trails
            raster_trial = sign_spk_raster(round((refs(jj,1))*fs+1):round((refs(jj,2))*fs),ch);
            spk_raster_mean_rate= sum(raster_trial,1)*1000/(size(raster_trial,1));
            all_trails_spk_intreval_time_mean_rate{jj,ch}=spk_raster_mean_rate;

        end
    end
    
    
% spk_and_lfp_rate_path = strcat(filepath,'')
% save('C:/Users/zdy/Desktop/20240117/0117-0-3.mat', 'all_trails_spk_intreval_time_mean_rate')    
