function [filtered_result]=MULTIPLE_TYPE_FILTERS(data,srate,filter_type,high_frequency_bound,low_frequency_bound)
%综合三种不同类型的滤波器的生成以及滤波数据的输出，采用fir1函数设计（默认窗选用hamming窗），默认对输入的数据进行detrend操作
%输入参数：
%               data——要进行滤波的数据，形式为矩阵， 每一行对应着一个通道的所有数据
%               srate——要进行滤波器设计时需要获得滤波数据的采样率
%               filter_type——有三种可选输入，输入形式为数字，1对应低通滤波器，2对应高通滤波器，3对应带通滤波器
%               hign/low_frequency_bound——对应所要进行限制的频率段（即使是高/低通滤波，也同时输入两个频率点，在程序处理时会自动识别滤波器类型，忽略额外参数）
sample_rate=srate;
nyquist_freq=srate/2;
[channel,time]=size(data);
if filter_type==1%对应的滤波器形式为低通滤波器
    filter_order=3*fix(sample_rate/high_frequency_bound);%滤波器阶数为最高频率信号周期长度的三倍
    filter_weights=fir1(filter_order,high_frequency_bound/nyquist_freq);
    filtered_data=zeros(size(data));
    for i=1:channel
        filtered_data(i,:)=convn(data(i,:),filter_weights,'same');
        filtered_data(i,:)=detrend(filtered_data(i,:));
    end
end
if filter_type==2%对应的滤波器形式为高通滤波器
    filter_order=3*fix(sample_rate/low_frequency_bound);%滤波器阶数为最高频率信号周期长度的三倍
    filter_weights=fir1(filter_order,low_frequency_bound/nyquist_freq,'high');
    filtered_data=zeros(size(data));
    for i=1:channel
        filtered_data(i,:)=convn(data(i,:),filter_weights,'same');
        filtered_data(i,:)=detrend(filtered_data(i,:));
    end
end
if filter_type==3%对应的滤波器形式为带通滤波器
    filter_order=3*fix(sample_rate/low_frequency_bound);%滤波器阶数为最高频率信号周期长度的三倍
    filter_weights=fir1(filter_order,[low_frequency_bound/nyquist_freq high_frequency_bound/nyquist_freq]);
    filtered_data=zeros(size(data));
    for i=1:channel
        filtered_data(i,:)=convn(data(i,:),filter_weights,'same');
        filtered_data(i,:)=detrend(filtered_data(i,:));
    end
end
if filter_type==4%对应的滤波器形式为带阻滤波器
    filter_order=3*fix(sample_rate/low_frequency_bound);%滤波器阶数为最高频率信号周期长度的三倍
    filter_weights=fir1(filter_order,[low_frequency_bound/nyquist_freq high_frequency_bound/nyquist_freq],'stop');
    filtered_data=zeros(size(data));
    for i=1:channel
        filtered_data(i,:)=convn(data(i,:),filter_weights,'same');
        filtered_data(i,:)=detrend(filtered_data(i,:));
    end
end
    filtered_result= filtered_data;

