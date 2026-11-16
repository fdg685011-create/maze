NCL硕士大论文——筛选的MATLAB原始处理程序

源仓库：https://github.com/fdg685011-create/maze
源分支：main
源仓库树SHA：4d5b09cb7281b86136463f5b243383756d460460

本分支仅存放经初步筛选的 MATLAB 旧处理程序和PLX读取SDK。
原始文件使用GitHub已有blob直接引用，未重写、未修复、未运行。
不包含实验数据、大型PLX文件、视频和测试数据。

目录：
00_Plexon_SDK：PLX相关MATLAB接口、mexPlex.mexw64、SDK手册
01_PLX读取：readplx.m
02_信号预处理与试次切分：原始LFP预处理、事件时间切片
03_Spike分析：Spike阈值检测、Raster、放电率
04_LFP分析：STFT、时频、频段及试次图
05_PLV与功能网络：PLV计算、网络分析及绘图
06_辅助函数：PCA、行为标记和放电率辅助函数

使用前特别注意：
1. MATLAB程序仍有旧实验固定路径、时间窗、类别标签等限制，不能直接用于新鸽子大论文完整流程。
2. readplx.m原版不能完整输出所有Spike和事件字段。
3. f_read_rawdata_lfp.m原版150 Hz陷波设置疑似错误。
4. extract_data_for_graduate.m使用固定时间窗和旧结果命名。
5. f_read_raster.m是阈值检测，不代表完成独立单神经元分选。
6. Plexon SDK 的 mexPlex.mexw64 需在Windows MATLAB实机上验证。
7. 不要把00_Plexon_SDK/plx/readplx.m与01_PLX读取/readplx.m同时当做同一调用入口。
8. 参照 文件来源对应关系.json 追溯全部原始路径。
