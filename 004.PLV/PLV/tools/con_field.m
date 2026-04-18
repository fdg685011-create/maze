function [rect_all] = con_field(stim)

    con_field_size=stim.MotionFieldRegion;%%左右上下的边界
    con_field_obj_size=stim.ObjSize;%%目标尺寸
    
    if exist(strcat('StimulusConfig\Motion\confield_rowsize_',num2str(con_field_size(2)-con_field_size(1)+1),...
        '_linesize_',num2str(con_field_size(4)-con_field_size(3)+1),'.mat'))
        load(strcat('StimulusConfig\Motion\confield_rowsize_',num2str(con_field_size(2)-con_field_size(1)+1),...
            '_linesize_',num2str(con_field_size(4)-con_field_size(3)+1),'.mat'));
        disp(strcat('StimulusConfig\Motion\confield_rowsize_',num2str(con_field_size(2)-con_field_size(1)+1),...
            '_linesize_',num2str(con_field_size(4)-con_field_size(3)+1),'.mat'))
        save(strcat('Data\',stim.ExperimentName,'\confield_rowsize_',num2str(con_field_size(2)-con_field_size(1)+1),...
        '_linesize_',num2str(con_field_size(4)-con_field_size(3)+1),'.mat'),'stim_ser');
    else
        num_row=floor((con_field_size(2)-con_field_size(1)+1)/con_field_obj_size);
        num_line=floor((con_field_size(4)-con_field_size(3)+1)/con_field_obj_size);
        stim_ser=[randperm(2*num_line) randperm(2*num_row)];
        save(strcat('StimulusConfig\Motion\confield_rowsize_',num2str(con_field_size(2)-con_field_size(1)+1),...
            '_linesize_',num2str(con_field_size(4)-con_field_size(3)+1),'.mat'),'stim_ser');
        save(strcat('Data\',stim.ExperimentName,'\confield_rowsize_',num2str(con_field_size(2)-con_field_size(1)+1),...
            '_linesize_',num2str(con_field_size(4)-con_field_size(3)+1),'.mat'),'stim_ser');
    end

    Height            = con_field_size(2)-con_field_size(1)+1;
    Width             = con_field_size(4)-con_field_size(3)+1; 
    aa                = 1:con_field_obj_size:Height;
    bb                = 1:con_field_obj_size:Width;
    X1                = reshape(repmat(bb,length(aa),1),[],1);
    Y1                = repmat(aa',length(bb),1);
    s                 = reshape((1:length(aa)*length(bb))',length(aa),[]);
    randser_x         = stim_ser(1,1:length(bb)*2);
    randser_y         = stim_ser(1,length(bb)*2+1:end);
    randser_1          = [s,flipud(s)];
    randser_2          = [s',flipud(s')];
    randser1          = reshape(randser_1(:,randser_x),[],1);%
    randser2          = reshape(randser_2(:,randser_y),[],1);%
    randser_all       = [randser1;randser2];
    rect_all          = [X1(randser_all,:)+con_field_size(3)-1,Y1(randser_all,:)+con_field_size(1)-1,...
        X1(randser_all,:)+con_field_obj_size-1+con_field_size(3)-1,Y1(randser_all,:)+con_field_obj_size-1+con_field_size(1)-1];
end


