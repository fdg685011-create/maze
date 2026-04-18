%% 脚本通用三连
clc
clear all
close all
%% 基本路径设置
CD = 'D';
base = '研究生';
animal_name = 'cx\数据\06';
exp_name = '20210505';
date_info = '20210505';
BirdBiaohao = 6;
base_path = strcat(CD,':\',base,'\',animal_name,'\',date_info,'\',exp_name,'\');
abso_path = strcat(CD,':\',base,'\',animal_name,'\',date_info,'\');
addpath('supfile');
Oo = 2;
%% 读取文件
fs = 10000;      %采样频率
cha=[1 2 4:16];    %选择通道
% time=[-0.5 1];
Filename_saved = strcat(abso_path,'Oo_',num2str(BirdBiaohao),'_spkdata_',date_info,'_',exp_name,'.mat')
if ~exist(Filename_saved,'file') 
    % 没有保存好的数据就读取原始数据
[NAMEFile,PATHFile,~] = uigetfile( ...
    {'*.*',  'All Files (*.*)'}, ...
    'Select the date file', strcat(abso_path));
FullFilename = strcat(PATHFile,NAMEFile);
%[SPIKEData,datalfp,fs]=raw_spk_lfphsmm(FullFilename,cha);
[SPIKEData, ~,~] = getSpikeDatal(strcat(FullFilename(1:end-4),'.nev'));
save(Filename_saved,'SPIKEData')
    save(Filename_saved,'SPIKEData')
else
    load(Filename_saved,'SPIKEData')
end
%% 处理SPK信号
befo_STI = 2;
befo_door = 2;
[NAMEFile,PATHFile,FILEIndex] = uigetfile('*.xlsx','Select the date file',abso_path);
data1 = xlsread(strcat(PATHFile,NAMEFile));
refs = data1(:,2);
nsim = length(refs);
microb = 0.05;
for mm=1:length(cha)
    mx = cha(mm); 
    Datachann = SPIKEData{1,mx};
%     figure  
    for m = 1:nsim
        adata = Datachann(Datachann >= refs(m) - befo_STI & ...
            Datachann <= refs(m) + befo_door);
        [tmp, mt]=histc(adata, [refs(m) - befo_STI : microb : refs(m) + befo_door]);
        if isempty(tmp)
            tmp = zeros(bin_nums, 1);
        end
         spikerate=tmp/microb;
        %                     bin_spike(:,f,mm) = tmp(1:end-1);
        sec_spk(:,m,mm) = reshape(tmp(1:end-1),[],1);
        spike_fr(:,m,mm)=reshape(spikerate(1:end-1),[],1);
    end  
end 
bin_num=(befo_STI+befo_door)/microb;
spike_fr=reshape(spike_fr,bin_num,mm,nsim);
 
 
for ff=1:5
     spike_fr1=spike_fr(:,:,ff);  %选择试次
 for k=1:mm
     figure
      plot(spike_fr1(:,k))
       xlabel('时间（50ms）');
    ylabel('spike发放率');
     title(strcat('通道 ', num2str(k),'-trial',num2str(ff)));
 end
end


%% 秩和检验

spike_fr_n=spike_fr(21:bin_num/2,:,:);       %选择检验对比的时间窗口期   目标出现前后1秒进行检验
spike_fr_y=spike_fr(bin_num/2+1:60,:,:);
%% 所有试次求均值的单通道秩和检验
spike_fr_n_s=zeros(bin_num/4,1);
spike_fr_y_s=zeros(bin_num/4,1);
for jj=1:nsim
    spike_fr_n_s= spike_fr_n_s+spike_fr_n(:,1,jj) ;  %目标出现前第一个通道所有试次的发放率总和
    spike_fr_y_s=spike_fr_y_s+spike_fr_y(:,1,jj) ;  %目标出现后第一个通道所有试次的发放率总和
end
spike_fr_n_s_a=spike_fr_n_s/nsim;   %目标出现前第一个通道所有试次的发放率均值
spike_fr_y_s_a=spike_fr_y_s/nsim;   %目标出现后第一个通道所有试次的发放率均值
 [p,h]=ranksum( spike_fr_n_s_a, spike_fr_y_s_a);
h=zeros(nsim,mm);
p=zeros(nsim,mm);
for i=1:nsim
    spike_fr_n_1=spike_fr_n(:,:,i);
    spike_fr_y_1=spike_fr_y(:,:,i);
    for j=1:mm
        spike_fr_n1=spike_fr_n_1(:,j);
        spike_fr_y1=spike_fr_y_1(:,j);
         [p(i,j),h(i,j)]=ranksum( spike_fr_n1, spike_fr_y1);
    end
end
 [rates_pca,b,c] = self_f_pca(rates',0.95);  %%%降维 
        