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
data_lfp_all_and_mean=[];  %20240313对比不同通道之间修改
all_data_lfp_all_and_mean=[];
data_save=[];
spk_thre=4.25;
% num=1;
%figure
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
   lfp_ch=15; %选取LFP能量通道
   data_lfp_ch=squeeze(mean(lfp_freq,1));
   data_lfp_ch=sum(data_lfp_ch,1);
   data_lfp_mean=mean((data_lfp_ch),2);

   sum_spk_raster=sum(sign_spk_raster);
   
   data_lfp_all_and_mean=[data_lfp_ch,data_lfp_mean];
   all_data_lfp_all_and_mean=[all_data_lfp_all_and_mean;data_lfp_all_and_mean];
   
   %decode_data=[sum_spk_raster,data_lfp_mean];
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
 %% 截取目标出现前后的时间段,用于构建数据集
time_beforemarking=2;
object_marking=refs(:,1);    %打标时刻
object_beforemarking=object_marking(:,1)-time_beforemarking;                                  %打标前时刻
object_aftermarking=refs(:,2);                                         %打标后试次
%refs_trails=size(object_marking,1);                                            
object_index_row=refs(:,3);                                                     %目标种类，0小车，1干扰
object_car_index=find(object_index_row==0);                                         %找到0对应的行
object_car_beforemarking=object_beforemarking(object_car_index,1);
object_car_marking=object_marking(object_car_index,1);
object_car_aftermarking=object_aftermarking(object_car_index,1);
time_object_divided=floor((object_car_aftermarking(:,1)-object_car_beforemarking(:,1))*10)/10;
object_car_aftermarking=object_car_beforemarking(:,1)+time_object_divided(:,1);
frame_rate=30;
object_frames=time_object_divided*frame_rate;
object_frames=round(object_frames);
object_trails=size(object_car_marking,1);
all_decode_lfp=all_decode_data(:,17);
mat_rootpath='C:/Users/zdy/Desktop/106-20240407/';
mkdir(mat_rootpath)
all_data_selectint=[];

for m=1:object_trails
    current_begin_position=(object_car_beforemarking(m,1)*30000)/6000;
    current_end_position=(object_car_aftermarking(m,1)*30000)/6000;
    current_object_frames=object_frames(m,1);
    
    data_select=[];
    data_selectint=[];
    train_data=[];
    normalization_traindata=[];
    Interval=(current_end_position-current_begin_position)/((current_object_frames)-1);
    
    for j=1:(current_object_frames)
        current_number=current_begin_position+Interval*(j-1);
        current_numberint=ceil(current_number);
        data_select(j)=(current_number);
        data_selectint(j)=(current_numberint);
        train_data(j)=all_decode_lfp(current_numberint,1);  
    end    
    data_selectint=data_selectint';
    all_data_selectint=[all_data_selectint;data_selectint];
    normalization_traindata=mapminmax(train_data, 0, 1);
    mat_current_trail=string(m);
    mat_filename='20240407-106-'+mat_current_trail+'.mat';
    mat_fullfilepath=fullfile(mat_rootpath,mat_filename);
    save(mat_fullfilepath, 'normalization_traindata')
    
    
end

%% 截取打标前后信号数据，作互相关图
refs_interval_lfp_data={};
refs_interval_spk_data={};
refs_beforemarking_lfp_data={};
refs_aftermarking_lfp_data={};
refs_beforemarking_spk_data={};
refs_aftermarking_spk_data={};
refs_beforetime=2;
refs_aftertime=2;
refs_trails=size(refs,1);

for aa=1:refs_trails
    %截取信号的对应采样点位置
    refs_interval_begin_row=((refs(aa,1)-refs_beforetime)*30000)/6000;
    refs_interval_marking_row=(refs(aa,1)*30000)/6000;
    refs_interval_end_row=((refs(aa,1)+refs_aftertime)*30000)/6000;
    %根据采样点位置，测算对应窗口
    refs_interval_begin_rowint=ceil(refs_interval_marking_row);
    refs_interval_marking_rowint=ceil(refs_interval_begin_row);
    refs_interval_end_rowint=ceil(refs_interval_end_row);
    %分别截取打标前后LFP、SPK，打标前LFP、SPK，达标后LFP、SPK 
    refs_interval_lfp_data{aa}=all_data_lfp_all_and_mean(refs_interval_begin_rowint:refs_interval_end_rowint,1:16);
    refs_interval_spk_data{aa}=all_sign_spk_raster(refs_interval_begin_rowint:refs_interval_end_rowint,1:16);
    refs_beforemarking_lfp_data{aa}=all_data_lfp_all_and_mean(refs_interval_begin_rowint:refs_interval_marking_rowint,1:16);
    refs_aftermarking_lfp_data{aa}=all_data_lfp_all_and_mean(refs_interval_marking_rowint:refs_interval_end_rowint,1:16);
    refs_beforemarking_spk_data{aa}=all_sign_spk_raster(refs_interval_begin_rowint:refs_interval_marking_rowint,1:16);
    refs_aftermarking_spk_data{aa}=all_sign_spk_raster(refs_interval_marking_rowint:refs_interval_end_rowint,1:16);
    
    refs_interval_lfp_data=all_data_lfp_all_and_mean(refs_interval_begin_rowint:refs_interval_end_rowint,1:16);
    refs_interval_spk_data=all_sign_spk_raster(refs_interval_begin_rowint:refs_interval_end_rowint,1:16);
    refs_beforemarking_lfp_data=all_data_lfp_all_and_mean(refs_interval_begin_rowint:refs_interval_marking_rowint,1:16);
    refs_aftermarking_lfp_data=all_data_lfp_all_and_mean(refs_interval_marking_rowint:refs_interval_end_rowint,1:16);
    refs_beforemarking_spk_data=all_sign_spk_raster(refs_interval_begin_rowint:refs_interval_marking_rowint,1:16);
    refs_aftermarking_spk_data=all_sign_spk_raster(refs_interval_marking_rowint:refs_interval_end_rowint,1:16);
    
    
    
    corr_matrix_before_spkspk=corrcoef( refs_beforemarking_spk_data,refs_beforemarking_spk_data);
    corr_matrix_before_spklfp=corrcoef( refs_beforemarking_spk_data,refs_beforemarking_lfp_data);
    corr_matrix_before_lfplfp=corrcoef( refs_beforemarking_lfp_data,refs_beforemarking_lfp_data);
    corr_matrix_after_spkspk=corrcoef( refs_aftermarking_spk_data,refs_aftermarking_spk_data);
    corr_matrix_after_spklfp=corrcoef( refs_aftermarking_spk_data,refs_aftermarking_lfp_data);
    corr_matrix_after_lfplfp=corrcoef( refs_aftermarking_lfp_data,refs_aftermarking_lfp_data);
    corr_matrix_interval_spkspk=corrcoef(refs_interval_spk_data,refs_interval_spk_data);
    corr_matrix_interval_spklfp=corrcoef(refs_interval_spk_data,refs_interval_lfp_data);
    corr_matrix_interval_lfplfp=corrcoef(refs_interval_lfp_data,refs_interval_lfp_data);
    subplot(3,3,1)
    figure;
    heatmap(corr_matrix_before_spkspk, 'Colormap', jet, 'ColorLimits', [-1 1], 'XData', {'ch1', 'ch2', 'ch3', 'ch4', 'ch5','ch6', 'ch7', 'ch8', 'ch9', 'ch10','ch11', 'ch12', 'ch13', 'ch14', 'ch15', 'ch16'}, 'YData', {'ch1', 'ch2', 'ch3', 'ch4', 'ch5','ch6', 'ch7', 'ch8', 'ch9', 'ch10','ch11', 'ch12', 'ch13', 'ch14', 'ch15', 'ch16'});
    title('before-markingspk-spk');
    
    subplot(3,3,2)
    figure;
    heatmap(corr_matrix_after_spkspk, 'Colormap', jet, 'ColorLimits', [-1 1], 'XData', {'ch1', 'ch2', 'ch3', 'ch4', 'ch5','ch6', 'ch7', 'ch8', 'ch9', 'ch10','ch11', 'ch12', 'ch13', 'ch14', 'ch15', 'ch16'}, 'YData', {'ch1', 'ch2', 'ch3', 'ch4', 'ch5','ch6', 'ch7', 'ch8', 'ch9', 'ch10','ch11', 'ch12', 'ch13', 'ch14', 'ch15', 'ch16'});
    title('after-markingspk-spk');

    subplot(3,3,3)
    figure;
    heatmap(corr_matrix_interval_spkspk, 'Colormap', jet, 'ColorLimits', [-1 1], 'XData', {'ch1', 'ch2', 'ch3', 'ch4', 'ch5','ch6', 'ch7', 'ch8', 'ch9', 'ch10','ch11', 'ch12', 'ch13', 'ch14', 'ch15', 'ch16'}, 'YData', {'ch1', 'ch2', 'ch3', 'ch4', 'ch5','ch6', 'ch7', 'ch8', 'ch9', 'ch10','ch11', 'ch12', 'ch13', 'ch14', 'ch15', 'ch16'});
    title('both-markingspk-spk');

    subplot(3,3,4)
    figure;
    heatmap(corr_matrix_before_spklfp, 'Colormap', jet, 'ColorLimits', [-1 1], 'XData', {'ch1', 'ch2', 'ch3', 'ch4', 'ch5','ch6', 'ch7', 'ch8', 'ch9', 'ch10','ch11', 'ch12', 'ch13', 'ch14', 'ch15', 'ch16'}, 'YData', {'ch1', 'ch2', 'ch3', 'ch4', 'ch5','ch6', 'ch7', 'ch8', 'ch9', 'ch10','ch11', 'ch12', 'ch13', 'ch14', 'ch15', 'ch16'});
    title('before-markingspk-lfp');

    subplot(3,3,5)
    figure;
    heatmap(corr_matrix_after_spklfp, 'Colormap', jet, 'ColorLimits', [-1 1], 'XData', {'ch1', 'ch2', 'ch3', 'ch4', 'ch5','ch6', 'ch7', 'ch8', 'ch9', 'ch10','ch11', 'ch12', 'ch13', 'ch14', 'ch15', 'ch16'}, 'YData', {'ch1', 'ch2', 'ch3', 'ch4', 'ch5','ch6', 'ch7', 'ch8', 'ch9', 'ch10','ch11', 'ch12', 'ch13', 'ch14', 'ch15', 'ch16'});
    title('after-marking(spk-lfp)');

    subplot(3,3,6)
    figure;
    heatmap(corr_matrix_interval_spklfp, 'Colormap', jet, 'ColorLimits', [-1 1], 'XData', {'ch1', 'ch2', 'ch3', 'ch4', 'ch5','ch6', 'ch7', 'ch8', 'ch9', 'ch10','ch11', 'ch12', 'ch13', 'ch14', 'ch15', 'ch16'}, 'YData', {'ch1', 'ch2', 'ch3', 'ch4', 'ch5','ch6', 'ch7', 'ch8', 'ch9', 'ch10','ch11', 'ch12', 'ch13', 'ch14', 'ch15', 'ch16'});
    title('both-markingspk-lfp');

    subplot(3,3,7)
    figure;
    heatmap(corr_matrix_before_lfplfp, 'Colormap', jet, 'ColorLimits', [-1 1], 'XData', {'ch1', 'ch2', 'ch3', 'ch4', 'ch5','ch6', 'ch7', 'ch8', 'ch9', 'ch10','ch11', 'ch12', 'ch13', 'ch14', 'ch15', 'ch16'}, 'YData', {'ch1', 'ch2', 'ch3', 'ch4', 'ch5','ch6', 'ch7', 'ch8', 'ch9', 'ch10','ch11', 'ch12', 'ch13', 'ch14', 'ch15', 'ch16'});
    title('before-markinglfp-lfp');
    
    subplot(3,3,8)
    figure;
    heatmap(corr_matrix_after_lfplfp, 'Colormap', jet, 'ColorLimits', [-1 1], 'XData', {'ch1', 'ch2', 'ch3', 'ch4', 'ch5','ch6', 'ch7', 'ch8', 'ch9', 'ch10','ch11', 'ch12', 'ch13', 'ch14', 'ch15', 'ch16'}, 'YData', {'ch1', 'ch2', 'ch3', 'ch4', 'ch5','ch6', 'ch7', 'ch8', 'ch9', 'ch10','ch11', 'ch12', 'ch13', 'ch14', 'ch15', 'ch16'});
    title('after-marking(lfp-lfp)');
    
    subplot(3,3,9)
    figure;
    heatmap(corr_matrix_interval_lfplfp, 'Colormap', jet, 'ColorLimits', [-1 1], 'XData', {'ch1', 'ch2', 'ch3', 'ch4', 'ch5','ch6', 'ch7', 'ch8', 'ch9', 'ch10','ch11', 'ch12', 'ch13', 'ch14', 'ch15', 'ch16'}, 'YData', {'ch1', 'ch2', 'ch3', 'ch4', 'ch5','ch6', 'ch7', 'ch8', 'ch9', 'ch10','ch11', 'ch12', 'ch13', 'ch14', 'ch15', 'ch16'});
    title('both_marking(lfp-lfp)');
end

