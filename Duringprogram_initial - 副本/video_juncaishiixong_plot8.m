% clc;clear;close all
addpath(genpath('tools'));

%% 参数设定
FS=30000;
fs=1000;
spk_thre=4.25;
samfs=30000;
downfs=1000;
channel=1:32;
    %% 滤波参数设置，得到spk和lfp原始信号
    
    %加载数据
     sign_raw=data';
     
    % 滤波得到lfp信号，[1 250]
    [b1,a1] = butter(2,[1 250]/(samfs/2));  % 带通滤波器，阶数为2，通带为1-250Hz，用来得到LFP信号
    % 滤除50hz
    wp = [1 999]/(samfs/2);            % 陷波器通带频率归一化处理
    ws1 = [49 51]/(samfs/2);           % 陷波器阻带频率归一化处理 ， 中心陷波频率为 50Hz
    rp = 3;                             % 通带衰减取 3dB
    rs = 20;                            % 阻带衰减取 20dB
    [n,wn]  = buttord(wp,ws1,rp,rs);    % 确定巴特沃斯滤波器的最低阶数和截止频率
    [b2,a2] = butter(n,wn,'stop');      % 确定巴特沃斯陷波器
    % 滤除100hz
    ws2 = [99 101]/(samfs/2);          % 陷波器阻带频率归一化处理 ， 中心陷波频率为 100Hz
    [n,wn]  = buttord(wp,ws2,rp,rs);    % 确定巴特沃斯滤波器的最低阶数和截止频率
    [b3,a3] = butter(n,wn,'stop');      % 确定巴特沃斯陷波器
    % 滤除150hz
    ws3 = [99 101]/(samfs/2);          % 陷波器阻带频率归一化处理 ， 中心陷波频率为 150Hz
    [n,wn]  = buttord(wp,ws3,rp,rs);    % 确定巴特沃斯滤波器的最低阶数和截止频率
    [b4,a4] = butter(n,wn,'stop');      % 确定巴特沃斯陷波器
    % 滤波得到spk信号，[300 5000]
    [b5,a5] = butter(2,2*[300 5000]/samfs);  % 滤波得到高频信号
    %% 循环每个通道进行滤波
    sign_lfp_raw = zeros(size(sign_raw));
    sign_spk_raw = zeros(size(sign_raw));
    [time,~] = size(sign_raw);
    time = time/samfs;                              %采样时间，秒
        for ch = 1 : length(channel)
            data_ch = sign_raw(:,ch);                   % 单个通道的原始数据
            data_ch = filter(b2,a2,data_ch);            % 去除工频50
            data_ch = filter(b3,a3,data_ch);            % 去除工频100
            data_ch = filter(b4,a4,data_ch);            % 去除工频150
            sign_lfp_raw(:,ch)=filtfilt(b1,a1,data_ch); %低通，得到lfp信号
            sign_spk_raw(:,ch)=filtfilt(b5,a5,data_ch); %高通，得到spk信号
        end
         sign_lfp_raw = resample(sign_lfp_raw,downfs,samfs);   %降采样,时间，通道
         
%% 提取SPK响应
data=sign_spk_raw;
spkdata = {};
    sign_spk_raster=[];
    for ch = 1:length(channel)
        data_ch=data(:,ch);                         % 取通道数据
        thre = -mean(abs(data_ch))*spk_thre;                % 以整段数据的平均值来定义阈值
        b = find(diff(sign(diff(data_ch)))>0)+1;            % 找波谷
        trw = b(data_ch(b)<=thre);                          % 找超过阈值的波谷位置
        newid = trw(trw>20 & trw<(length(data_ch)-40));     % 删除前段和后端的位置
        newid(find(diff(newid)<(0.0016*samfs))+1)=[];       % 删除离得太近的波谷
        if length(newid)>0
            trw  = repmat(newid,1,round(0.0016*samfs))+repmat(-1*round(0.0016*samfs)*1/4+1:round(0.0016*samfs)*3/4,length(newid),1);%获得spk采样点
        else
            trw  = [];
        end
        waveform = data_ch(trw);            % 获得spk波形
        % 打包为结构体
        spkdata{1,ch} = newid/samfs;        % 获得spk发放时刻，单位为s
        spkdata{2,ch} = waveform;           % 48个点的spk波形
        spkdata{3,ch} = thre;               % 阈值
        spkdata{4,ch} = channel(ch);    % 通道编号
    end
    
     for ch = 1:length(channel)
        sk = spkdata{1,ch};     
        [bin_spike ~] = f_spk_binms(sk,downfs,[0,length(data_ch)/samfs]);  %1ms一个spike,返回spike的时序
        sign_spk_raster(:,ch) = bin_spike;
       end
    sign_spk_raster(sign_spk_raster>0)=1;
    
    sign_spk_rate = f_sl_binsl(sign_spk_raster,200,1);


refs=refs(1,:);
%% 做单试次图
before = 5; %%打标前5s
after = 5;   %%打标后5s
choose_ch=[1:32];
fbandone=[1,12];   %选择分析频带
fbandtwo=[13,30];   %选择分析频带
fbandthree=[30,45];   %选择分析频带
fbandfour=[60,80];   %选择分析频带
P_plot_8(choose_ch,sign_raw,sign_lfp_raw,sign_spk_raw,refs,before,after,fs,FS,fbandone,fbandtwo,fbandthree,fbandfour,spkdata,sign_spk_rate);
