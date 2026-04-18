%% 脚本通用三连
clc
clear all
close all
%% 基本路径设置
CD = 'D';
base = '王虎';
animal_name = 'cx\数据\06';
exp_name = '20210505';
date_info = '20210505';
BirdBiaohao = 6;
base_path = strcat(CD,':\',base,'\',animal_name,'\',date_info,'\',exp_name,'\');
abso_path = strcat(CD,':\',base,'\',animal_name,'\',date_info,'\');
addpath('supfile');
Oo = 2;
%% 读取文件\ 
fs = 10000;      %采样频率
cha=[1 2 3];     %选择通道
% time=[-0.5 1];
Filename_saved = strcat(abso_path,'Oo_',num2str(BirdBiaohao),'_spkdata_',date_info,'_',exp_name,'.mat')
if ~exist(Filename_saved,'file') 
    % 没有保存好的数据就读取原始数据
[NAMEFile,PATHFile,~] = uigetfile( ...
    {'*.*',  'All Files (*.*)'}, ...
    'Select the date file', strcat(abso_path));
FullFilename = strcat(PATHFile,NAMEFile);
[SPIKEData,datalfp,fs]=raw_spk_lfphsmm(FullFilename,cha);
save(Filename_saved,'SPIKEData','datalfp')
    save(Filename_saved,'SPIKEData','datalfp')
else
    load(Filename_saved,'SPIKEData','datalfp')
end
N_FFT=1024;
Fs = 1000;
f1=1;
f2=250;
befo_STI = 2;
befo_door = 2;
% Fs_rate = fs/Fs;
% datalfp =detrend(resample(datalfp',1,Fs_rate)');
 datalfp =detrend(resample(datalfp',Fs,fs)');   %去趋势和降采样
[NAMEFile,PATHFile,FILEIndex] = uigetfile('*.xlsx','Select the date file',abso_path);
data1 = xlsread(strcat(PATHFile,NAMEFile));
 refs =  data1(:,2);
 refs=refs(1,:);          %选择试次
 nsim = length(refs);
 
params1.tapers=[4,7];params1.pad=0;params1.Fs=Fs;params1.fpass=[30 80];
params1.err=[1 0.05];params1.trialave=1;
movingwin=[0.5 0.1];   %多窗口谱分析

for mm=1:length(cha)
    mx = cha(mm);   
    Datachann = datalfp(mx,:);
    for fff = 1:length(refs)
        adata = Datachann((refs(fff) - befo_STI)*Fs + 1:(refs(fff) + befo_door)*Fs)';
%                  %%% 频谱分析
%                         adata = adata - mean(adata);  % 去除直流分量
%                         P =fft(adata,N_FFT);
%                         y_p = P.*conj(P)/N_FFT;%conj()函数是求P函数的共轭复数，实数的共轭复数是他本身。
%                         y_f = fs*(0:N_FFT-1)/N_FFT;%变换后对应的频率的序列
%                         ni=round(f1 * N_FFT/fs+1);
%                         na=round(f2 * N_FFT/fs+1);
%                         figure
%                         hold on
%                         plot(y_f(ni:na),y_p(ni:na));
%                         title(strcat('第',num2str(mm),'通道，第',num2str(fff),'试次'))
%                        bin_Plfp(:,mm,fff) = y_p;
%                        bin_Plfp(:,mm,fff)=P([n1:n2 ]);
%     end
% end

%                          %% 功率谱分析
%        P_sd = P.*conj(P)/N_FFT;%conj()函数是求y函数的共轭复数，实数的共轭复数是他本身。
%        bin_Psd(:,mm,fff) = P_sd([n1:n2 N_FFT-n2:N_FFT-n1]);
%        subplot(212);plot(fs_p([1:128 N_FFT-127:N_FFT]),P_sd([1:128 N_FFT-127:N_FFT]));ylabel('功率谱密度');xlabel('频率');title('信号功率谱');hold on
%         close all
%         mtspc
%         [Ss,t,f,Serr]=mtspecgramc(adata,movingwin,params1);
%         subplot(3,2,f)
%         figure
%         imagesc(t,f,log10(Ss'));colorbar
%         title(strcat('ch',num2str(mx),'-trial',num2str(fff)))
%           %  S变换
%                 minfreq = 1;
%                % maxfreq = 500;
%                 maxfreq=length(adata)/2;
%                 samplingrate = 1/1000;
%                 freqsamplingrate = 1;
%                  [st,t,ff] = st_kdm(adata,minfreq,maxfreq,samplingrate,freqsamplingrate);
%                 abs_st=abs(st);
%                 abs_st=abs(st)+cos(angle(st));
%              
%                 figure
%         
% %                 pcolor(t,ff,abs_st(:,:))
% %                 colormap jet
% %                   title(strcat('通道： ',num2str(mx),' - 试次： ',num2str(fff)))
%                 imagesc(t,ff,abs_st(:,:));colorbar        
%                 title(strcat('通道： ',num2str(mx),' - 试次： ',num2str(fff)))
% %                 bin_Plfp(:,:,f,mm) = abs_st;
% %                 bin_lfp_(:,f,mm) = adata;
%%  小波分析
t = linspace(-2,2,8000);  %目标前后4s的时间段
fs=1000; % 采样频率
%%%%小波时频图绘制%%%%

wavename='cmor3-3';

totalscal=256;

%尺度序列的长度，即scal的长度

wcf=centfrq(wavename);

%小波的中心频率

cparam=2*wcf*totalscal;

%为得到合适的尺度所求出的参数

a=totalscal:-1:1;

scal=cparam./a;
f=scal2frq(scal,wavename,1/fs);

%将尺度转换为频率

%得到各个尺度，以使转换得到频率序列为等差序列

    s = adata;
    coefs=cwt(s,scal,wavename);
    %得到小波系数
    %绘制原始信号图

    figure
    imagesc(t,f,abs(coefs));
    %绘制色谱图
    colorbar;
    xlabel('时间 t/s');
    ylabel('频率 f/Hz');
    set(gca,'ylim',[0,80])
    set(gca,'YDir','normal')
   title(strcat('ch',num2str(mx),'-trial',num2str(fff)))


    end
end
% % 秩合检验
% 
%  BBB=abs(coefs);
%  H0=BBB(:,1:3000);
%  H1=BBB(:,3000:6000);
%  [h,p,ci]=ttest2(H0,H1);