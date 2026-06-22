clc
clear all
close all
%% 读取.mat文件
load D:\王虎\数据\20230720\数据\datalfp
fs=30000;
Fs=1000;
befo_STI = 2;
befo_door = 2;
cha=[1:1:16];
[NAMEFile,PATHFile,FILEIndex] = uigetfile('*.xlsx','Select the date file','D:\王虎\数据');
lfpdata =detrend(resample(datalfp',Fs,fs)');   %去趋势和降采样
dbtime = xlsread(strcat(PATHFile,NAMEFile));
refs =dbtime(:,1);
refs1=refs(:,:);    %选择试次
datalfps=[];
for mm=1:length(cha)
    mx = cha(mm);   
    Datachann = lfpdata(mx,:);
    for xx = 1:length(refs1)
        adata = Datachann((refs1(xx) - befo_STI)*Fs + 1:(refs1(xx) + befo_door)*Fs);
%         data(mx,xx,:)=adata;
         datalfps=[datalfps,adata];
    end
   data(mm,:)=datalfps;
   datalfps=[];
end
%% PLV
 sig =data';
    nLoc = size(sig, 2); 
plv = zeros(nLoc, nLoc); 
complex_sig = hilbert(sig);       %希尔波特变换
%% 计算信号的瞬时相位和PLV值
    for i = 1:nLoc     
        for j = 1:nLoc      
            if i <= j 
            plv(i, j) = abs(mean(...
                exp(1i*(unwrap(angle(complex_sig(:,i)))-...
                unwrap(angle(complex_sig(:, j))))), 1));
            plv(j, i) = plv(i, j);              
            end
        end
    end
    string_name={'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16'};   %变量名称，即通道编号
xvalues = string_name;
yvalues = string_name;
h = heatmap(xvalues,yvalues,plv, 'FontSize',10, 'FontName','Times New Roman');
h.Title = 'PLV';
colormap(jet)
caxis([0 1])
