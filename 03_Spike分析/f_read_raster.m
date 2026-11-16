function [spk_raster] = f_read_raster(rawspk,samfs,downfs,spk_thre_min,spk_thre_max)
% 提取spike raster



    temp=resample(rawspk(:,1),downfs,samfs);   %用于计算降采样后尺寸
    resample_size=size(temp,1); 
    [~,channel] = size(rawspk);            %时间，通道
    times = resample_size/downfs;
    spk_raster=[];
    for ch = 1:channel
        raw_spk_ch=rawspk(:,ch);
        raw_spk_temp = raw_spk_ch;
        %补充筛掉超过阈值上限的值
        thre_max = mean(abs(raw_spk_ch))*spk_thre_max;          %找到spike阈值上限幅值
        raw_spk_ch(abs(raw_spk_ch)>thre_max) = mean(abs(raw_spk_ch));               %大于阈值上限的置0
       
        thre = -mean(abs(raw_spk_ch))*spk_thre_min;                 % 以整段数据的平均值来定义阈值
        b = find(diff(sign(diff(raw_spk_ch)))>0)+1;             % 找波谷
        trw = b(raw_spk_ch(b)<=thre);                           % 找超过阈值的波谷位置
        newid = trw(trw>20 & trw<(length(raw_spk_ch)-40));         % 删除前段和后端的位置
        newid(find(diff(newid)<(0.0016*samfs))+1)=[];           % 删除离得太近的波谷
        sk=newid/samfs;
        if length(sk)==0
            bin_spike=zeros(resample_size,1);
        else
            [bin_spike ~] = f_spk_binms(sk,downfs,[0 times]);  %raster
            bin_spike(bin_spike>0)=1;
        end
        spk_raster=[spk_raster,bin_spike];
    end
end

