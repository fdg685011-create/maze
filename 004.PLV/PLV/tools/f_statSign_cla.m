function [p_respones] = respones_on(respones_on,kind)
    %独立样本t检验，输出单个神经元不同类别间两两组的差异性，组间校正，返回channel，class，class
    if strcmp(kind,'independentt')
        p_respones=f_independentt(respones_on);
    end
    %秩和检验，输出单个神经元不同类别间两两组的差异性，组间校正，返回channel，class，class
    if strcmp(kind,'ranksum')
        p_respones=f_ranksum(respones_on);
    end
    p_respones(isnan(p_respones))=0;
    p_respones=p_respones/((size(respones_on,2)*size(respones_on,2)-size(respones_on,2))/2);
end

