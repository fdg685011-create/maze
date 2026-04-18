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


mat_rootpath='C:/Users/zdy/Desktop/20ms_test/';
all_reselect_all_decode_result={};
result_T=result';

for h=1:10
    temp_data=[];
    current_data_row=[];
    reselect_all_decode_data=[];
    reselect_all_decode_result=[];
    temp_data=reselect_data_rows{h};
    number_of_temp_data=size(temp_data,1);
    for b=1:number_of_temp_data
        current_data_row=temp_data(b,1);
        reselect_all_decode_data(b,:)=all_decode_data(current_data_row,:);
        reselect_all_decode_result(b,:)=result_T(current_data_row,:);
    end
    all_reselect_all_decode_data{h}= reselect_all_decode_data;    
    all_reselect_all_decode_result{h}= reselect_all_decode_result;  
    reselect_all_decode_result_T=reselect_all_decode_result';
    
    mat_current_trail=string(h);
    mat_filename='20240122-629-decode_result-'+mat_current_trail+'.mat';
    mat_fullfilepath=fullfile(mat_rootpath,mat_filename);
    save(mat_fullfilepath, 'reselect_all_decode_result_T')
    
end


