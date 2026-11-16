function [plv_fea_on,plv_fea_off] = plot_PLV(respones_on_temp,~,~,channel,~,fband,Before,After,Fs)
%     respones_on_temp= bin_lfp;
[time,ref,channel_]=size(respones_on_temp);
respones_on_=zeros(size(respones_on_temp));
%%首先进行滤波
[b1,a1] = butter(2,[fband(1) fband(2)]/(Fs/2));
for i=1:ref
    for j =1:channel_
        temp=respones_on_temp(:,i,j);
        respones_on_(:,i,j)=detrend(filtfilt(b1,a1,temp));
    end
end
%%计算plv
plv_fea1=[];plv_fea2=[];p=[];hh=[]; PLV=[];Ppp2=[];plv2=[];Ppp3=[];
iii=1;
figure('units','normalized','outerposition',[0 0 1 1])
Ppp=zeros(channel_, channel_,ref);
plv_fea_on=[];plv_fea_off=[];
%% 步长100ms 窗长150ms
 Bc=100;Cc=150; %Bc=100步长;Cc=150窗长; 
%% 

 for n = 1:(After*Fs-Bc)/Bc
   
%for n = 1:(Before*Fs+After*Fs-Bc)/Bc
    
     for t=1:ref
%           sig1=squeeze(respones_on_(1+(n-1)*Bc:(n-1)*Bc+Cc+1,t,:));
        
         sig1=squeeze(respones_on_(Before*Fs+(n-1)*Bc:Before*Fs+(n-1)*Bc+Cc,t,:));
  
        nLoc1 = size(sig1, 2);
       
        plv1 = zeros(nLoc1, nLoc1);
       
        complex_sig1 = hilbert(sig1);       %利用希尔波特变换 计算信号的瞬时相位
       
        %计算plv
        for i = 1:nLoc1
            for j = 1:nLoc1
                if i <= j
                    plv1(i, j) = abs(mean(...
                        exp(1i*(unwrap(angle(complex_sig1(:,i)))-...
                        unwrap(angle(complex_sig1(:, j))))), 1));
%                       plv1(j,i)=plv1(i,j);
                    Ppp(i,j,t)=plv1(i,j);
                end
            end
        end
        %% 选基线
        for  m = 1:(Before*Fs-Bc)/Bc     %打标前
            sig2=squeeze(respones_on_(1+(m-1)*Bc:(m-1)*Bc+Cc-1,t,:)); 
            nLoc2 = size(sig2, 2);
            plv = zeros(nLoc2, nLoc2);
            complex_sig2 = hilbert(sig2);
        for i = 1:nLoc2
            for j = 1:nLoc2
                if i <= j
                    plv(j,i) = abs(mean(...
                        exp(1i*(unwrap(angle(complex_sig2(:,i)))-...
                        unwrap(angle(complex_sig2(:, j))))), 1));
                        plv2(j,i,m)=plv(j,i);
                    Ppp2(j,i,t,m)=plv(j,i);
                end
            end
        end
        end
             plv2=squeeze(mean(plv2,3));

    plv_fea_on0=[]; plv_fea_off1=[];
    for i=2:channel_   %%通道  提取plv特征
        plv_fea0=plv1(1:i-1,i)';
        plv_fea_on0=[plv_fea_on0,plv_fea0];
        plv_fea1=plv2(i,1:i-1);
        plv_fea_off1=[plv_fea_off1,plv_fea1];
    end
    plv_fea_on(t,:,n)=plv_fea_on0;
    plv_fea_off(t,:,n)=plv_fea_off1;
     end
         Ppp3=squeeze(mean(Ppp2,4))+Ppp;%
         PLV=mean(Ppp3,3);
         PLV(logical(eye(size(PLV))))=1;%对角线化为1
    for f=1:size(plv_fea_on,2)
        a=squeeze(plv_fea_on(:,f,n));
        b=squeeze(plv_fea_off(:,f,n));
        [h_,p_,ci]=ttest2(a,b);
        p(f,n)=p_;
        hh(f,n)=h_;
%         p(n,f)=p(f,n);
%         hh(n,f)=hh(f,n);
    end
xvalues={};yvalues={}; %%画图
for i =1 :length(channel) xvalues{i} = num2str(channel(i)); end
for i =1 :length(channel) yvalues{i} = num2str(channel(i)); end
%subplot(4,ceil((After*Fs+Before*Fs-Bc)/(4*Bc)),iii);
 subplot(4,ceil((After*Fs-Bc)/(4*Bc)),iii);
h = heatmap(xvalues,yvalues,PLV, 'FontSize',10, 'FontName','Times New Roman');
h.Title = (strcat('PLV-',num2str((n-1)*Bc),'-',num2str((n-1)*Bc+Cc),'ms'));
% set(gca,'XTickLabelRotation',0) 
colormap(jet)
caxis([0 1])
iii=iii+1;
end
%         t-检验
%     p=zeros(nLoc1, nLoc1);
%     hh=zeros(nLoc1, nLoc1);
%     for i = 1:channel_
%         for j=1:i
%             a=squeeze(Ppp(i,j,:));
%             b=squeeze(Ppp(j,i,:));
%             [h_,p_,ci]=ttest2(a,b);
%             p(i,j)=p_;
%             hh(i,j)=h_;
%             p(j,i)=p(i,j);
%             hh(j,i)=hh(i,j);
%         end
%     end
figure('units','normalized','outerposition',[0 0 1 1])
xvalues={};yvalues={}; %%画图
for i =1 :size(hh,2) xvalues{i} = i; end
for i =1 :size(hh,1)  yvalues{i} =i; end
H = heatmap(xvalues,yvalues,hh, 'FontSize',10, 'FontName','Times New Roman');
H.Title = (strcat('PLV(p)')) ;
xlabel(strcat('Time window ',num2str(Cc),'ms'));
ylabel('Feature');
colormap(jet)
caxis([0 1])
% PLV=[];
end


