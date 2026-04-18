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
                h = vartest2(a,b);  %0表示方差齐性
                if h==0
                    [h4,p4,ci4,stats4]=ttest2(a,b);
                else
                    [h4,p4,ci4,stats4]=ttest2(a,b,'Vartype','unequal'); %0表示差异不显著

                end
                p_respones(i,j,k)=p4;
            end
    %         h =jbtest(a);  %0表示服从正态分布
%             p_respones(i,j,:)=mafdr(squeeze(p_respones(i,j,:)),'BHFDR',true);   %  校正
        end
    end 
end

