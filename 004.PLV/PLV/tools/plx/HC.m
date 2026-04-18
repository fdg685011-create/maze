 clc
 clear all
 close all
 load D:\王虎\数据\20230724\数据\datalfp1
 load D:\王虎\数据\20230724\数据\dataspk1
 datalfp1=datalfp;
 dataspk1=dataspk;
 clear datalfp dataspk
 load D:\王虎\数据\20230724\数据\datalfp2
 load D:\王虎\数据\20230724\数据\dataspk2
 datalfp2=datalfp;
 dataspk2=dataspk;
 clear datalfp dataspk
 datalfp=[datalfp1;datalfp2];
 dataspk=[dataspk1;dataspk2];