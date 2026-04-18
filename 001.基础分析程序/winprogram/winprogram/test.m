%% 手动设置参数
all_decode_lfp=all_decode_data(:,17);
beginning=1451.5163335;
ending=1468.0165;
FPS=30;
data_select=[];
data_selectint=[];
train_data=[];
Interval=(ending-beginning)/((FPS*3.3)-1);
for j=1:(FPS*3.3)
    current_number=beginning+Interval*(j-1);
    current_numberint=ceil(current_number);
    data_select(j)=(current_number);
    data_selectint(j)=(current_numberint);
    train_data(j)=all_decode_lfp(current_numberint,1);  
end    
normalization_traindata=mapminmax(train_data, 0, 1);
save('C:/Users/zdy/Desktop/20240117/0117-0-3.mat', 'normalization_traindata')
