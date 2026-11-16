function [outdata] = f_limitamp(data,amp_thre)
    thre=mean(abs(data))*amp_thre;
    thre=repmat(thre,size(data,1),1);
    outdata=min(data,thre);
end

