%% 001.清空工作区间，添加工具箱至搜索路径
clc;clear;close all

%% 001.选择原始数据，读取原始数据和打标, 滤波，计算和降采样得到raw_raster和raw_lfptf
disp('读取原始信号......')
tic;
channel=1:32;                                                               % 通道数
samfs = 20000;                                                              % 采样频率
downfs = 1000;
fband=1:80;% 降采样后频率i
Selected_ch = [1:16 17:24 25:2:32];                                         % 筛选通道，（1）ENTO脑区：1：16；（2）NCL脑区：17：24；（3）IPC脑区：25：2：32；

% 打开大工原始数据文件：RHD2216y
[NAMEFile,PATHFile,FILEIndex] = uigetfile('*.*','打开原始数据文件','data');
FullFilename = strcat(PATHFile,NAMEFile);
    
% 读取excel精确打标时刻
[xlsx_NAMEFile,xlsxpath,xlsx_FILEIndex] = uigetfile('*.xlsx','Select the date file',PATHFile);
xlsx_FullFilename = strcat(xlsxpath,xlsx_NAMEFile);
refs_temp = xlsread(xlsx_FullFilename);
refs = refs_temp(:,1:3);

% 基本参数设定（通常按照默认），读取原始数据和rawspk
Common = false;
start_time = 0;                                                             % 确定起止时刻（单位秒）                                                         
end_time = 240;      %%%%%%%%%%%% 调整时长 %%%%%%%                          % 默认60分钟         
[rawdata , rawlfp, rawspk] = f_read_rawdata_DG(FullFilename, samfs, downfs, channel, Common, start_time, end_time);      
rawdata = rawdata(:,Selected_ch);                                           % 选择有效通道
rawspk = rawspk(:,Selected_ch);                                             % 选择有效通道
rawlfp = rawlfp(:,Selected_ch);                                             % 选择有效通道
times = size(rawlfp,1);                                                     % 采样率为1000的总时间
stop_time=toc;
disp(stop_time)  

%% 005.试次区间LFP特征分析
freq = [1,250];             % 时频分析的频率范围
window=128;
step=1;
before=1;      % 往前往后的时间裕量，秒
after=3;       % 往前往后的时间裕量，秒
[data_sz,f]=f_read_lfptf(rawlfp,channel,freq,downfs,window,step,refs,before,after);

p_lfp_trial(data_sz,f,channel,refs,fband,downfs,before,after);



%% 单试次多通道时频图

Result_RootPath = strcat(PATHFile, '归一化后LFP');  % 可视化图片保存路径
mkdir(Result_RootPath);
all_select_ch = 16;
for i=1:size(data_sz,1)
    label=refs(i,3);
    if label==0
        target_category ='特定目标';
    elseif label==1
        target_category ='干扰目标';
    end

    h2=figure('units','normalized','outerposition',[0 0 1 1],'visible','on');
    sgtitle(strcat(target_category,'---','试次',num2str(i),'---频带归一化后LFP能量时频图'),'FontName', 'SimHei', 'FontSize', 16)
    for ch=1:size(data_sz,2)

        subplot(4,7,ch);
        A = data_sz{i,ch};
        % B= A';
        % C= normalize(B);
        % D= C';

        if ch==1

            trail_all_chs = zeros(size(A,1),size(A,2));
        end
        
        trail_all_chs=trail_all_chs+A;
        imagesc(A);
        % colormap("jet")
        colorbar
        axis xy;
        hold on
        xline(before*downfs, 'r', 'LineWidth', 3.5);
        xline((refs(i,2)-refs(i,1)+before)*downfs, 'r', 'LineWidth', 3.5);

        xlabel('时间/秒','FontName', 'SimHei', 'FontSize', 14);
        ylabel('LFP频带','FontName', 'SimHei', 'FontSize', 14);
        title(strcat('通道',num2str(ch)),'FontName', 'SimHei', 'FontSize', 12)

    end

        %图片保存
        saved_rootpath = Result_RootPath;
        filename = strcat('Trial ',num2str(i),'-类别标签- ',target_category);
        full_savedfile_name = strcat(saved_rootpath,'\',filename,'.png');
        print(h2,'-dpng',full_savedfile_name);
        close(h2)

        % 绘制单试次多通道叠加图
        h3=figure('units','normalized','outerposition',[0 0 1 1],'visible','on');
        imagesc(trail_all_chs)
        colormap("jet")
        colorbar
        axis xy;
        hold on
        xline(before*downfs, 'r', 'LineWidth', 3.5);
        xline((refs(i,2)-refs(i,1)+before)*downfs, 'r', 'LineWidth', 3.5);

        xlabel('时间/秒','FontName', 'SimHei', 'FontSize', 14);
        ylabel('LFP频带','FontName', 'SimHei', 'FontSize', 14);
        title(strcat(target_category,'所有通道叠加-','试次',num2str(i)),'FontName', 'SimHei', 'FontSize', 12)

        % 保存叠加图
        filename = strcat('所有通道叠加-','试次-',num2str(i),target_category);
        full_savedfile_name = strcat(saved_rootpath,'\',filename,'.png');
        print(h3,'-dpng',full_savedfile_name);
        close(h3)



end

