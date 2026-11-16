function [refs, equipment_start_time] = f_timechange(fullpath)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明


% 读取选择的 Excel 文件
[~, ~, raw] = xlsread(fullpath);

% 解析数据
start_time = raw{1, 1}; % 第一行的起始时间
num_trials = size(raw, 1) - 1; % 计算试次数量（去掉第一行）
relative_times = cell(num_trials, 3); % 初始化存储相对时间的数组

% 将时间字符串解析为小时、分钟、秒
[start_hour, start_min, start_sec] = parse_time(start_time);

% 将起始时刻由XX.XX.XX形式转换为XX:XX:XX
time_strs = {num2str(start_hour,'%02d'), num2str(start_min,'%02d'), num2str(start_sec,'%02d')};  
equipment_start_time = strjoin(time_strs,':');

% 遍历每个试次，计算相对时间（秒）
for i = 2:size(raw, 1)
    trial_start_time = raw{i, 1};  % 试次的开始时间
    trial_end_time = raw{i, 2};    % 试次的结束时间
    label = raw{i, 3};             % 保留标签
    
    % 解析开始时间和结束时间
    [start_hour_trial, start_min_trial, start_sec_trial] = parse_time(trial_start_time);
    [end_hour_trial, end_min_trial, end_sec_trial] = parse_time(trial_end_time);
    
    % 计算相对起始时间和结束时间（以秒为单位）
    relative_start_time = (start_hour_trial - start_hour) * 3600 + (start_min_trial - start_min) * 60 + (start_sec_trial - start_sec);
    relative_end_time = (end_hour_trial - start_hour) * 3600 + (end_min_trial - start_min) * 60 + (end_sec_trial - start_sec);
    
    % 将结果存入数组
    relative_times{i-1, 1} = relative_start_time;
    relative_times{i-1, 2} = relative_end_time;
    relative_times{i-1, 3} = label;

end

refs = cell2mat(relative_times);
















end