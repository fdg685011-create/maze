function [SPIKEData,datalfp,fs]=raw_spk_lfphsmm(FullFilename,selcha)
%%
%% Transforming the raw data
% if nargin == 0
%     [FileName,PathName]=uigetfile('*.nev','Select the date file','F:\ysf\实验\20190409\20190409data\1600um\Sparse_noise_RF_test\');
%   % 当用户点击打开时，[file,path] = uigetfile 将返回文件的名称和路径。如果用户点击取消或窗口关闭按钮 (X)，uigetfile 将为两个输出参数都返回 0。
%     FullFilename=strcat(PathName,FileName);
%     
% end
% [NAMEFile,PATHFile,FILEIndex] = uigetfile('*.ns5','Select the date file','F:\data\');
% 
% FullFilename = strcat(PATHFile,NAMEFile);


%[SPIKEData1, ~,~] = getSpikeDatal(strcat(FullFilename(1:end-4),'.nev'));

%nr_129 = SPIKEData{1,cell2mat(SPIKEData(4,:)) == 129};
%selcha用于分析的通道

NS3 = openNSx('read', strcat(FullFilename(1:(end-4)),'.ns4'),'p:int16');
% NEV = openNEV('read',FullFilename,'nosave','noparse');
fs = NS3.MetaTags.SamplingFreq;
cha =  NS3.MetaTags.ChannelID;
[b1,a1] = butter(2,2*250/fs,'low');
[b2,a2] = butter(2,2*[250 4999]/fs);
m = fs/2;
wp      = [1 999]/m;%陷波器通带频率归一化处理
ws      = [49 51]/m;%陷波器阻带频率归一化处理 ， 中心陷波频率为 50Hz
rp      = 3;%通带衰减取 3dB
rs      = 20;%阻带衰减取 20dB
[n,wn]  = buttord(wp,ws,rp,rs);% 确定巴特沃斯滤波器的最低阶数和截止频率
[n1,wn1]  = buttord(wp,[99 101]/m,rp,rs);% 确定巴特沃斯滤波器的最低阶数和截止频率
[b3,a3] = butter(n,wn,'stop');%确定巴特沃斯陷波器
[b4,a4] = butter(n1,wn1,'stop');%确定巴特沃斯陷波器
 %spkcha = cell2mat(SPIKEData1(4,:));
if cha(end)==138
    
cha = cha(1:end-1);%mubiao3_001
end
    % 滤波程序
for k=1:length(cha)
    s=double(NS3.Data(k,:));
%     datalfp(k,:) = filter(b1,a1,s);    
    s = filtfilt(b3,a3,s);
    s = filtfilt(b4,a4,s);
    datalfp(k,:) = detrend(resample(filtfilt(b1,a1,s),1,1));
    dataspk(k,:) = filtfilt(b2,a2,s);
%     kj=find(spkcha==cha(k));
%     if ~isempty(kj)
%     thresh(k)= SPIKEData1{3,kj};
%     else thresh(k)=NaN;
%     end
end
    datalfp=datalfp-repmat(mean(datalfp,1),length(cha),1);
%     newdataspk = dataspk;
    newdataspk=dataspk-repmat(mean(dataspk(selcha,:),1),length(cha),1);
%      newdataspk=dataspk-repmat(mean(dataspk,1),length(cha),1);
    SPIKEData={};
    t_end=size(newdataspk,2);
 for k=1:length(cha)
    demodata=newdataspk(k,:);
% figure;subplot(211);plot(dataspk(1,:));set(gca,'ylim',[-150 150])
% subplot(212);plot(newdataspk(1,:));set(gca,'ylim',[-150 150])
% hold on;line([1 size(newdataspk,2)],[-25 -25])
thre = -mean(abs(demodata((t_end-fs):t_end)))*5;
b = find(diff(sign(diff(demodata)))>0)+1;  
ba=(demodata(b)<=thre);
trw = b(ba);
newid    = trw(trw>20 & trw<(length(demodata)-40));
    newid(find(diff(newid)<(0.0016*fs))+1)=[];
    if length(newid)>0
    trw  = repmat(newid',1,round(0.0016*fs))+repmat(-6:9,length(newid),1);%获得spk采样点
    else
        trw  = [];
    end
    waveform = demodata(trw); % 获得spk
SPIKEData{1,k} = newid'/fs;                          % 获得spk发放时刻，单位为s
SPIKEData{2,k}=waveform;  

SPIKEData{3,k}=thre;
SPIKEData{4,k}=cha(k);
% figure;plot(demodata);hold on;
% plot(newid,ones(length(newid),1)*thre,'o');
% set(gca,'ylim',[-100 100]);hold on;
% line([0 length(demodata)],[thre thre]);
%line([0 length(demodata)],[-21 -21]);
% plot(SPIKEData{1,2}*fs,ones(length(SPIKEData{1,2}),1)*(-21),'ro');

end

% sti_time = NEV.Data.SerialDigitalIO.TimeStampSec';

%savepath=strcat(FullFilename(1:(end-4)),'\');
