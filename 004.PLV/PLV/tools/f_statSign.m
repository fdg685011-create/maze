function P = f_statSign(sum_on,sum_off)
    %统计性检验，并删除响应无统计性差异的通道
    p=[];
    h=[];
    P=[];
    for i = 1:size(sum_on,2)
            a=sum_on(:,i);
            b=sum_off(:,i);
            [h_,p_,ci]=ttest2(a,b);
            p=[p,p_];
            h=[h,h_];
    end
    P(1,:)=p;
    P(2,:)=h;
end

