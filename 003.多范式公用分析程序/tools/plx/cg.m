clc
clear all
close all
% 原始信号
fs=1000;
f1=50;
f2=100;
t=0:1/fs:1;
s1=sin(2*pi*f1*t);
s2=sin(2*pi*f2*t);
figure
plot(t, s1,'r');
hold on 
plot(t, s2,'b');