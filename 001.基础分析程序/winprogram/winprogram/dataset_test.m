%% 清除变量
close all;
clear all;clc;
addpath(genpath('tools'));
%% 马美芳读取数据
[plx_NAMEFile,filepath,plx_FILEIndex] = uigetfile('*.plx','Select the date file','G:\新迷宫\Data');
plx_FullFilename = strcat(filepath,plx_NAMEFile);
[xlsx_NAMEFile,xlsxpath,xlsx_FILEIndex] = uigetfile('*.xlsx','Select the date file',filepath);
xlsx_FullFilename = strcat(xlsxpath,xlsx_NAMEFile);
Fs=30000;
fs=1000;
channel=1:1:16;
Drawing=false;
refs = xlsread(xlsx_FullFilename);% 读取目标打标  
[allad] = readplx(plx_FullFilename,Drawing);
sign_raw=[];
for k=1:length(channel)
        cha=channel(k);
        s=allad{1,cha};
        sign_raw=[sign_raw,s];
end    


%% 按打标对数据截取
trails_object=10;           %识别目标的试次
max_dividelength=120000;
sign_divide_array=zeros(max_dividelength,16,trails_object);
for j=1:trails_object
        A=refs(j,1)-2;
        B=refs(j,2);
        sign_raw_divide=sign_raw((A*Fs)+1:(B*Fs),:);% 切割数据
        sign_divide_array(:,:,j)=sign_raw_divide(:,:);
end

%% 
