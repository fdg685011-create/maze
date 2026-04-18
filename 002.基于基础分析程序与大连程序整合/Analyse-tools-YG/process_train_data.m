function [lfp6080_train, lfp3045_train, lfp510_train, spk_rate_train] = process_train_data(refs_train, spk_rate, rawlfp, downfs)
    lfp6080_train = {};
    lfp3045_train = {};
    lfp510_train = {};
    spk_rate_train = {};
    
    for i = 1:size(refs_train, 1)
        disp(i);
        % 获取试次的开始时间、结束时间和标签
        start_time = refs_train(i, 1);
        end_time = refs_train(i, 2);
        label = refs_train(i, 3);
        
        % 截取该试次的spike发放率和LFP信号
        [spk_rate_subset, lfp_subset] = extract_data(spk_rate, rawlfp, start_time, end_time, downfs);
        
        % 对LFP信号进行STFT并提取频带能量
        [lfp6080, lfp3045, lfp510] = process_lfp(lfp_subset, downfs);
        
        % 将结果存储到元胞数组中
        lfp6080_train{i, 1} = lfp6080;
        lfp6080_train{i, 2} = label;
        
        lfp3045_train{i, 1} = lfp3045;
        lfp3045_train{i, 2} = label;
        
        lfp510_train{i, 1} = lfp510;
        lfp510_train{i, 2} = label;
        
        spk_rate_train{i, 1} = spk_rate_subset;
        spk_rate_train{i, 2} = label;
    end
end
