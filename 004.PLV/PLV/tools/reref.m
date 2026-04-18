function [channel_data_referenced] = reref(channel_data)

%输入为ms*channel
	common_mode_reference = mean(channel_data, 3); % 在每个时间点计算所有通道的平均值
    common_mode_reference=repmat(common_mode_reference,[1,1,size(channel_data,3)]);
    % 应用共模参考
    channel_data_referenced = channel_data - common_mode_reference;
end

