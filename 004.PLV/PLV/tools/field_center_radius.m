function field_center_radius(psth_1,psth_2,psth_3,psth_4)
%FIELD_CENTER_RADIUS 此处显示有关此函数的摘要
%   此处显示详细说明
thre_radio=0.21;

V_1=max(psth_1,[],'all');
V_2=max(psth_2,[],'all');
V_3=max(psth_3,[],'all');
V_4=max(psth_4,[],'all');
all_direct=psth_1+psth_2+psth_3+psth_4;
V_all=max(all_direct,[],'all');

psth_1(psth_1<V_1*thre_radio)=0;
psth_2(psth_2<V_2*thre_radio)=0;
psth_3(psth_3<V_3*thre_radio)=0;
psth_4(psth_4<V_4*thre_radio)=0;
all_direct(all_direct<V_all*thre_radio)=0;

figure,
imagesc(psth_1);
%colormap gray;
axis equal tight;  
axis off

figure,
imagesc(psth_2);
%colormap gray;
axis equal tight;  
axis off

figure,
imagesc(psth_3);
%colormap gray;
axis equal tight;  
axis off

figure,
imagesc(psth_4);
%colormap gray;
axis equal tight;  
axis off

figure,
imagesc(all_direct);
%colormap gray;
axis equal tight;  
axis off






end

