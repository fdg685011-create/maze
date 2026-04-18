figure
p=[];
str={' ','*','**'};
for ch = channel
    subplot(4,8,ch)
    data1=squeeze(response_on(:,:,ch));
    data2=squeeze(response_baseline(:,:,ch));
    pp=f_ttest(data1,data2);
    p(:,ch)=pp;
    p1=0.9:1:length(stim.ClassName)+0.5;
    p2=1.2:1:length(stim.ClassName)+0.5;
    b1 = boxplot(data1,'positions',p1,'Colors',[255,5,87]/255,'Widths',0.2,'Symbol','');
    for ii =1:size(data1,2)
        text(p1(ii)+0.1,-7,str{pp(ii)+1},'HorizontalAlignment','center','FontSize',12)
    end
    hold on
    b2 = boxplot(data2,'positions',p2,'Colors',[0, 80, 255]/255,'Widths',0.2,'Symbol','');
    fillcolor2=[255,5,87]/255;  %这是红色
    fillcolor1=[0, 80, 255]/255; % fillcolors = rand(24, 3);
    [t,z]=size(data1');
    fillcolors=[repmat(fillcolor1,t,1);repmat(fillcolor2,t,1)];
    boxobj= findobj(gca,'Tag','Box');
    for j=1:length(boxobj)   %给每个添加颜色
        hx=patch(get(boxobj(j),'XData'),get(boxobj(j),'YData'),fillcolors(j,:),'FaceAlpha',0.5);
    end
    set(gca,'XTickLabel',{'r','b','g','y','w'});
    title(strcat('-ch',num2str(ch)));
    ylim([-10,inf])
end
