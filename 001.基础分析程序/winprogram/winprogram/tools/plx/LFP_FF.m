clc
close all
%% 设置实验参数
fs=30000;
Fs=1000;
befo_STI = 2;
befo_door = 2;
cha=[1:1:16];
[NAMEFile,PATHFile,FILEIndex] = uigetfile('*.xlsx','Select the date file','D:\王虎\数据');
dbtime = xlsread(strcat(PATHFile,NAMEFile));
refs =dbtime(:,1)';

[allad,tsevs,svStrobed,~] = readplx(fullfile(PATHFile,strcat(NAMEFile(1:end-5),'.plx')));
%% 设置去噪滤波参数
% [b1,a1] = butter(2,2*250/fs,'low');
[b1,a1] = butter(2,[1 250]/(fs/2));  %带通滤波器，阶数为8，通带为1-250Hz，用来得到LFP信号
[b2,a2] = butter(2,2*[250 4999]/fs);
m = fs/2;
wp  = [1 999]/m;%陷波器通带频率归一化处理
ws1 = [49 51]/m;%陷波器阻带频率归一化处理 ， 中心陷波频率为 50Hz
ws2 = [99 101]/m;%陷波器阻带频率归一化处理 ， 中心陷波频率为 50Hz
rp = 3;%通带衰减取 3dB
rs = 20;%阻带衰减取 20dB
[n,wn]  = buttord(wp,ws1,rp,rs);% 确定巴特沃斯滤波器的最低阶数和截止频率
[n1,wn1]  = buttord(wp,ws2,rp,rs);% 确定巴特沃斯滤波器的最低阶数和截止频率
[b3,a3] = butter(n,wn,'stop');%确定巴特沃斯陷波器
[b4,a4] = butter(n1,wn1,'stop');%确定巴特沃斯陷波器
%% 数据截断,构造bin_lfp、bin_spk
datalfp=[];
dataspk=[];
bin_lfp = zeros((befo_STI+befo_door)*Fs,length(refs),length(cha));
bin_spk = zeros((befo_STI+befo_door)*fs,length(refs),length(cha));
for r=1:length(refs)
    for k=1:length(cha)  
       s=allad{1,k}';
       datays = s((refs(r) - befo_STI)*fs + 1:(refs(r) + befo_door)*fs);
       ss= filtfilt(b3,a3,datays);
       ss= filtfilt(b4,a4,ss);
       lfpdata=resample(filtfilt(b1,a1,ss),Fs,fs); %降采样
       datalfp=[datalfp;lfpdata];
       spkdata =filtfilt(b2,a2,ss);
       dataspk=[dataspk;spkdata];
%        ysdata1=[ysdata1,datays];
    end
bin_lfp(:,r,:) = datalfp';
bin_spk(:,r,:) = dataspk';
datalfp=[];
dataspk=[];
end
%% 选择是否共模参考。
channel=cha';
commonmode = false; %是否共模参考
if commonmode
    channel=channel([1:1:16],:);  %此处可以人工选通道,去除坏道，否则影响共模参考
    bin_lfp=bin_lfp(:,:,[1:1:16]);
    bin_lfp = reref(bin_lfp);                 %共模参考
end
%% 神经信号与打标类别对应
    bin_lfp_off = bin_lfp(1:befo_STI*Fs,:,:);%%取出打标前数据
    bin_lfp_on = bin_lfp(befo_STI*Fs+1:end,:,:);%%取出打标后数据
   
%% 绘制功率谱
frequencies = 1:50;  %所要分析的频带
plot_powerspectrum(bin_lfp_on,bin_lfp_off,Fs,frequencies,channel);
%% 绘制时频 输出[f,ms,trial,channel]
fscale=1:250; %分析频带的点数   
Fs=1000;
timefrequencyflag='cmor3-3';  %128,'cmor5-5','mexh'等小波，int型是stft，str型是小波
summean=false;   %是否减均值
[respones_on,F,T]=f_caltimefrequency(bin_lfp,fscale,Fs,timefrequencyflag,summean);

% imagesc(T,F,respones_on(:,:,1,1));
% set(gca,'ydir','normal')

%% 选择频带和时间窗
fband=[1,250];   %1:4, 5:12, 13:30, 31:40, 60:80
respones_on_= [];
F=round(F);
F_=find(F(1,:)>=fband(1) & F(1,:)<=fband(2));
F__=F(F_(1):F_(end));
respones_on_ = respones_on(F_(1):F_(end),:,:,:);
sum_on_= squeeze(mean(respones_on_,1));
window_on = [befo_STI*Fs+1,(befo_STI+befo_door)*Fs];   %刺激出现后的时间段
window_off = [1,befo_STI*Fs]; 
sum_on = squeeze(mean(sum_on_(window_on(1):window_on(2),:,:),1)); 
sum_off = squeeze(mean(sum_on_(window_off(1):window_off(2),:,:),1)); 
P= f_statSign(sum_on,sum_off);
pp=P(1,:);
TT = linspace(-befo_STI,befo_door,(befo_STI+befo_door)*Fs);
Cha=cha';
%% PLV
plot_PLV(respones_on_,window_on,window_off)
%% 所有试次叠加的图
colornorm=true;
plot_lfpsumtrial(respones_on_,F__,TT,fband,Cha,colornorm)
% 频率叠加，试次并列
plot_lfpsumfreq(respones_on_,TT,fband,Cha)
%% lfp能量响应曲线图，每个试次一个曲线，并画出平均曲线
plot_lfpfiringrate_line(respones_on_,Cha,fband,window_on,window_off,pp)
%% lfp平均和标准差点线图
% st=25;
% plot_lfpfiringrate_scatter(respones_on_,Cha,fband,window_on,window_off,pp,st)
%% 统计类别间的显著性差异
% 计算神经元的选择性和敏感性
% sum_sub1=sum_on-sum_off;

sum_sub = zeros(length(refs),2,length(cha));
sum_sub(:,1,:)=sum_on;
sum_sub(:,2,:)=sum_off;
ClassName = ["on" "off" ];
[sensitivity,selectivity] = f_calsenandsel(sum_sub);
plot_responseratebar(sum_sub,pp,ClassName,channel,sensitivity,selectivity,'LfpPower');%% 最高和最低响应对比