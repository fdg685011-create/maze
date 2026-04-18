function [] = t_subplot(data,refs,yl)
%T_SUBPLOT 此处显示有关此函数的摘要
%   此处显示详细说明
    fs=1000;
    color_orig=[0.5 0 0 0.1;0 0.5 0 0.1];
    plot(data)
    xlim([0,length(data)])
    ylim([0,yl])
    hold on
    for r =1:length(refs)
        rectangle('Position',[refs(r,1)*fs,0,(refs(r,2)-refs(r,1))*fs,200],...
            'FaceColor',color_orig(refs(r,3)+1,:),'EdgeColor',color_orig(refs(r,3)+1,1:3),'LineWidth',0.2);
    end
    ylabel('发放率')
end

