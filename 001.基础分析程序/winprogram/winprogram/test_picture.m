x_left=0;
x_right=0;
colors = [
    65/255 105/255 225/255;  % 品蓝
    255/255 255/255 0/255;   % 黄
    255/255 97/255  0/255;    % 橙
    106/255 90/255 205/255;    % 石板蓝
    127/255 255/255 212/255; % 碧绿
    250/255 235/255 215/255; % 古董白
    160/255 32/255 240/255; % 紫色
    0/255   201/255 87/255; % 翠绿色
    255/255 128/255 0/255; % 桔黄
    135/255 206/255 235/255; % 天蓝
    227/255 207/255 87/255; % 香蕉色
    255/255 192/255 203/255; % 分红
    127/255 255/255 0/255; % 黄绿
    64/255 224/255 208/255; % 青绿色
    255/255 215/255 0/255;  % 金黄色
    250/255 128/255 114/255;  % 橙红
    0/255 0/255 0/255;   % 红
];

linewidth=[ 3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;6];

for p=1:10
    figure
    current_figure_data=[];
    x_left=x_right+1;
    x_right=x_right+object_frames(p,1);
    current_figure_data=all_train_lfp_all_and_mean(x_left:x_right,:);
    current_x_value=size(current_figure_data,1);
    x_frame=1:1:current_x_value;
    
    legendLabels = {'ch1_lfp','ch2_lfp','ch3_lfp','ch4_lfp','ch5_lfp','ch6_lfp','ch7_lfp','ch8_lfp','ch9_lfp','ch10_lfp','ch11_lfp','ch12_lfp','ch13_lfp','ch14_lfp','ch15_lfp','ch16_lfp','all_lfp_mean'};
    for pp=1:size(current_figure_data,2)
            legendname='ch'+string(pp)+'lfp';
        plot(x_frame,current_figure_data(:,pp),'Color', colors(pp,:),'DisplayName',legendname,'LineWidth',linewidth(pp,:));  
        hold on; 
    end
    legend('show')
    picture_title='实验试次'+string(p);
    title(picture_title);  
    xlabel('帧数');  
    ylabel('能量');  
    
end
