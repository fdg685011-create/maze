function  [p,hh]=Plv_net(bin_lfp,Fs,fband,Before,After)
% Fs=1000;
%  fband=[60,70];
  Bc=100;Cc=150; %Bc=100步长;Cc=150窗长; 
respones_on_temp= bin_lfp;
[time,ref,channel_]=size(respones_on_temp);
window_ =[Before*Fs+1,(Before+After)*Fs];
respones_on_=zeros(size(respones_on_temp));
%%首先进行滤波
[b1,a1] = butter(2,[fband(1) fband(2)]/(Fs/2));
for i=1:ref
    for j =1:channel_
        temp=respones_on_temp(:,i,j);
        respones_on_(:,i,j)=detrend(filtfilt(b1,a1,temp));
    end
end

%        respones_on=squeeze(mean(respones_on_,2));
plv_net=[]; W_plv_all =[];W_net=[];plv_value=[];plv_valueref=[];W_plv_all2=[];plv_value2=[];plv_valueref2=[];
W_plv_all0=[];maxplv_value1=[];maxplv_value2=[];plv_valueref0=[];plv3=[];plv33=[];
qd=1:Bc:((After+Before)*Fs-Cc+1); %对打标前一秒和打标后1秒进行滑窗
xx=floor((qd+Bc-1-Before*Fs));
figure('units','normalized','outerposition',[0 0 1 1])
subplot(2,3,4:6);
for trial=1:ref
    %计算off
     for QD2=1:Bc:((Before)*Fs-Cc+1)  % 打标前1s 滑窗数据作为基线off
        GS2=(QD2-1)/Bc+1;
        sig2=squeeze(respones_on_(QD2:QD2+Cc-1,trial,:));
   
    nLoc2 = size(sig2, 2);
    plv2 = zeros(nLoc2, nLoc2);
    complex_sig2 = hilbert(sig2);
    %计算plv off
    for i = 1:nLoc2
        for j = 1:nLoc2
            plv2(i, j) = abs(mean(...
                exp(1i*(unwrap(angle(complex_sig2(:,i)))-...
                unwrap(angle(complex_sig2(:, j))))), 1));
        end
    end
     plv3(:,:,GS2)=plv2;
     end
     plv33=mean(plv3,3); %求叠加平均值
    % 计算off
    plv33(logical(eye(size(plv33))))=0;%对角线化为零
    W_plv2=double(im2bw(plv33,0.8));   %%阈值设置为0.8
    W_plv_all2(:,:,trial)=W_plv2;

    plv_value2=length(find(W_plv2==1))/16;%算平均连接数即平均节点度

    plv_valueref2(trial)=plv_value2;
    %%计算on 并滑窗
     
    for QD=1:Bc:((After+Before)*Fs-Cc+1)
        GS1=(QD-1)/Bc+1;
        sig1=squeeze(respones_on_(QD:QD+Cc-1,trial,:));
        nLoc1 = size(sig1, 2);
        plv = zeros(nLoc1, nLoc1);
        complex_sig1 = hilbert(sig1);       %利用希尔波特变换 计算信号的瞬时相位
        %计算plv
        for i = 1:nLoc1
            for j = 1:nLoc1
                plv(i, j) = abs(mean(...
                    exp(1i*(unwrap(angle(complex_sig1(:,i)))-...
                    unwrap(angle(complex_sig1(:, j))))), 1));
            end
        end
        plv1=plv;
        plv1(logical(eye(size(plv1))))=0;%对角线化为零
        W_plv=double(im2bw(plv1,0.8));   %%阈值设置为0.8
        W_plv_all(:,:,GS1,trial)=W_plv;
        plv_value(GS1)=length(find(W_plv==1))/16;%算平均连接数即平均节点度
        
    end 
    %归一化成0-1
%     plv_value=mapminmax(plv_value,0,1);
    plv_valueref(:,trial)=plv_value;
  
  
    %% 画图
    hold on
    % %               plv_value=smooth(xx, plv_value, 'lowess');
    plot(xx, plv_value,'c');
end

hold on
%  meanplv_valueref=floor(mean(plv_valueref,2));
 meanplv_valueref=mean(plv_valueref,2);
plot(xx, meanplv_valueref,'m');
meanW_plv_all=mean(W_plv_all,4);
% meanplv_valueref=smooth(xx, meanplv_valueref, 'lowess');
% plot(xx, plv_value0,'r');
xlim([xx(1),xx(end)])
xlabel('时间（ms）')
ylabel('平均节点度')
QD_da=length(1:Bc:((Before)*Fs+1));
QD_af=length(1:Bc:((Before+0.5)*Fs+1))-1;   
QD_da2=QD_af+1;
QD_af2=length(1:Bc:((Before+1)*Fs-Cc+1));
max_value1=find(meanplv_valueref(QD_da:QD_af)==max(meanplv_valueref(QD_da:QD_af)))+QD_da-1;%0-500ms
maxplv_value1=max_value1(1);
max_value2=find(meanplv_valueref(QD_da2:QD_af2)==max(meanplv_valueref(QD_da2:QD_af2)))+QD_da2-1;%500-1000ms
maxplv_value2=max_value2(1);
points=[maxplv_value1,maxplv_value2];
scatter(xx(points), meanplv_valueref(points), 'filled', 'MarkerFaceColor', 'b'); % 设置图形标题和轴标签 title('曲线上的指定点'); xlabel('x'); ylabel('y');

subplot(2,3,1);
colormap(jet)
 caxis([0 1])
 colorbar;
myColorMap = lines(length(mean(W_plv_all2,3)));%%lines(m)为返回m种颜色的图
circularGraph(mean(W_plv_all2,3));
subplot(2,3,2);
colormap(jet)
 caxis([0 1])
  colorbar;
myColorMap = lines(length(meanW_plv_all(:,:,maxplv_value1)));%%lines(m)为返回m种颜色的图
circularGraph(meanW_plv_all(:,:,maxplv_value1));
subplot(2,3,3);
colormap(jet)
 caxis([0 1])
  colorbar;
myColorMap = lines(length(meanW_plv_all(:,:,maxplv_value2)));%%lines(m)为返回m种颜色的图
circularGraph(meanW_plv_all(:,:,maxplv_value2));



for nn=1:GS1
    [h,p_,ci,stats]=ttest(plv_valueref2,plv_valueref(nn,:));
    p(nn)=p_;
    hh(nn)=h;
end
%% 网络连接图
% % figure('units','normalized','outerposition',[0 0 1 1])
% % for i=1:GS1
% % m=i*8;
% % if m<=GS1
% %     subplot(2,3,i);
% %
% % myColorMap = lines(length(W_plv_all(:,:,m)));%%lines(m)为返回m种颜色的图
% %
% % %  colorbar;
% % % circularGraph(W_plv_all(:,:,m),'Colormap',myColorMap,'Label',myLabel);
% % circularGraph(W_plv_all(:,:,m));
% % title (strcat('PLV','-net',num2str(m))) ;
% % %     colormap(jet)
% % %     caxis([0 1])
% %     mm(i)=m;
% % end
% %     plv_value(i)=length(find(W_plv_all(:,:,i)==1))/2;
% % end
% % subplot(2,3,4:6);
% % xx=-950:100:1951;
% % % figure
% % plot(xx,plv_value)
% % xlim([xx(1),xx(end)])
% % xlabel('时间（ms）')
% % ylabel('连接数（hz）')
% % hold on;
% %  points = mm; % 标出指定的点
% %  scatter(xx(points), plv_value(points), 'filled', 'MarkerFaceColor', 'r'); % 设置图形标题和轴标签 title('曲线上的指定点'); xlabel('x'); ylabel('y');
% %  %取消保持轴的刻度和方向
% % axis auto; % 取消保持轴的状态
% % hold off;
