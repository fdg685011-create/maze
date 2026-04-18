function [label] = p_label_process(data,refs,fs,bin,yl)
%P_LABEL_PROCESS 此处显示有关此函数的摘要
%   此处显示详细说明
    color_orig=[0.5 0 0 0.1;0 0.5 0 0.1];
    figure('units','normalized','outerposition',[0 0 1 1])                      % 全屏显示
    t=tiledlayout(5,1,'TileSpacing','compact','padding','compact');   % 三个参数：'normal', 'compact', 'none'
    title(t,'Make Label-ch','FontSize',20)

    nexttile;                                        % 原始数据
    data = f_sl_binsl(data,bin,1);
    t_subplot(data,refs,yl)
    set(gca,'FontName','Times New Rome','FontSize',13); % 设置整体的字号大小

    nexttile;                                        % 平滑处理
    refs(:,1)=refs(:,1)-1;
    refs(:,2)=refs(:,2)+1;
    t_subplot(data,refs,yl)
    smooth_data_ch = smoothdata(data);       
    plot(smooth_data_ch)                                   
    [peak_val,peak_loc]=findpeaks(smooth_data_ch);   % 寻找波峰
    plot(peak_loc,peak_val,'*','color','R');         %繪制最大值點
    set(gca,'FontName','Times New Rome','FontSize',13); % 设置整体的字号大小

    nexttile; 
    label_target=zeros(length(data),1);
    for r = 1:length(refs)
        peaks=zeros(length(data),1);
        peaks(peak_loc)=peak_val;
        temp = zeros(length(data),1);
        temp(round(refs(r,1)*fs+1):round(refs(r,2)*fs),:) = 1;
        peaks = temp.*peaks;
        [maxv,maxl] = max(peaks);
        label_target(maxl) = maxv;
    end
    label_target(label_target>0)=1;

    convf = ones(bin,1);
    label_target=convn(label_target, convf, 'same');
    t_subplot(label_target,[],2)


    label_other=zeros(length(data),1);
    peaks=zeros(length(data),1);
    peaks(peak_loc)=peak_val;
    label_other=peaks.*~label_target;
    label_other(label_other>0)=1;
    convf = ones(bin,1);
    label_other=convn(label_other, convf, 'same');
    label_other(label_other>0)=1;
    label_other=label_other.*~label_target;
    t_subplot(label_other,[],2)
    set(gca,'FontName','Times New Rome','FontSize',13); % 设置整体的字号大小

    nexttile; 
    convf = ones(bin*2,1);
    label_target=convn(label_target, convf, 'same');
    label_target(label_target<max(label_target))=0;
    label_target(label_target==max(label_target))=1;
    t_subplot(label_target,[],2)
    label_other=label_other.*~label_target;
    label_target(1)=0;
    label_target(end)=0;
    label_other(1)=0;
    label_other(end)=0;
    label_baseline=zeros(length(data),1);
    label_baseline=~(label_baseline+label_other+label_target);
    t_subplot(label_other,[],2)
    set(gca,'FontName','Times New Rome','FontSize',13); % 设置整体的字号大小

    nexttile; 
    refs_t=[];
    dif=diff(label_target)';
    refs_t(:,1)=find(dif==1)/fs;
    refs_t(:,2)=find(dif==-1)/fs;
    refs_t(:,3)=0;
    plot(data)
    hold on 
    for r = 1:length(refs)
         rectangle('Position',[refs(r,1)*fs,0,(refs(r,2)-refs(r,1))*fs,max(data)],'FaceColor',color_orig(1,:),...
            'EdgeColor',color_orig(1,1:3),'LineWidth',0.2);
    end
    for r = 1:length(refs_t)
         rectangle('Position',[refs_t(r,1)*fs,0,(refs_t(r,2)-refs_t(r,1))*fs,max(data)],'FaceColor',color_orig(2,:),...
            'EdgeColor',color_orig(2,1:3),'LineWidth',0.2);
    end
    xlim([0,size(data,1)])
    set(gca,'FontName','Times New Rome','FontSize',13); % 设置整体的字号大小

    figure
    data_bar=[sum(label_baseline),sum(label_other),sum(label_target)];
    bar(data_bar)
    set(gca,'Xticklabel', ["baseline","other","target"])  %gca 坐标的句柄
    for i=1:length(data_bar)
        text(i,data_bar(i),strcat(num2str(data_bar(i)/length(data)*100),'%'),...
            'HorizontalAlignment','center','VerticalAlignment','bottom');
    end
    title('类别分布')
    ylabel('样本数量')
    set(gca,'FontName','Times New Rome','FontSize',13); % 设置整体的字号大小
    
    label=label_baseline*0+label_other*1+label_target*2;
end

