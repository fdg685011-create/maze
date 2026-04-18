function [refs] = f_read_refs(PathFile,re)
%读出信号打标，视频和神经信号时间对齐，筛选试次时间小于阈值的试次
    num = xlsread(PathFile);
    refs=floor(num(:,2:3))*60+(num(:,2:3)-floor(num(:,2:3)))*100+re;
    refs(:,3)=num(:,1);
%     refs=refs((refs(:,2)-refs(:,1))<thre,:);
end

