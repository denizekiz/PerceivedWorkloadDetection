function [timeRatio,sampleRatio,n,filteredTime,filteredValue,fft_pLF,fft_pHF,fft_LFHFratio,fft_VLF,fft_LF,fft_HF,lomb_lf,RMSSD,PNN50,TRI,TINN,lomb_hf,meanV,stdV,sdsd,time]=FilterWithPercentage(IBI,lev,minConseq,threshold_time,filter_length,segmentTime)
%IBI Data : IBI
%minConseq: minimum number of consequtive data points so that data segment can be
%considered meaningful
%filter_length: filter size for median averager. 
%segmentTime: time window for feature extraction
%threshold_time : minimum time interval of data points so that data segment can be
%considered meaningful



%lf : low frequency components
%hf : high frequency components
%mean, std...

IBI_time=IBI(:,1);
IBI_value=IBI(:,2);
EDA_period=1/4;
percent_change(1)=0;
filter_length=3;
%This is using percentage filter instead of static threshold and determine
%artifacts
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
%plot(IBI_time,[0;bottomLine],'g',IBI_time,[0;topLine],'r*');

%delete artifact data

CC= bwconncomp(isnan(topLine));
n = cellfun('prodofsize',CC.PixelIdxList);
b = zeros(size(topLine));
for ii = 1:CC.NumObjects
  b(CC.PixelIdxList{ii}) = n(ii);
end

i=1;
sI=1;
eI=1;
startIndex=-1;
%check if sample segment has more samples than minConseq
while i <= length(b)
    if(b(i)~=0 && b(i)>minConseq)
        startIndex(sI)=i;
        endIndex(eI)=i+b(i)-1;
        sI=sI+1;
        eI=eI+1;
        i=i+b(i);
    elseif (b(i)==0)
        i=i+1;
    elseif (b(i)<=minConseq)
        i=i+b(i);
    end
    
end


timeTotal=IBI_time(length(IBI_time))-IBI_time(1);
sampleTotal=length(b);

if(startIndex~=-1)
validTime=0;
for i=1:length(startIndex)
    validTime=validTime + (IBI_time(endIndex(i))-IBI_time(startIndex(i)));
end

validTime=0;
for i=1:length(startIndex)
    validTime=validTime + (IBI_time(endIndex(i))-IBI_time(startIndex(i)));
end
end
filteredTime=[];
filteredValue=[];
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
time=[];


%data is not consequtive now. For each cnsequtive part, divide data to
%segment times and extract features for each part.
if(startIndex~=-1)
for i=1:length(startIndex)
    if(IBI_time(endIndex(i))-IBI_time(startIndex(i))>threshold_time)
        for count=1:floor((IBI_time(endIndex(i))-IBI_time(startIndex(i))) / segmentTime)
            intermediateIndexLow=min(find(IBI_time(startIndex(i))+segmentTime*(count-1)<IBI_time & IBI_time<IBI_time(startIndex(i))+(segmentTime*count)));
            intermediateIndexHigh=min(find(IBI_time(startIndex(i))+segmentTime*(count)<IBI_time & IBI_time<IBI_time(startIndex(i))+(segmentTime*(count+1))));
            timeSegmentToAdd=IBI_time(intermediateIndexLow:intermediateIndexHigh);
            valueSegmentToAdd=IBI_value(intermediateIndexLow:intermediateIndexHigh);
            if(isempty(timeSegmentToAdd))
                timeSegmentToAdd=IBI_time(startIndex(i):endIndex(i));
                valueSegmentToAdd=IBI_value(startIndex(i):endIndex(i));
                break
            end
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
            sdsd=vertcat(sdsd, HRV.SDSD(valueSegmentToAdd));
            meanV=vertcat(meanV, mean(valueSegmentToAdd));
            stdV=vertcat(stdV,std(valueSegmentToAdd));
            TINN = vertcat(TINN,HRV.TINN(valueSegmentToAdd));
            TRI = vertcat(TRI,HRV.TRI(valueSegmentToAdd));
            PNN50 = vertcat(PNN50,HRV.pNN50(valueSegmentToAdd));
            RMSSD = vertcat(RMSSD,HRV.RMSSD(valueSegmentToAdd));
        %hundredPer=EDA(round(IBI_time(startIndex(i)))/EDA_period:round(IBI_time(endIndex(i)))/EDA_period);
            timeDiff=IBI_time(endIndex(i))-IBI_time(startIndex(i));
       % peakpersecond=vertcat(peakpersecond,length(findpeaks(hundredPer))/timeDiff);
            time=vertcat(time,(IBI_time(endIndex(i))+IBI_time(startIndex(i)))/2);
            filteredTime=vertcat(filteredTime,timeSegmentToAdd );
            filteredValue=vertcat(filteredValue, IBI_value(startIndex(i):endIndex(i)));
        end
    end
    
end

validSample=0;
for i=1:length(startIndex)
    validSample=validSample + (endIndex(i)-startIndex(i));
end

timeRatio=validTime/timeTotal;
sampleRatio=validSample/sampleTotal;
else
timeRatio=0;
sampleRatio=0;
end



%hist(n,100);
end