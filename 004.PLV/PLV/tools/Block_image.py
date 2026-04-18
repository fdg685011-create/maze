# -*- coding: utf-8 -*-
"""
Created on Wed Jul 26 14:28:26 2023

@author: pt
"""

import cv2



# for j in range(6):
#     image=cv2.imread(r'E:\zjc\Item-neuron\Experiment1-FixedUnsupervised\StimulusConfig\ImageBlock\0180_001.png')
#     # image=cv2.resize(image,(int(628*0.5),int(1368*0.5)))

#     image[j*int(1368/6):(j+1)*int(1368/6),:,:]=0
#     cv2.imshow('a',image)
#     cv2.imwrite(r'E:\zjc\Item-neuron\Experiment1-FixedUnsupervised\StimulusConfig\ImageBlock/'+'0'+'{0:>1d}.png'.format(j+1),image)
#     if cv2.waitKey(2000) & 0xFF == ord('q'):
#         break
# cv2.destroyAllWindows()


# for j in range(3):
#     image=cv2.imread(r'E:\zjc\Item-neuron\Experiment1-FixedUnsupervised\StimulusConfig\ImageBlock\0180_001.png')
#     # image=cv2.resize(image,(int(628*0.5),int(1368*0.5)))

#     image[:,j*int(628/3):(j+1)*int(628/3),:]=0
#     cv2.imshow('a',image)
#     cv2.imwrite(r'E:\zjc\Item-neuron\Experiment1-FixedUnsupervised\StimulusConfig\ImageBlock/'+'{0:>1d}0.png'.format(j+1),image)
#     if cv2.waitKey(2000) & 0xFF == ord('q'):
#         break
# cv2.destroyAllWindows()

# img=cv2.imread(r'E:\zjc\Item-neuron\Experiment1-FixedUnsupervised\StimulusConfig\ImageBlock\00_001.png')
# gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
# hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
# hls = cv2.cvtColor(img, cv2.COLOR_BGR2HLS)
# cv2.imwrite(r'E:\zjc\Item-neuron\Experiment1-FixedUnsupervised\StimulusConfig\ImageColor/'+'img_001.png',img)
# cv2.imwrite(r'E:\zjc\Item-neuron\Experiment1-FixedUnsupervised\StimulusConfig\ImageColor/'+'gray_001.png',gray)
# cv2.imwrite(r'E:\zjc\Item-neuron\Experiment1-FixedUnsupervised\StimulusConfig\ImageColor/'+'hsv_001.png',hsv)
# cv2.imwrite(r'E:\zjc\Item-neuron\Experiment1-FixedUnsupervised\StimulusConfig\ImageColor/'+'hls_001.png',hls)
# cv2.imshow('a',hls)
# cv2.waitKey(4000)
# cv2.destroyAllWindows()


import os
path=r'E:\zjc\Item-neuron\Experiment1-FixedUnsupervised\StimulusConfig\ImageBackground'
image=cv2.imread(r'E:\zjc\Item-neuron\Experiment1-FixedUnsupervised\StimulusConfig\ImageBlock\00_001.png')
for f in os.listdir(path):
    print(f)
    img=cv2.imread(os.path.join(path,f))
    img=cv2.resize(img,(int(2160),int(3840)))
    # img[int(3840/2-1368/2):int(3840/2+1368/2),int(2160/2-628/2):int(2160/2+628/2),:]=image
    # img=cv2.resize(img,(int(2160/4),int(3840/4)))
    cv2.imwrite(r'E:\zjc\Item-neuron\Experiment1-FixedUnsupervised\StimulusConfig\ImageBackground/'+f[:-4]+'.png',img)
    cv2.imshow('a',img)
    if cv2.waitKey(2000) & 0xFF == ord('q'):
        break
cv2.destroyAllWindows()
