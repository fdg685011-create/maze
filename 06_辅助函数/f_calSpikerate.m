function [outputdata] = f_calSpikerate(inputdata,window_on)
    %划分窗口，计算平均响应率 单位spikes/sec
    %输入[ms,trial,class,channel]
    %输出[trial class channel]
    
    outputdata=squeeze(sum(inputdata(window_on(1):window_on(2)-1,:,:,:),1))*1000/(window_on(2)-window_on(1));
    
end

