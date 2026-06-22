clc
clear all
close all
%% 读取.mat文件
load D:\王虎\数据\009_左NCL\20230720\数据\datalfp
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
databf=[];
dataaf=[];
for xx = 1:length(refs1)
    for mm=1:length(cha)
        mx = cha(mm);   
        Datachann = lfpdata(mx,:);
        bfdata = Datachann((refs1(xx) - befo_STI)*Fs + 1:refs1(xx)*Fs);
%         data(mx,xx,:)=adata;
        afdata = Datachann(refs1(xx)*Fs + 1:(refs1(xx) + befo_door)*Fs); 
        databf=[databf;bfdata];
        dataaf=[dataaf;afdata];
    end
%% PLV
    sig1 =databf';
    sig2 =dataaf';
    nLoc1 = size(sig1, 2); 
    nLoc2 = size(sig2, 2); 
    plv = zeros(nLoc1, nLoc1); 
    plv = zeros(nLoc2, nLoc2);
    complex_sig1 = hilbert(sig1);       %希尔波特变换
    complex_sig2 = hilbert(sig2);  
    %% 计算信号的瞬时相位和PLV值
    for i = 1:nLoc1     
        for j = 1:nLoc1      
            if i <= j 
            plv(i, j) = abs(mean(...
                exp(1i*(unwrap(angle(complex_sig1(:,i)))-...
                unwrap(angle(complex_sig1(:, j))))), 1));             
            end
        end
    end
       for i = 1:nLoc2     
        for j = 1:nLoc2      
            if i <= j 
            plv(j, i) = abs(mean(...
                exp(1i*(unwrap(angle(complex_sig2(:,i)))-...
                unwrap(angle(complex_sig2(:, j))))), 1));             
            end
        end
    end
string_name={'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16'};   %变量名称，即通道编号
xvalues = string_name;
yvalues = string_name;
figure
h = heatmap(xvalues,yvalues,plv, 'FontSize',10, 'FontName','Times New Roman');
h.Title = (strcat('PLV','-trial',num2str(xx))) ;
colormap(jet)
caxis([0 1])
databf=[];
dataaf=[];
end

