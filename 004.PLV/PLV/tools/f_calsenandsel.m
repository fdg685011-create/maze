function [sensitivity,selectivity] = f_calsenandsel(respones_on)
    %% 计算敏感性（对单个类别的选择性）
    %%输入，trial，class，channel
    %输出sensitivity：class,channel；selectivity：channel
    
%     respones_on=f_normalization(respones_on,1);  %最大最小归一化
    temp=reshape(respones_on, [size(respones_on,1)*size(respones_on,2),size(respones_on,3)]);
    mean_respones=mean(temp);
    std_respones=std(temp);
    sensitivity=[];
    for j =1:size(respones_on,3)
        for i = 1:size(respones_on,2)
            temp=respones_on(:,i,j);
            mean_class=mean(temp);
            std_class=std(temp);
            sensitivity(i,j)=(mean(temp)-mean_respones(j))/sqrt(0.5*(std(temp)^2+std_respones(j)^2));
        end
    end
    %% 计算单个神经元对所有物体的选择性
    selectivity=[];
    for j =1:size(respones_on,3)
        temp=respones_on(:,:,j);
        mean_=mean(temp);
        selectivity(j)=(1-(sum(mean_)/size(mean_,2))^2/sum((mean_.^2)/size(mean_,2)))/(1-1/size(mean_,2));
    end
end

