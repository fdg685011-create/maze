function p_respones=f_independentt(respones_on)
  %方差齐性检验，即检验两组样本的总体方差是否相同
    %输入trail，class，channel
    %输出单个神经元不同类别间两两组的差异性，组件校正，返回channel，class，class
    p_respones=[];
    for i = 1:size(respones_on,3)
        for j = 1:size(respones_on,2)
            a=respones_on(:,j,i);
            for k = 1:size(respones_on,2)
                b=respones_on(:,k,i);
                [p,h,stats]=ranksum(a,b);
                p_respones(i,j,k)=p;
            end
    %         h =jbtest(a);  %0表示服从正态分布
        end
    end 
%     p_respones=p_respones/((size(respones_on,2)*size(respones_on,2)-size(respones_on,2))/2);
end


