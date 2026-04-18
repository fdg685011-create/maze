function [outputdata] = f_binspike(data,bin,step)
    %%按照滑动步长和窗口大小对神经数据bin化
    %%输入[ms,trial,class,channel]
    outputdata=[];
    num=1;
    for i = 1:step:(size(data,1)-bin+1)  %划分bin窗口
        outputdata(num,:,:,:)=sum(data(i:i+bin-1,:,:,:),1)*1000/bin;
        num=num+1;
    end
end

