%% 读取.mat文件
clc
clear all
close all
load D:\王虎\数据\20230720\数据\dataspk
%% 不读取.mat文件
clear sec_spk spike_fr
befo_STI = 2;
befo_door = 2;
adfreq=30000;
cha=[7 8 9 10];
[NAMEFile,PATHFile,FILEIndex] = uigetfile('*.xlsx','Select the date file','D:\王虎\数据');
dbtime = xlsread(strcat(PATHFile,NAMEFile));
refs =dbtime(:,1);
refs1=refs(5:8,:);    %选择试次
nsim = length(refs);
microb = 0.4;
spike={};
for mm=1:length(cha)
    mx = cha(mm);   
    Datachann = dataspk(mx,:);
    for xx = 1:length(refs1)
            adata = Datachann((refs1(xx) - befo_STI)*adfreq + 1:(refs1(xx) + befo_door)*adfreq);
            Route1=adata';
            y=Route1;
            theSize=size(y);
            L=theSize(1);
            theMean=mean(abs(adata));
            theStd=std(abs(adata));
            threshold=theMean+3*theStd;
            high_fre=adata;
            num=0;
            spikes=[];
            i=12;
while i<L-36;
   if  high_fre(i)>threshold
       point0=i-11;
       point1=i+36;
       one_spike=high_fre(1,point0:point1);
       num=num+1;
       spikes=[spikes,one_spike];
       i=i+37;
   else
       i=i+1;
   end
end
        [tmp, mt]=histc(spikes, [refs(xx) - befo_STI : microb : refs(xx) + befo_door]);
        if isempty(tmp)
            tmp = zeros(bin_nums, 1);
        end
        spikerate=tmp/microb;
        sec_spk(:,xx,mm) = reshape(tmp(1:end-1),[],1);
        spike_fr(:,xx,mm)=reshape(spikerate(1:end-1),[],1);

    end
end
bin_num=(befo_STI+befo_door)/microb;
spike_fr=reshape(spike_fr,bin_num,mm,length(refs1));
 
 
for sc=1:3
     spike_fr1=spike_fr(:,:,sc);  %选择试次
 for k=1:mm
     size1=size(spike_fr1(:,k),1);
     t = linspace(-befo_STI,befo_door,size1);
     figure
     plot(t,spike_fr1(:,k))
     xlabel('时间');
     ylabel('spike发放率');
     title(strcat('通道 ', num2str(k),'-trial',num2str(sc)));
 end
end

