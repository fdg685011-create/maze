% 大工读取数据
[NAMEFile,PATHFile,FILEIndex] = uigetfile('*.*','Select the date file','G:\新迷宫\Data');
FullFilename = strcat(PATHFile,NAMEFile);
fid = fopen(FullFilename,'rb');
[data,count] = fread(fid,inf,'int16');
fclose(fid);
num = count;
A = zeros(num,1);
i = 1;
j = 1;
B = zeros(num/16, 16);
j = 1;
k = 1;
for i = 1:num 
B( k, j) = data(i,1);
if j == 16
k = k + 1;
j = 1;
else
j = j + 1;
end
end
sign_raw=B;
Fs=20000;
fs=1000;
channel=1:1:16;