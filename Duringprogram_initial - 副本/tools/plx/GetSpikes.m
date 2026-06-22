%%得到spike信号
%需设置采样率Fs，剪spike前后点数，聚类数。
%傅里叶变换
Route1=CH1_Cecebus';
y=Route1;
theSize=size(y);
L=theSize(1);
Fs=30000;
figure_model=1;
%[fft_result ,P1 ]=self_fft(y,L,Fs,figure_model);
%%滤波器提高频
filtered_data=y';
[filtered_result]=MULTIPLE_TYPE_FILTERS(filtered_data,Fs,3,5000,250);%滤波器
%[fft_result2 ,P2]=self_fft(filtered_result,L,Fs,figure_model);%滤波后的傅里叶变换
%subplot(2,1,1);plot(Route1);
%subplot(2,1,2);plot(filtered_result);
%%画出滤波后的时频图
%[t,frex1,tf_matrix2]=MORLET_WAVELET_TIME_FREQ_PLOT(filtered_result,Fs,250,5000,2048,64);
%计算阈值 阈值=均值+3*标准差
theMean=mean(abs(filtered_result));
theStd=std(abs(filtered_result));
threshold=theMean+3*theStd;
%spike发放时间1.6ms 取前12后36
high_fre=filtered_result;
num=0;
spikes=[];
i=12;
while i<L-36;
   if  high_fre(i)>threshold
       point0=i-11;
       point1=i+36;
       one_spike=high_fre(1,point0:point1);
       num=num+1;
       spikes=[spikes;one_spike];
       i=i+37;
   else
       i=i+1;
   end
end

%K-means聚类
cla_num=4;%聚类类数
cata_num=zeros(1,cla_num);
cl_result=cell(1,cla_num);
[Idx,C,sumD,D]=kmeans(spikes,cla_num);
for i=1:num
    cla=Idx(i);
    cl_result{1,cla}=[cl_result{1,cla};spikes(i,:)];
    cata_num(cla)=cata_num(cla)+1;
end
%可视化
figure();

for i=1:cla_num
    subplot(cla_num,1,i);
    plot(cl_result{1,i}');
    title("Spike信号聚类结果第"+i+"类，共"+cata_num(i)+"个");
end
