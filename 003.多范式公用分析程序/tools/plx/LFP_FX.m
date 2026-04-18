% 读取.mat文件
clc
clear all
close all
load D:\王虎\数据\009_左NCL\20230720\数据\datalfp
%% 不读取.mat文件
fs=30000;
Fs=1000;
befo_STI = 2;
befo_door = 2;
cha=[1 2 3 4];
[NAMEFile,PATHFile,FILEIndex] = uigetfile('*.xlsx','Select the date file','D:\王虎\数据');
lfpdata =detrend(resample(datalfp',Fs,fs)');   %去趋势和降采样
dbtime = xlsread(strcat(PATHFile,NAMEFile));
refs =dbtime(:,1);
refs1=refs(7:11,:);    %选择试次
% num=1;
for mm=1:length(cha)
    mx = cha(mm);   
    Datachann = lfpdata(mx,:);
    for xx = 1:length(refs1)
        adata = Datachann((refs1(xx) - befo_STI)*Fs + 1:(refs1(xx) + befo_door)*Fs)';
        t = linspace(-befo_STI,befo_door,(befo_STI+befo_door)*Fs);  %目标前后时间段
%         adata=Datachann(1:end/2);
%         t = linspace(0,Duration/2,fnad);  %全时间段
        wavename='cmor3-3';%wavename='cmor5-2'; 这里5是带宽，2是中心频率
        totalscal=500;%尺度序列的长度，即scal的长度
        wcf=centfrq(wavename);%小波的中心频率，尺度和频率之间存在一个比例常数的倒数关系，称为小波的“中心频率”
        cparam=2*wcf*totalscal;%为得到合适的尺度所求出的参数
        a=totalscal:-1:1;
        scal=cparam./a;%尺度因子与小波的频率成反比，尺度因子越大，小波就会被拉伸变长，那么小波的频率就会变小
        f=scal2frq(scal,wavename,1/Fs);%将尺度转换为实际频率
        cc=find(f(1,:)>=8 & f(1,:)<=12);
        %得到各个尺度，以使转换得到频率序列为等差序列
        ss = adata;
        coefs=cwt(ss,scal,wavename);%得到小波系数
        %绘制原始信号图
        figure
%         subplot(length(cha),length(refs1),num)
        imagesc(t,f(cc(1):cc(end)),abs(coefs(cc(1):cc(end),:)));%绘制色谱图
        colorbar;
        xlabel('时间 t/s');
        ylabel('频率 f/Hz');
        ymin=f(cc(end));
        ymax=f(cc(1));
        set(gca,'ylim',[ymin,ymax])
        set(gca,'YDir','normal')
        title(strcat('ch',num2str(mx),'-trial',num2str(xx))) 
%         num=num+1;
    end
end
% nl=abs(coefs(cc(1):cc(end),:));
% nl_1=mean(nl,1);
% Data = mapminmax(nl_1,0,1);
