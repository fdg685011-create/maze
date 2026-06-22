function [label] = f_make_label(data,ref,fs,bin)
%P_MAKE_LABEL 此处显示有关此函数的摘要
%   此处显示详细说明
    [time,channel]=size(data);
    label=zeros(size(data));
    for ch = 1:channel
        refs=ref;
        data_ch = data(:,ch);
        data_ch = f_sl_binsl(data_ch,bin,1);
%         refs(:,1)=refs(:,1)-1;
%         refs(:,2)=refs(:,2)+1;
        smooth_data_ch = smoothdata(data_ch);   
        [peak_val,peak_loc]=findpeaks(smooth_data_ch);   % 寻找波峰

        label_target=zeros(length(data_ch),1);
        for r = 1:length(refs)
            peaks=zeros(length(data_ch),1);
            peaks(peak_loc)=peak_val;
            temp = zeros(length(data_ch),1);
            temp(round(refs(r,1)*fs+1):round(refs(r,2)*fs),:) = 1;
            peaks = temp.*peaks;
            [maxv,maxl] = max(peaks);
            label_target(maxl) = maxv;
        end
        label_target(label_target>0)=1;
        convf = ones(bin,1);
        label_target=convn(label_target, convf, 'same');

        label_other=zeros(length(data_ch),1);
        peaks=zeros(length(data_ch),1);
        peaks(peak_loc)=peak_val;
        label_other=peaks.*~label_target;
        label_other(label_other>0)=1;
        convf = ones(bin,1);
        label_other=convn(label_other, convf, 'same');
        label_other(label_other>0)=1;
        label_other=label_other.*~label_target; 

        convf = ones(bin*2,1);
        label_target=convn(label_target, convf, 'same');
        label_target(label_target<max(label_target))=0;
        label_target(label_target>0)=1;
        label_other=label_other.*~label_target;

        label_baseline=zeros(length(data_ch),1);
        label_baseline=~(label_baseline+label_other+label_target);

        label_=label_baseline*0+label_other*1+label_target*2;
        label(:,ch)=label_;
    end
end

