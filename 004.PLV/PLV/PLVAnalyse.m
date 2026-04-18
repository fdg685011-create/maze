%% LFP  maze分析程序 
clc;clear;close all
addpath(genpath('tools'));
%% 设置实验参数
fs=30000;  %%采样频率
Fs=1000;   %%降采样后频率
Before = 1;    %%打标前
After = 1;   %%打标后
window_on = [Before*Fs+1,(Before+After)*Fs]; 
window_off = [1,Before*Fs]; 
%% 读取打标和神经数据
channel=[1:1:16];    
RootFile = 'E:\郑州平台\迷宫20240409';
FileList=['数据'];
dataflag=[];
bin_lfp=[];
bin_spk=[];
for i = 1:size(FileList,1)
    FullPath=fullfile(RootFile,FileList(i,:));
    day=FileList(i,end-1:end);
    disp(FullPath)
    %读取文件
    XLSXName=dir(strcat(FullPath,'/*.xlsx'));
    dbtime = xlsread(fullfile(FullPath,XLSXName.name));
    refs =dbtime(:,1)';   %%读取打标时间
    PLXName=dir(strcat(FullPath,'/*.plx'));
    Drawing = false; %是否画出单天原始图像
    [allad,tsevs,svStrobed,~] = readplx(fullfile(FullPath,PLXName.name),Drawing,day);    %%读取神经信号
    %读取LFP和spk信号
    commonmode=false;  %spike是否共模参考
    thre=4.25;         %spike的阈值，根据效果来调整
    flag='all'; %lfp,all,spike
    [bin_lfp_,bin_spk_] = obtion_matrix(allad,fs,Fs,refs,channel,Before,After,6.25,commonmode,flag);
    temp=repmat([i],size(bin_lfp_,2),1);
    dataflag=cat(1,dataflag,temp);
    bin_lfp=cat(2,bin_lfp,bin_lfp_);
%     bin_spk=cat(2,bin_spk,bin_spk_);
end

%% 是否筛选通道
% cha_choose=[1:3,6:10,14:16];
% channel=cha_choose;  %此处可以人工选通道,去除坏道，否则影响共模参考
% bin_lfp1=bin_lfp;
%  bin_lfp=bin_lfp(:,:,cha_choose);
% bin_spk=bin_spk(:,:,[1,3:16]);
%% 选择是否共模参考
% commonmode = false; %是否共模参考
% if commonmode
%     bin_lfp = reref(bin_lfp);                 %共模参考
% end
%% 构造打标前后对比矩阵
% bin_lfp_off = bin_lfp(1:Before*Fs,:,:);%%取出打标前数据
% bin_lfp_on = bin_lfp(Before*Fs+1:end,:,:);%%取出打标后数据
%% PLV
fband=[35,45];   %1:4, 5:12, 13:30, 31:40, 60:80
[plv_fea_on,plv_fea_off]=plot_PLV(bin_lfp,window_on,window_off,channel,fs,fband,Before,After,Fs);  %%继续做出一张图 plv统计学差异,先滤波，再计算PLV
[acc_mean_num,acc_mean,coeff,mu,idx,mdl]=LfpPCA(plv_fea_on(:,:,6),mean(plv_fea_off,3));   %% mean(plv_fea_on,3)选择第五个窗长降维聚类
%%
[p,hh]=Plv_net(bin_lfp,Fs,fband,Before,After);
%% 保存
PLV_class=[plv_fea_on;plv_fea_off];
newcolumn1=ones(size(plv_fea_on,1),1);
newcolumn2=zeros(size(plv_fea_off,1),1);
datalabel=[newcolumn1;newcolumn2];
save(strcat('K:\Z项目\程序\最终版新\data\classfication\',num2str(fband(1)),'-',num2str(fband(2)),'Hz','PLV_',FileList,'.mat'),'PLV_class','datalabel');
