
filename = './44.67_modified.csv';
IBI = csvread(filename,1,0);


IBI_time=IBI(:,1);
IBI_value=IBI(:,2);


%[fft_pLF,fft_pHF,fft_LFHFratio,fft_VLF,fft_LF,fft_HF,lomb_lf,RMSSD,PNN50,TRI,TINN,lomb_hf,meanV,stdV,sdsd,qr]=FilterInterpolateWithPercentage(IBI,0.2,10,2,100)
%IBI,lev,minConseq,filter_length,interval

%[timeRatio,sampleRatio,n,filteredTime,filteredValue,fft_pLF,fft_pHF,fft_LFHFratio,fft_VLF,fft_LF,fft_HF,lomb_lf,RMSSD,PNN50,TRI,TINN,lomb_hf,meanV,stdV,sdsd,time]=FilterWithPercentage(IBI,0.2,5,10,2,10)
%IBI,lev,minConseq,threshold_time,filter_length,segmentTime

splitCsvFile(0,'A021AD',4,[2000,2000,1000,1200],'EDA')



