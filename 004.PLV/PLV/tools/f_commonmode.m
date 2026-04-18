function [outputdata] = f_commonmode(inputdata)
    %%将所有通道全部发放的删除
    
    multiply_on=ones(size(inputdata,1),size(inputdata,2));
    nchannel=size(inputdata,3);
    for i =1:nchannel
        multiply_on=inputdata(:,:,i).*multiply_on;
    end
    outputdata=inputdata.*~multiply_on;
end

