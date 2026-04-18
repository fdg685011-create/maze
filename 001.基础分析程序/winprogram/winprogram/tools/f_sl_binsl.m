function [outputdata,timestamp] = f_sl_binsl(data,bin,step)
    %%按照滑动步长和窗口大小对神经数据bin化
    %%输入[ms,trial,class,channel]
    time=size(data,1);
    l=length(size(data));
    timestamp=1:step:time;
    if l==2
        B = ones(bin,1);
    end
    if l==3
        B = ones(bin,1,1);
        end
    if l==4
        B = ones(bin,1,1,1);
    end
    outputdata=convn(data, B, 'same')*1000/bin;
    outputdata=outputdata(timestamp,:,:,:);
end

