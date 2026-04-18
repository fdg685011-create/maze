x_left=0;
x_right=0;
reselect_data_rows={};
reselect_all_decode_data=[];
all_reselect_all_decode_data={};



for n=1:10
    current_trail_selectint=[];
    x_left=x_right+1;
    x_right=x_right+object_frames(n,1);
    current_trail_selectint=all_data_selectint(x_left:x_right,1);
    reselect_data_rows{n}=current_trail_selectint;

end


for h=1:10
    temp_data=[];
    current_data_row=[];
    reselect_all_decode_data=[];
    temp_data=reselect_data_rows{h};
    number_of_temp_data=size(temp_data,1);
    for b=1:number_of_temp_data
        current_data_row=temp_data(b,1);
        reselect_all_decode_data(b,:)=all_decode_data(current_data_row,:);
    end
    all_reselect_all_decode_data{h}= reselect_all_decode_data;    
    
end

all_reselect_sumspk={};
mat_rootpath='C:/Users/zdy/Desktop/106-20240407/';

for c=1:10
    temp_all_reselect_data=[];
    temp_all_reselect_sumspk=[];
    reselect_sumspk=[];
    normalization_sumspkdata=[];
    temp_all_reselect_data=all_reselect_all_decode_data{c};
    temp_all_reselect_sumspk=temp_all_reselect_data(:,1:16);
    reselect_sumspk=squeeze(mean(temp_all_reselect_sumspk,2));
    normalization_sumspkdata=mapminmax(reselect_sumspk', 0, 1);
    all_reselect_sumspk{c}=normalization_sumspkdata;
    
    mat_current_trail=string(c);
    mat_filename='20240407-106-'+mat_current_trail+'.mat';
    mat_fullfilepath=fullfile(mat_rootpath,mat_filename);
    %save(mat_fullfilepath, 'normalization_sumspkdata')
end
