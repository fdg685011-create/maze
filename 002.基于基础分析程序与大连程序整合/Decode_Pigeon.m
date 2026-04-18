%% 001.清空工作区间，添加工具箱至搜索路径
clc;clear;close all
addpath(genpath('Analyse-tools-YG'));

%% 002.读取原始信号（易格无线采集设备）
% 参数设置
samfs = 30000;    % 采样频率
downfs = 1000;    % 降采样后频率
channel = 1:1:16;
Drawing = false;

% 读取plx原始数据文件
[plx_NAMEFile,filepath,plx_FILEIndex] = uigetfile('*.plx','Select the date file','E:\郑州平台\实验室迷宫数据之092_106_653\1.原始数据\092鸽原始数据(N)');
plx_FullFilename = strcat(filepath,plx_NAMEFile);

% 读取excel精确打标时刻
[xlsx_NAMEFile,xlsxpath,xlsx_FILEIndex] = uigetfile('*.xlsx','Select the date file',filepath);
xlsx_FullFilename = strcat(xlsxpath,xlsx_NAMEFile);
refs_temp = xlsread(xlsx_FullFilename);
refs = refs_temp(:,1:3);
refs(:,1) = refs(:,1)+0.3;


% % 获取所有通道原始数据
% [allad] = readplx(plx_FullFilename,Drawing);
% rawdata=[];
% for k=1:length(channel)
%         cha=channel(k);
%         s=allad{1,cha};
%         rawdata=[rawdata,s];
% end
% 
% % 原始数据预处理得到Spike与LFP原始信号
% Common=false;
% [rawspk,rawlfp] = f_rawdata_preprocessing(rawdata,samfs, downfs, channel,Common);

Common=false;

[rawdata,rawlfp,rawspk] = f_read_rawdata_lfp(plx_FullFilename,samfs,downfs,channel,Common,Drawing);  % 读取原始信号并筛选通道


%% 003.提取Spike特征
bin=50;
spk_thre_min = 2.5;                           % spike阈值下限
spk_thre_max = 8;                             % spike阈值上限
p_spkthre(rawspk,spk_thre_min,spk_thre_max)                                  % 显示spk原始信号，确定spk阈值
spk_raster=f_read_raster(rawspk,samfs,downfs,spk_thre_min,spk_thre_max);     % 提取raster特征 
spk_rate=f_sl_binsl(spk_raster,bin,1);

%% 004.特征数据预处理
% 设置训练集和测试集的比例
train_ratio = 0.7; % 50%训练集，50%测试集
% 将refs拆分为训练集和测试集
[refs_train, refs_test] = split_refs(refs, train_ratio);
% 处理训练集，生成spike发放率和LFP的频带数据
[lfp6080_train, lfp3045_train, lfp510_train, spk_rate_train] = process_train_data(refs_train, spk_rate, rawlfp, downfs);
% 处理测试集，生成spike发放率和LFP的频带数据
[lfp6080_test, lfp3045_test, lfp510_test, spk_rate_test] = process_train_data(refs_test, spk_rate, rawlfp, downfs);

%% 005.SVM解码数据集制作
Selected_ch=1:16;
window_size_s = 1;  % 单位：s
step_size_s = 0.5;    % 单位：s
% 生成训练集
[svm_train_x, svm_train_y] = generate_svm_train_data(spk_rate_train, lfp6080_train, lfp3045_train, lfp510_train, window_size_s, step_size_s, downfs, Selected_ch);
% 生成测试集
[svm_test_x, svm_test_y] = generate_svm_train_data(spk_rate_test, lfp6080_test, lfp3045_test, lfp510_test, window_size_s, step_size_s, downfs, Selected_ch);
% 特征维度与标签拼接，为放入matlab自带分类app进行分类解码作准备
svm_traindata=[svm_train_x,svm_train_y'];
svm_testdata=[svm_test_x,svm_test_y'];
% 类平衡处理
svm_traindata_balanced = balance_svm_data(svm_traindata);
svm_testdata_balanced = balance_svm_data(svm_testdata);

%% 006.构建解码模型
%(1)打开matlab自带app中的分类学习器；
%(2)点击学习模块中的新建会话，从工作区中选择svm_traindata_balanced，进行模型训练； 
%(3)点击测试模块，导入测试集svm_testdata_balanced，进行模型测试；
%(4)保存准确率较高模型，用于后续的滑窗预测；

%% 007.使用SVM预训练模型对数据进行滑窗预测

% 实际标签参考
gt=zeros(size(rawlfp,1),1);
for r = 1:length(refs)
    startms=floor(refs(r,1)*1000);
    stopms=min(ceil(refs(r,2)*1000),size(rawlfp,1));
    gt(startms:stopms)=refs(r,3);
end
decode_timelen = 1000;    %单位：ms
decode_step =200;
strat_position = 1;  
end_position=size(rawlfp,1);          % 数据预测结束位置
num=0;            %用于对应当前窗口数
for i = strat_position:decode_step:end_position-decode_timelen
    % 显示滑窗进度
    disp([num2str(i), '/', num2str(size(rawlfp,1))]);
    num = num+1;
    window_start = i;
    window_stop = i+decode_timelen-1;
    current_rawlfp = rawlfp( window_start:window_stop,:);
    [lfp6080_w, lfp3045_w, lfp510_w] = process_lfp(current_rawlfp, downfs);
    spk_rate_w = spk_rate(window_start:window_stop,:);
    % testing_x = cat(2, spk_rate_w(:,1:16), lfp3045_w(:,1:16), lfp6080_w(:,1:16));
    testing_x = cat(2,lfp3045_w(:,1:16), lfp6080_w(:,1:16));
    % testing_x = lfp6080_w(:,1:16);
    testing_x = mean(testing_x,1);
    prediction =trainedModel958.predictFcn(testing_x);       % 注意需要调整SVM模型的名称
    predt(num) = prediction;
    groundth(num) = gt(i);
end

%% 绘制预测结果
figure
% 绘制第1张图----------------1----------------实际标签参考
subplot(3,1,1); 
stem(groundth);
t=title('目标进出通道实际标签类别（groundth）');
set(gca, 'FontSize', 18, 'LineWidth', 1.5);
set(t, 'FontSize', 24); % 修改字体大小
xlabel('预测窗口序数','FontSize', 24);
ylabel('标签类别','FontSize', 24);

% 绘制第2张图----------------2----------------预测结果
subplot(3,1,2); 
stem(predt);
t=title('直接预测结果（predt）');
set(gca, 'FontSize', 18, 'LineWidth', 1.5);
set(t, 'FontSize', 24); % 修改字体大小
xlabel('预测窗口序数','FontSize', 24);
ylabel('标签类别','FontSize', 24);

% 绘制第3张图----------------3----------------预测结果
smoothed_predictions = sliding_window_mode_conv(predt,7);
subplot(3,1,3); 
stem(smoothed_predictions);
t=title('滑窗预测结果（predt）');
set(gca, 'FontSize', 18, 'LineWidth', 1.5);
set(t, 'FontSize', 24); % 修改字体大小
xlabel('预测窗口序数','FontSize', 24);
ylabel('标签类别','FontSize', 24);
