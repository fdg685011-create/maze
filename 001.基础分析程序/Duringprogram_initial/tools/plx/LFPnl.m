CH1_Cecebus=allad{1,1}(2070000:21900000);  
% Route1=CH1_Cecebus';
Route1=CH1_Cecebus;
y=Route1;
theSize=size(y);
L=theSize(1);
Fs=30000;
figure_model=1;
%[fft_result ,P1 ]=self_fft(y,L,Fs,figure_model);
%%滤波器提高频
filtered_data=y';
[filtered_result]=MULTIPLE_TYPE_FILTERS(filtered_data,Fs,3,250,1);%滤波器
datalfp= detrend(resample(filtered_result,1000,30000));
%%  小波分析
t = linspace(69,73,120000);  %目标前后4s的时间段
fs=1000; % 采样频率
%%%%小波时频图绘制%%%%
wavename='cmor3-3';
totalscal=1000;
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
    s = datalfp;
    coefs=cwt(s,scal,wavename);
    %得到小波系数
    %绘制原始信号图
    figure
    imagesc(t,f(977:985),abs(coefs));
    %绘制色谱图
    colorbar;
    xlabel('时间 t/s');
    ylabel('频率 f/Hz');
%     set(gca,'ylim',[1,250])
    set(gca,'YDir','normal')
%    title(strcat('ch',num2str(mx),'-trial',num2str(fff)))


