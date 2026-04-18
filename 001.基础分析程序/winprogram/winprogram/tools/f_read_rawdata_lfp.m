function [sign_lfp_raw,sign_spk_raw,time,channel] = f_read_rawdata_lfp(data_raw,samfs,downfs,channel,Common)
%F_READ_RAWDATA 读取数据的原始信号，和滤波后的spk信号、lfp信号(降采样)
%   输入：nsx文件的地址，转换为double类型的原始数据，时间×通道；
%   输出：滤波后的spk和lfp，经过去工频；
%   输出：信号的采样点长度和通道数。
    %% 读取nsx文件
    %     nsxfile = dir(fullfile(filepath,'*.ns6'));                          % nsx文件地址
    %     nsx = openNSx('read',fullfile(filepath,nsxfile.name),'p:int16');    % 读入nsx文件
    %     sign_raw=double(nsx.Data');                                         % 原始信号，时间×通道
    %% 滤波参数设置，得到spk和lfp原始信号
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
    ws3 = [149 151]/(samfs/2);          % 陷波器阻带频率归一化处理 ， 中心陷波频率为 150Hz
    [n,wn]  = buttord(wp,ws3,rp,rs);    % 确定巴特沃斯滤波器的最低阶数和截止频率
    [b4,a4] = butter(n,wn,'stop');      % 确定巴特沃斯陷波器
    % 滤波得到spk信号，[300 5000]
    [b5,a5] = butter(2,2*[300 5000]/samfs);  % 滤波得到高频信号
    %% 循环每个通道进行滤波
    sign_spk_raw = zeros(size(data_raw));
    [time,~] = size(data_raw);
    time = time/samfs;                              %采样时间，秒
        for ch = 1 : length(channel)
            data_ch = data_raw(:,ch);                   % 单个通道的原始数据
            data_ch = filter(b2,a2,data_ch);            % 去除工频50
            data_ch = filter(b3,a3,data_ch);            % 去除工频100
            data_ch = filter(b4,a4,data_ch);            % 去除工频150
            sign_lfp_raw(:,ch)=resample(filtfilt(b1,a1,data_ch),downfs,samfs); %低通，得到lfp信号
            sign_spk_raw(:,ch)=filtfilt(b5,a5,data_ch); %高通，得到spk信号
        end
         if Common
         common_mode_reference = mean(sign_lfp_raw,2); % 在每个时间点计算所有通道的平均值
          for ch = 1 : length(channel)
            choose_ch=sign_lfp_raw(:,ch);
            choose_ch=choose_ch-common_mode_reference;
            sign_lfp_raw(:,ch)=choose_ch; %低通，得到lfp信号
          end
         end
end

