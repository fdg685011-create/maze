function [rawdata, rawlfp, rawspk] = f_read_rawdata_DG(filepath, samfs, downfs, channel, Common, start_time, end_time)
% 读取数据的原始信号，和滤波后的spk信号、lfp信号(降采样)
% 输入：filepath - 数据文件路径
%       samfs - 原始采样频率
%       downfs - 降采样频率
%       channel - 选择的通道
%       Common - 是否进行共模参考
%       start_time - 需要读取数据的起始时间（秒）
%       end_time - 需要读取数据的结束时间（秒）
% 输出：滤波后的spk和lfp信号

% 计算起始和结束样本点
start_sample = start_time * samfs + 1;
end_sample = end_time * samfs;

% 打开文件
fid = fopen(filepath, 'rb');

% 逐块读取数据
block_size = 1e6;  % 每次读取的样本数
rawdata = [];

% 跳过不需要的部分数据
fseek(fid, (start_sample - 1) * length(channel) * 2, 'bof');  % 跳到起始位置，2表示int16类型占用的字节数

total_samples = end_sample - start_sample + 1;  % 总样本数
processed_samples = 0;  % 已处理样本数

while ftell(fid) < (end_sample * length(channel) * 2)
    % 计算读取的样本数，确保不超过结束样本点
    samples_to_read = min(block_size, end_sample - start_sample + 1);
    
    % 读取数据块
    [data_block, count] = fread(fid, [length(channel), samples_to_read], 'int16');
    
    if count == 0
        break;
    end
    
    % 转置并添加到结果中
    rawdata = [rawdata; double(data_block')];
    
    % 更新起始位置
    start_sample = start_sample + samples_to_read;
    processed_samples = processed_samples + samples_to_read;
    
    % 计算并显示进度
    progress_percent = (processed_samples / total_samples) * 100;
    fprintf('Progress: %.2f%%\n', progress_percent);
end


fclose(fid);

%% 原始信号进行滤波得到rawspk，rawdata
% 滤波得到lfp信号，[1 250]
[b1,a1] = butter(2,[1 250]/(samfs/2));      %带通滤波器，阶数为8，通带为1-250Hz，用来得到LFP信号
% 滤波得到spk信号，[300 5000]
[b2,a2] = butter(2,[250 5000]/(samfs/2));   %滤波得到高频信号
% 滤除50hz
wp = [1 4999]/(samfs/2);                    %陷波器通带频率归一化处理
ws1 = [49 51]/(samfs/2);                    %陷波器阻带频率归一化处理 ， 中心陷波频率为 50Hz
rp = 3;                                     %通带衰减取 3dB
rs = 20;                                    %阻带衰减取 20dB
[n,wn]  = buttord(wp,ws1,rp,rs);            %确定巴特沃斯滤波器的最低阶数和截止频率
[b3,a3] = butter(n,wn,'stop');              %确定巴特沃斯陷波器
% 滤除100hz
ws2 = [99 101]/(samfs/2);                   %陷波器阻带频率归一化处理 ， 中心陷波频率为 50Hz
[n,wn]  = buttord(wp,ws2,rp,rs);            %确定巴特沃斯滤波器的最低阶数和截止频率
[b4,a4] = butter(n,wn,'stop');              %确定巴特沃斯陷波器

[times,channel] = size(rawdata);            %时间，通道

%% 循环每个通道进行滤波
rawspk = zeros(times,channel);
rawlfp = zeros(ceil(times/(samfs/downfs)),channel);

for ch = 1:channel
    % 依次应用陷波滤波器    
    data_ch = double(rawdata(:,ch));        % 取通道数据
    data_ch = filter(b3,a3,data_ch);        % 去除工频50
    data_ch = filter(b4,a4,data_ch);        % 去除工频100
    % 应用带通滤波器，得到LFP和spike信号
    raw_lfp_ch=filtfilt(b1,a1,data_ch);     % 低通, 得到lfp信号
    raw_spk_ch=filtfilt(b2,a2,data_ch);     % 高通，得到spk信号
    raw_lfp_ch=resample(raw_lfp_ch,downfs,samfs);   %降采样到1000hz
    rawspk(:,ch) = raw_spk_ch;
    rawlfp(:,ch) = raw_lfp_ch;
end

% 对LFP信号进行降采样
% rawlfp = resample(rawlfp,downfs,samfs);   %降采样到1000hz

% 共模参考去除（可选）
if Common
    common_mode_reference = mean(rawlfp, 2); % 计算所有通道的平均值
    for ch = 1 : length(channel)
        rawlfp(:, ch) = rawlfp(:, ch) - common_mode_reference;
    end
end


end

