rawlfp_data = cat(1,rawlfp_0508_trial,rawlfp_0510_trial,rawlfp_0512_trial,rawlfp_0513_trial,rawlfp_0523_trial,rawlfp_0526_trial,rawlfp_0529_trial);

save(fullfile('data','rawlfp_data.mat'),'rawlfp_data','-v7.3');     