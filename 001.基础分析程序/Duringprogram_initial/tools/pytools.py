import numpy as np
import tsfel
import math
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import matplotlib.gridspec as gridspec
from sklearn.preprocessing import MinMaxScaler
from collections import Counter
from matplotlib import rcParams
rcParams['font.size'] = 10   # 设置字体大小为14

def f_sl_binsl(data,bin_,step):
    B = np.ones([bin_,])
    tim,channel=data.shape
    outputdata=np.zeros_like(data)
    for ch in range(channel):
        data_ch=data[:,ch]
        outputdata[:,ch]=np.convolve(data_ch, B, mode='same')*1000/bin_
    outputdata=outputdata[0:tim:step,:]
    return outputdata

def datashow(data,refs,label,fs,savename):
    channel = data.shape[1]  # 数据采集通道
    fig = plt.figure(figsize=(25,14))
    gs = gridspec.GridSpec(channel, 1)
    plt.title('data refs and label',fontsize = 20)
    plt.axis('off')
    for ch in range(channel):
        # 创建子图1
        ax1 = fig.add_subplot(gs[ch, 0])
        ax1.plot(data[:, ch], linewidth=0.8)
        ax1.get_xaxis().set_visible(False)
        ax1.set_ylabel('ch-'+str(ch),fontsize = 15)
        #添加矩形阴影
        for r in refs:
            ax1.add_patch(
                patches.Rectangle((r[0]*fs, np.min(data[:, ch])), (r[1] - r[0]) * fs, np.max(data[:, ch]) - np.min(data[:, ch]) + 0.1, edgecolor=["red", 'green'][int(r[2])], facecolor=["red", 'green'][int(r[2])], fill=True, alpha=0.2)
            )
        label_ch=label[:,ch]
        label_ch=np.diff(label_ch)
        start=np.where(label_ch==1)[0]
        stop=np.where(label_ch==-1)[0]
        for r in range(len(start)):
            ax1.add_patch(
                patches.Rectangle((start[r], np.min(data[:, ch])), stop[r] - start[r], np.max(data[:, ch]) - np.min(data[:, ch]) + 0.1, edgecolor="blue", facecolor="blue", fill=True, alpha=0.2)
            )
    # 添加图形
    fig.tight_layout()
    plt.savefig(savename, dpi=600,bbox_inches = 'tight')

def featget(data, refs, label, window, ch, fs, domain):
    feat = []
    for t in range(window, data.shape[0]):
        feat.append(data[t - window:t, ch])
    # 提取特征
    cfg_file = tsfel.get_features_by_domain(domain)  # 14个时域特征
    x_train = tsfel.time_series_features_extractor(cfg_file, feat)
    ref=refs.copy()
    ref[:, 0:2]= ref[:, 0:2] - window / 2 / fs
    label = np.transpose(np.tile(label[window // 2:-window // 2, ch], (x_train.values.shape[1], 1)))

    return x_train,ref,label

def calsel(inputdata,label,savename):
    data=inputdata.copy()
    #异常值处理
    uplimit=np.tile(np.mean(data,0)+4*np.std(data,0),(data.shape[0],1))
    data=np.min([data,uplimit],0)
    #数据归一化
    x_norm=MinMaxScaler().fit_transform(data)
    label_count = Counter(label)
    s = np.zeros([x_norm.shape[1],len(label_count)+1])
    fig = plt.figure(figsize=(25,14))
    for ch in range(0,x_norm.shape[1]):
        hist = np.zeros([20,len(label_count)])
        data_show=[]
        for index,c in enumerate(label_count):
            data_cla=x_norm[label == c, ch]
            data_show.append(data_cla)
            hist_, bins = np.histogram(data_cla, range=(0, 1), bins=20)
            hist[:,index] = hist_ / data_cla.shape[0]

        for index, c in enumerate(label_count):
            a=list(range(0,len(label_count)))
            a.remove(index)
            s[ch,index]=(np.sum(np.max(hist,1))-np.sum(np.max(hist[:,a],1)))/np.sum(hist[:,index])
        s[ch,-1]=sum([s[ch,i]*np.sum(hist[:,i]) for i in range(len(label_count))])/np.sum(np.max(hist,1))

        plt.subplot(4, math.ceil(x_norm.shape[1]/4), ch+1)
        plt.boxplot(data_show)
        plt.xticks(list(range(1,len(label_count)+1)),['label'+str(i)+'({:.2f})'.format(s[ch,i]) for i in range(len(label_count))], fontsize=8)
        plt.title('feature_'+str(ch)+'({:.2f})'.format(s[ch,-1]))
        plt.ylabel('norm spk')
    fig.tight_layout()
    plt.savefig(savename, dpi=600,bbox_inches = 'tight')
    return s