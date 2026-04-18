function [acc_mean_num,acc_mean,coeff,mu,idx,mdl]=LfpPCA(sum_on,sum_off) 
% 假设你有一个m行n列的数据矩阵X，其中m是样本数量（这里是trial -不同类别的放在一起），n是特征数量 
%      sum_on=squeeze(mean(bin_lfp_on,1));
%       sum_off=squeeze(mean(bin_lfp_off,1));
      sum_fea=[sum_on;sum_off];
      fea=sum_fea; 

%% 加标签  分类 
gnd1=ones(size(sum_on,1),1);
gnd2=2*ones(size(sum_off,1),1);
gnd=[gnd1;gnd2];
data=[fea, gnd];
[data_r,data_c]=size(data);
acc_mean_num=[];
for num=1:100
%% 将数据样本随机分割为10部分 十折交叉验证
indices = crossvalind('Kfold', data_r, 10);
for i = 1 : 10
    % 获取第i份测试数据的索引逻辑值 1份测试，9份训练
    test = (indices == i);
    % 取反，获取第i份训练数据的索引逻辑值
    train = ~test;
    %% 训练 
    train_data = data(train, 1 : data_c - 1);
    train_label = data(train, data_c); 
    %% 计算训练数据集 train_data 的主成分。
  [coeff,scoreTrain,~,~,explained,mu] = pca(train_data);
  %  coeff（主成分系数）和 mu（XTrain 的估计均值）将 PCA 应用于测试数据集。
  %  在训练模型时，请使用 scoreTrain（主成分分数）而不是 XTrain。
  % explained可用来计算降维后取多少维度能够达到自己需要的精度
  idx = find(cumsum(explained)>95,1);% 将特征的累计贡献率不小于0.95的维数作为PCA降维后特征的个数
  idx(idx<=3)=3;  idx(idx>=10)=10;
  scoreTrain95=scoreTrain(:,1:idx); % 取转换后的矩阵score的前idx列为PCA降维后特征
    %% 测试
    test_data = data(test, 1 : data_c - 1);
    test_label = data(test, data_c);
    scoreTest95 = (test_data-mu)*coeff(:,1:idx); %%测试集投影转化
    % 使用数据的代码 
 %% KNN k近邻分类
    k = 5;
     mdl = fitcknn(scoreTrain95, train_label, 'NumNeighbors', k);  %% 训练分类器模型得出mdl
 %   mdl = fitcknn(scoreTrain95, train_label, 'Distance', 'Euclidean', 'Exponent', [], 'NumNeighbors', 1,  'DistanceWeight', 'Equal', 'Standardize', true, 'ClassNames', [0; 1]);

   % 预测测试集数据
   Ypred = predict(mdl, scoreTest95);
   % 评估模型性能
   accuracy1 = sum(Ypred==test_label) / numel(test_label);
   acc(i,:)=accuracy1;  
end
acc_num(:,num)=acc;  
acc_mean=mean(acc);
acc_mean_num(:,num)=acc_mean;
end
%% %% 绘制聚类结果 三维 绘制最后i=100的结果
figure
scatter3(scoreTrain95(train_label==1,1), scoreTrain95(train_label==1,2), scoreTrain95(train_label==1,3),'ro')
% scatter3(testData(testLabel==1,1), testData(testLabel==1,2), testData(testLabel==1,3),'r*')
hold on;
scatter3(scoreTrain95(train_label==2,1), scoreTrain95(train_label==2,2), scoreTrain95(train_label==2,3),'bo')
scatter3(scoreTest95(test_label==1,1), scoreTest95(test_label==1,2), scoreTest95(test_label==1,3),'r*')
scatter3(scoreTest95(test_label==2,1), scoreTest95(test_label==2,2), scoreTest95(test_label==2,3),'b*') 
scatter3(scoreTest95(Ypred==1,1), scoreTest95(Ypred==1,2), scoreTest95(Ypred==1,3),'r+')
scatter3(scoreTest95(Ypred==2,1), scoreTest95(Ypred==2,2), scoreTest95(Ypred==2,3),'b+') 

legend('trainData1','trainData2','test1','test2','预测1','预测2'...
       ,'Location','NW')  %
xlabel('1st Principal Component')
ylabel('2nd Principal Component')
zlabel('3rd Principal Component')
title(strcat('PCA降维聚类-准确率',num2str(acc_mean)));
hold off;

%% 实时绘制分类结果 三维  先构建出PCA降维与分类器模型
 
% testData1=[sum_on;sum_off];
% 
%     scoreTest95 = (testData1-mu)*coeff(:,1:idx); %%测试集投影转化 
%     figure
%     Test_predicted = predict(mdl,scoreTest95); %预测测试集的评分类别
%     scatter3(scoreTest95(Test_predicted==1,1), scoreTest95(Test_predicted==1,2), scoreTest95(Test_predicted==1,3),'r*')
%    hold on 
%     scatter3(scoreTest95(Test_predicted==2,1), scoreTest95(Test_predicted==2,2), scoreTest95(Test_predicted==2,3),'b*') 
% %     set(gca,'xlim',[min(scoreTrain95(:,1)),max(scoreTrain95(:,1))]) 
%         set(gca,'ylim',[min(scoreTrain95(:,2)),max(scoreTrain95(:,2))]) 
%         set(gca,'zlim',[min(scoreTrain95(:,3)),max(scoreTrain95(:,3))]) 
% % xlim([-30,30]) %%需要调试具体的
% %      ylim([-30,30])
% %      zlim([-30,30])
% legend('预测1','预测2'...
%        ,'Location','NW')  %'trainData1','trainData2',
% xlabel('1st Principal Component')
% ylabel('2nd Principal Component')
% zlabel('3rd Principal Component')
% title('PCA降维分类', (strcat('-准确率',num2str(accuracy1))));
end