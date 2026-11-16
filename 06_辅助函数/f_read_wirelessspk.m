function [spkdata,sign_spk_raster,all_ch_thre] = f_read_wirelessspk(FullPath,data,channel,spk_thre,samfs,downfs,sorting)
%F_READ_WIRELESSSPK 此处显示有关此函数的摘要
%   此处显示详细说明
    spkdata = {};
    sign_spk_raster=[];
    all_ch_thre=[];
    for ch = 1:length(channel)
        data_ch=data(:,ch);                         % 取通道数据
        thre = -mean(abs(data_ch))*spk_thre;                % 以整段数据的平均值来定义阈值
        all_ch_thre=[all_ch_thre,thre];
        b = find(diff(sign(diff(data_ch)))>0)+1;            % 找波谷
        trw = b(data_ch(b)<=thre);                          % 找超过阈值的波谷位置
        newid = trw(trw>20 & trw<(length(data_ch)-40));     % 删除前段和后端的位置
        newid(find(diff(newid)<(0.0016*samfs))+1)=[];       % 删除离得太近的波谷
        if length(newid)>0
            trw  = repmat(newid,1,round(0.0016*samfs))+repmat(-1*round(0.0016*samfs)*1/4+1:round(0.0016*samfs)*3/4,length(newid),1);%获得spk采样点
        else
            trw  = [];
        end
        waveform = data_ch(trw);            % 获得spk波形
        % 打包为结构体
        spkdata{1,ch} = newid/samfs;        % 获得spk发放时刻，单位为s
        spkdata{2,ch} = waveform;           % 48个点的spk波形
        spkdata{3,ch} = thre;               % 阈值
        spkdata{4,ch} = channel(ch);    % 通道编号
    end
        %% Spike 分类
        if sorting
FullFileName=(strcat(FullPath(1:end)));
    spiketim=[];
for k=1:16
    index = [];
    spiketim = spkdata{1,channel==k};
    spikes_all = spkdata{2,channel==k};
     if ~exist(strcat(FullFileName,'times_','ch',num2str(channel(k)),'.mat'))
        spikes = spikes_all((ismember(spiketim,spiketim)==1),:);
        index    = spkdata{1,channel==k};
        sr       = 300000;
      save(strcat(FullFileName,'ch',num2str(channel(k)),'.mat'),'spikes','index','sr');
       varargout = wave_clus;
    else
        load(strcat(FullFileName,'times_','ch',num2str(channel(k)),'.mat'));
        spiketim =cluster_class(cluster_class(:,1)==1,2);
     end
     spkdata{1,channel==k}=spiketim;
end
        end
       for ch = 1:length(channel)
        sk = spkdata{1,ch};     
        [bin_spike ~] = f_spk_binms(sk,downfs,[0,length(data_ch)/samfs]);  %1ms一个spike,返回spike的时序
        sign_spk_raster(:,ch) = bin_spike;
       end
    sign_spk_raster(sign_spk_raster>0)=1;
end

