%% 清除变量
close all;
clear all;clc;
addpath(genpath('tools'));
 %% 大工读取数据
% time = 1;%采集信号时间，单位min
% [NAMEFile,PATHFile,FILEIndex] = uigetfile('*.*','Select the date file','G:\新迷宫\Data');
% FullFilename = strcat(PATHFile,NAMEFile);
% fid = fopen(FullFilename,'rb');
% [data,count] = fread(fid,inf,'int16');
% fclose(fid);
% num = count;
% A = zeros(num,1);
% i = 1;
% j = 1;
% B = zeros(num/16, 16);
% j = 1;
% k = 1;
% for i = 1:num 
%     B( k, j) = data(i,1);
%     if j == 16
%        k = k + 1;
%        j = 1;
%     else
%        j = j + 1;
%     end
% end
% sign_raw=B;
% Fs=30000;
% fs=1000;
% channel=1:1:16;
%% 马美芳读取数据
[plx_NAMEFile,filepath,plx_FILEIndex] = uigetfile('*.plx','Select the date file','G:\新迷宫\Data');
plx_FullFilename = strcat(filepath,plx_NAMEFile);
[xlsx_NAMEFile,xlsxpath,xlsx_FILEIndex] = uigetfile('*.xlsx','Select the date file',filepath);
xlsx_FullFilename = strcat(xlsxpath,xlsx_NAMEFile);
[xlsx_NAMEFile,xlsxpath,xlsx_FILEIndex] = uigetfile('*.xlsx','Select the date file');
xlsx_FullFilename2 = strcat(xlsxpath,xlsx_NAMEFile);
trained_data=xlsread(xlsx_FullFilename2);
Fs=30000;
fs=1000;
channel=1:1:16;
Drawing=false;
refs = xlsread(xlsx_FullFilename);% 读取打标  
[allad] = readplx(plx_FullFilename,Drawing);
sign_raw=[];
for k=1:length(channel)
        cha=channel(k);
        s=allad{1,cha};
        sign_raw=[sign_raw,s];
end
 A=1;
    sign_raw_divide=sign_raw((refs(1,1)-5)*Fs:(refs(1,2)+5)*Fs,channel);% 切割数据
sign_raw_reshape=sign_raw_divide(:,channel);
%% 数据处理
output_thre=[-120;-150;-170;-120;-150;-170;-120;-150;-170;-120;-150;-170;-120;-150;-170;-170];
output_lfp_maxmin=[1 999];
output_spk_maxmin=[1 20];
load('output_coeff.mat') 
load('model.mat')
window=0.2;
step=0.2;
L=length(sign_raw);
result=[];
all_decode_data=[];
all_sign_spk_raster=[];
data_save=[];
spk_thre=1;
% num=1;
figure
for i=1:window*Fs:L
    if i+step*Fs-1<=L
    disp(strcat(num2str(i),'/',num2str(L)));
    data_raw=sign_raw(i:i+step*Fs-1,:);
    Common=false; %选择是否共模参考
    [sign_lfp_raw,sign_spk_raw] = f_read_rawdata_lfp(data_raw,Fs,fs,channel,Common); 
    %% 提取spk响应
%     digit=16;
%     if num<digit
%        data_save=[data_save;sign_spk_raw];
%     else
%        data_save(((rem(num,digit))*window*Fs)+1:((rem(num,digit)+1)*window*Fs),:)=sign_spk_raw;
%     end
%     num=num+1;
    %% SPK
    [spkdata,sign_spk_raster] = f_read_wirelessspk(sign_spk_raw,output_thre,channel,spk_thre,Fs,fs); % 读取无线spk
   %% 提取lfp响应 
   freq = [1,100];             % 时频分析的频率范围
   win=64;
   step_lfp=1;
   [data_lfp,f]=f_read_lfptf(sign_lfp_raw,channel,freq,fs,win,step_lfp);
   fband=[60,80];              % 选取的子频带
   f=f(f>=fband(1) & f<=fband(2));
   lfp_freq=data_lfp(f,:,:);
   %% 特征融合
   lfp_ch=15;
   data_lfp_ch=squeeze(mean(lfp_freq,1));
   data_lfp_ch=sum(data_lfp_ch,1);
   %data_lfp_ch=mapminmax(data_lfp_ch,output_lfp_maxmin(1),output_lfp_maxmin(2));
   sum_spk_raster=sum(sign_spk_raster);
   %sum_spk_raster=mapminmax(sum_spk_raster,output_spk_maxmin(1),output_spk_maxmin(2));
   decode_data=[sum_spk_raster,data_lfp_ch(:,lfp_ch)];
   all_sign_spk_raster=[all_sign_spk_raster;sum_spk_raster];
   all_decode_data=[all_decode_data;decode_data]; 
  
   yfit = trainedModel.predictFcn(decode_data);
   result=[result,yfit];
   scoreTrain=sum_spk_raster*output_coeff;
   scoreTrain95=scoreTrain(:,1:3);
   scatter3(scoreTrain95(:,1),scoreTrain95(:,2),scoreTrain95(:,3),'bo');
   hold on
   title('PCA降维')
    else
        disp('结束');
    end
end
figure
plot(result);
title('预测结果')
xlabel('时间')
ylabel('结果')
