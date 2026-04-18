function [normalized_data] = f_normalization(respones_on,kind)
% 数据的标准化（归一化）处理
% 参数 source_data 可用格式的源数据
% 参数 kind 代表何种归一化, 默认为1. 1代表Min-Max标准化,2代表Z-score标准化.
% 返回归一化后的数据

if nargin < 2 % 如果参数少于2个,默认进行Min-Max标准化
    kind = 1; 
end

% data=[respones_on;respones_off];
data = respones_on;
%% Min-Max标准化(Min=0,Max=1)
if kind == 1
    max_=max(max(max(data)));
    min_=min(min(min(data)));
    normalized_data=(data-min_)/(max_-min_);
end

%% Z-score标准化
if kind == 2
    mea = mean(mean(mean( data )));
    st = std(std(std( data )));
    normalized_data = ( data-mea ) / st;
end

% normalized_on=normalized_data(1:size(respones_on,1),:,:);
% normalized_off=normalized_data(size(respones_on,1)+1:end,:,:);
end


