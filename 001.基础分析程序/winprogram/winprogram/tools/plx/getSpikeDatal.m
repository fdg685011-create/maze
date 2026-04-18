function [SpikeData, PATHFile, PVCSRand, sti_time]=getSpikeDatal(fileNEV)
% GETSPIKEDATA Return the numbers of spikes in channel independently
%   SPIKEDATA 保存的是各个通道的Spikes的数据
%   PATHFile  保存的是NEV文件的路径及名称
%   FILENEV   NEV文件的名字及路径
% HISTORY
%   Zhi-Gang Shang write
%   Xin-Yu Liu rewrite

if nargin == 0
    [FileName,PathName]=uigetfile('*.nev','Select the date file');
    FullFileName=strcat(PathName,FileName);
    PATHFile=FullFileName(1:end-4);
end

if nargin == 1
    if ischar(fileNEV)
        FullFileName=fileNEV;
        PATHFile=FullFileName(1:end-4);
    else
        error('INPUT argument is NOT NEV name.');
    end
end

if nargin > 1
    error('INPUT ONE argument required.');
end

NEV=openNEV('read',FullFileName,'nosave','noparse');

temp=double(NEV.Data.Spikes.Electrode);
temp2=sortrows([temp,[1:length(temp)]']); %#ok
elenum=0;
SpikeData={};
while ~isempty(temp2)
    elenum=elenum+1;
    jsel=temp2(1,1);
    jtemp=temp2(:,1)==jsel;
    jcho=temp2(jtemp,2);
    SpikeData{1,elenum}=NEV.Data.Spikes.Timestampsy(jcho); %#ok
    SpikeData{2,elenum}=NEV.Data.Spikes.Waveform(jcho,:)/4; %#ok 
    SpikeData{3,elenum}=(NEV.ElectrodesInfo{jsel,1}.HighThreshold+NEV.ElectrodesInfo{jsel,1}.LowThreshold)/4; %#ok  
    SpikeData{4,elenum}=jsel; %#ok
    temp2(jtemp,:)=[];
end
PVCSRand = NEV.Data.SerialDigitalIO.UnparsedData; 
sti_time = NEV.Data.SerialDigitalIO.TimeStampSec';
%save('PVCSFile.mat','PVCSRand','-append');
% if isempty(find(cell2mat(SpikeData(4,:))==129)) %#ok
%     error('Stimulated time record is miss');
% end