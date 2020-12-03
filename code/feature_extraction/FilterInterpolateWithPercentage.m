function [fft_pLF,fft_pHF,fft_LFHFratio,fft_VLF,fft_LF,fft_HF,lomb_lf,RMSSD,PNN50,TRI,TINN,lomb_hf,meanV,stdV,sdsd,qr]=FilterInterpolateWithPercentage(IBI,lev,minConseq,filter_length,interval)

%IBI Data : IBI
%minConseq: minimum number of consequtive data points so that data can be
%considered meaningful
%filter_length: filter size for median averager. 
%interval: time window for feature extraction


%lf : low frequency components
%hf : high frequency components
%mean, std...

IBI_time=IBI(:,1);
IBI_value=IBI(:,2);
EDA_period=1/4;
percent_change(1)=0;
%percentage threshold : determine artifacts
for i=2:filter_length
    percent_change(i)=(IBI_value(i)-IBI_value(i-1))/IBI_value(i);
end
if(length(IBI_value)>2*filter_length)
for i=filter_length+1:length(IBI_value)-filter_length
    percent_change(i)=(IBI_value(i)-MedianAverager(IBI_value,i,filter_length))/IBI_value(i);
end
end
for i=length(IBI_value)-filter_length+1:length(IBI_value)
    percent_change(i)=(IBI_value(i)-IBI_value(i-1))/IBI_value(i);
end

% Find points above the level
aboveLine = (abs(percent_change)>=lev);
% Create 2 copies of y
bottomLine = percent_change;
topLine = percent_change;
% Set the values you don't want to get drawn to nan
bottomLine(aboveLine) = NaN;
topLine(~aboveLine) = NaN;
IBI_value(aboveLine)=NaN;

%Create a copy of IBI_value
c_IBI_value = IBI_value;

%spline interpolation to replace artifacts
s = spline(IBI_time,IBI_value,IBI_time(aboveLine));
IBI_value(aboveLine)=s;
%plot(IBI_time,[0;bottomLine],'g',IBI_time,[0;topLine],'r*');

totalTime=IBI_time(end);
lomb_lf=[];
lomb_hf=[];
PNN50= [];
TINN = [];
TRI = [];
RMSSD = [];
fft_pHF= [];
fft_pLF = [];
fft_LFHFratio = [];
fft_VLF = [];
fft_LF = [];
fft_HF = [];
sdsd = [];
meanV=[];
stdV=[];
qr = [];

%divide data to intervals and extract features for each interval
for count=1:0.5:totalTime / interval
    t=IBI_time(find(IBI_time>interval*(count-1) & IBI_time<interval*count));
    y=IBI_value(find(IBI_time>interval*(count-1) & IBI_time<interval*count));
    y_m = c_IBI_value(find(IBI_time>interval*(count-1) & IBI_time<interval*count));
    number_of_nan = sum(isnan(y_m));
    total_number = length(y);
    quality_ratio = (total_number - number_of_nan)/total_number;
    IBI_frag= [t y];
    
   if(length(IBI_frag)>minConseq)
         timeSegmentToAdd=t;
        valueSegmentToAdd=y;
        [ratio,LF,HF]=Lomb_S(valueSegmentToAdd,timeSegmentToAdd);
        lomb_lf=vertcat(lomb_lf,LF);
        lomb_hf=vertcat(lomb_hf,HF);
        [pLF,pHF,LFHFratio,VLF,LF,HF,f,Y,NFFT] = HRV.fft_val_fun(valueSegmentToAdd,1000);
        fft_pLF = vertcat(fft_pLF,pLF);
        fft_pHF = vertcat(fft_pHF,pHF);
        fft_LFHFratio = vertcat(fft_LFHFratio,LFHFratio);
        fft_VLF = vertcat(fft_VLF,VLF);
        fft_LF = vertcat(fft_LF,LF);
        fft_HF = vertcat(fft_HF,HF);
        qr = vertcat(qr,quality_ratio);
        sdsd=vertcat(sdsd, HRV.SDSD(valueSegmentToAdd));
        meanV=vertcat(meanV, mean(valueSegmentToAdd));
        stdV=vertcat(stdV,std(valueSegmentToAdd));
        TINN = vertcat(TINN,HRV.TINN(valueSegmentToAdd));
        TRI = vertcat(TRI,HRV.TRI(valueSegmentToAdd));
        PNN50 = vertcat(PNN50,HRV.pNN50(valueSegmentToAdd));
        RMSSD = vertcat(RMSSD,HRV.RMSSD(valueSegmentToAdd));
        %hundredPer=EDA(round(IBI_time(startIndex(i)))/EDA_period:round(IBI_time(endIndex(i)))/EDA_period);
       % peakpersecond=vertcat(peakpersecond,length(findpeaks(hundredPer))/timeDiff);
    end
    
end




%hist(n,100);
end