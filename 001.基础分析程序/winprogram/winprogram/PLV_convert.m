%% 截取所有试次长时段信号
time_beforemarking=2;
first_marking=refs(1,1);
last_afermarking_temp= refs(size(refs,1),2);
first_beforemarking=first_marking-time_beforemarking;
longtime_divided=floor((last_afermarking_temp-first_beforemarking)*10)/10;
last_aftermarking=first_beforemarking+longtime_divided;

frame_rate=30;
video_frames=longtime_divided*frame_rate;

longtime_begin_position=(first_beforemarking*30000)/6000;
longtime_end_position=(last_aftermarking*30000)/6000;

longtime_data_select=[];
longtime_data_selectint=[];
longtime_data=[];
normalization_longtime_data=[];

longtime_Interval=(longtime_end_position-longtime_begin_position)/((video_frames)-1);
all_longtime_data_selectint=[];
% %all_decode_lfp=all_decode_data(:,17);
% all_decode_lfp=all_data_lfp_all_and_mean(:,4);
% all_decode_lfp_reselect=all_decode_lfp;
% all_decode_lfp_reselect(all_decode_lfp_reselect>20000)=20000;

all_decode_lfp=degree_cha_mean';
all_decode_lfp_reselect=all_decode_lfp;
all_decode_lfp_reselect(all_decode_lfp_reselect>2.6)=0;


for     p=1:(video_frames)
        current_longtime_number=longtime_begin_position+longtime_Interval*(p-1);
        current_longtime_numberint=ceil(current_longtime_number);
        longtime_data_select(p)=(current_longtime_number);
        longtime_data_selectint(p)=(current_longtime_numberint);
        longtime_data(p)=all_decode_lfp_reselect(current_longtime_numberint,1);
        longtime_initial_data(p)=all_decode_lfp(current_longtime_numberint,1);
end

longtime_data_selectint=longtime_data_selectint';
all_longtime_data_selectint=[all_longtime_data_selectint;longtime_data_selectint];
normalization_longtime_data=mapminmax(longtime_data, 0, 1);
% longtime_initial_data=round(longtime_initial_data);

mat_rootpath='C:/Users/zdy/Desktop/092-20240409/';
mkdir(mat_rootpath)

mat_filename_specific_lfp_data = '20240409-092-specific_longtime_data_PLV.mat';
mat_fullfilepath_specific_lfp_data=fullfile(mat_rootpath,mat_filename_specific_lfp_data);
save(mat_fullfilepath_specific_lfp_data, 'longtime_initial_data')

mat_filename_normalization_lfp_data = '20240409-092-normalization_longtime_data_PLV.mat';
mat_fullfilepath_normalization_lfp_data=fullfile(mat_rootpath,mat_filename_normalization_lfp_data);
save(mat_fullfilepath_normalization_lfp_data, 'normalization_longtime_data')



