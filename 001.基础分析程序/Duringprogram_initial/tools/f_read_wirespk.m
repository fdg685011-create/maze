function [spkdata,sign_spk_raster,refs,time] = f_read_wirespk(filepath,channel,samfs,downfs)
%F_READ_WIRESPK 此处显示有关此函数的摘要
%   此处显示详细说明
    % 读取nsx文件，获取采样时间
    nsxfile = dir(fullfile(filepath,'*.ns6'));                                  % nsx文件地址
    nsx = openNSx('read',fullfile(filepath,nsxfile.name),'p:int16');            % 读入nsx文件
    [~,time] = size(nsx.Data);
    time = time/samfs;                                                          %采样时间，秒
    % 读取nev文件，获取spike响应
    nevfile = dir(fullfile(filepath,'*.nev'));                                  % nev文件地址
    nev=openNEV('read',fullfile(filepath,nevfile.name),'nosave','noparse');     % 读取nev数据
    refs = double(nev.Data.SerialDigitalIO.TimeStampSec);                       % 打标时刻，秒
    temp=double(nev.Data.Spikes.Electrode);    
    temp2=sortrows([temp,[1:length(temp)]']); 
    elenum=0;
    spkdata={};
    while ~isempty(temp2)
        elenum=elenum+1;
        jsel=temp2(1,1);
        jtemp=temp2(:,1)==jsel;
        jcho=temp2(jtemp,2);
        spkdata{1,elenum}=nev.Data.Spikes.Timestampsy(jcho); 
        spkdata{2,elenum}=nev.Data.Spikes.Waveform(jcho,:)/4; 
        spkdata{3,elenum}=(nev.ElectrodesInfo{jsel,1}.HighThreshold+nev.ElectrodesInfo{jsel,1}.LowThreshold)/4; 
        spkdata{4,elenum}=jsel; 
        temp2(jtemp,:)=[];
    end
    sign_spk_raster = [];
    for ch = 1:length(channel)                                   % 循环每一个通道
        sk = spkdata{1,channel(ch)};                              % 选择通道
        [spk_raster ~] = f_spk_binms(sk,downfs,[0,time]);  % 1ms一个spike,返回spike的时序
        sign_spk_raster(:,ch) = spk_raster;
    end
    sign_spk_raster(sign_spk_raster>0)=1;
end

