function splitCsvFile(filePath, labelArray, noOfSegments, durationArray)
%filePath: the full path of the file that will be divided
%device Name: unique device name for Empatica E4 device.
%noOfSegments: The number of segments that the file will be divided
%durationArray: the duration of segments given in seconds. (It would be an array)
% noOfSegments: how many parts you want to divide the file
%durationArray: give the durations of each segments in seconds. (If not given, divide the file equally.)

fileType='';

%determining the file type from path name
if(contains(filePath, 'EDA'))
    fileType='EDA';
elseif(contains(filePath, 'IBI')) 
    fileType='IBI';
elseif(contains(filePath, 'HR')) 
    fileType='HR';
elseif (contains(filePath,'TEMP'))
    fileType='TEMP';
elseif (contains(filePath,'BVP'))
    fileType='BVP';
else (contains(filePath,'ACC'))
    fileType='ACC';
end
samplingFrequency=0

fileID = fopen(filePath);
C = textscan(fileID,'%s')
%start time of the session
startTime=str2num(C{1}{1}) 


%determining the sampling frequency of physiological signal
if(strcmp(fileType,'EDA'))
    samplingFrequency=4;
elseif (strcmp(fileType,'HR'))
    samplingFrequency=1;
elseif (strcmp(fileType,'ACC'))
    samplingFrequency=32;
elseif (strcmp(fileType,'TEMP'))
    samplingFrequency=4; 
else (strcmp(fileType,'BVP'))
    samplingFrequency=64;
end
alldata = csvread(filePath,1,0);

if(strcmp(fileType,'IBI'))
    time=alldata(:,1);  
    data=alldata(:,2);
elseif(strcmp(fileType,'ACC'))
    data=alldata(2:end,1); 
    data1=alldata(2:end,2); 
    data2=alldata(2:end,3); 
else
    data=alldata(2:end,1);
end

sampleTotal=length(data);
%take the data from files and length of data


timeAndSampleArr=[startTime;samplingFrequency];
%the first two line would be start time and sampling frequency
if(isempty(durationArray))
 %if durationArray is not given, divide equally   
for n=1:noOfSegments
    start=(n-1)* (sampleTotal / noOfSegments) +1;
    endData=(n)* (sampleTotal / noOfSegments);
    dataSegment=data(start:endData);
    if(strcmp(fileType,'IBI'))
        dataSegment=cat(1,startTime,  dataSegment);
        timeSegment=time(start:endData);
        timeSegment=cat(1,startTime,  timeSegment);
        dataSegment = cat(2, timeSegment, dataSegment);
    elseif(strcmp(fileType,'ACC'))
        dataSegment=data(start:endData);
        dataSegment=cat(1,timeAndSampleArr,  dataSegment);
        dataSegment1=data1(start:endData);
        dataSegment1=cat(1,timeAndSampleArr,  dataSegment1);
        dataSegment2=data2(start:endData);
        dataSegment2=cat(1,timeAndSampleArr,  dataSegment2);
        dataSegment = cat(2, dataSegment,dataSegment1,dataSegment2);
    else
        dataSegment=cat(1,timeAndSampleArr,  dataSegment);
    end
    add=strcat(fileType,".csv")
    prefix= extractBefore(filePath,add);
    folder=strcat(prefix,num2str(n),'\')
    if ~exist(folder , 'dir')
        mkdir (folder);
    end
    newFileName=strcat(prefix,num2str(n),'\',fileType,'.csv');
    csvwrite(newFileName,dataSegment);
end
    
else
    %divide data with given duration Array
totalTimePassed=0; 
for n=1:noOfSegments
    if(strcmp(fileType,'IBI'))
        start=min(find(time>totalTimePassed)) ;
        endData=max(find(time < totalTimePassed+ durationArray(n)));
        dataSegment=data(start:endData);
        dataSegment=cat(1,startTime,  dataSegment);
        timeSegment=time(start:endData);
        timeSegment=cat(1,startTime,  timeSegment);
        dataSegment = cat(2, timeSegment, dataSegment);
        add=strcat(fileType,".csv");
        prefix= extractBefore(filePath,add);
        folder=strcat(prefix,num2str(n),'\')
        if ~exist(folder , 'dir')
            mkdir (folder);
        end
        newFileName=strcat(prefix,num2str(n),'\',fileType,'.csv');
        csvwrite(newFileName,dataSegment);
    else            
        start=totalTimePassed*samplingFrequency +1 ;
        endData=totalTimePassed*samplingFrequency+durationArray(n)*samplingFrequency;
        if(strcmp(fileType,'ACC'))
            dataSegment=data(start:endData);
            dataSegment=cat(1,timeAndSampleArr,  dataSegment);
            dataSegment1=data1(start:endData);
            dataSegment1=cat(1,timeAndSampleArr,  dataSegment1);
            dataSegment2=data2(start:endData);
            dataSegment2=cat(1,timeAndSampleArr,  dataSegment2);
            dataSegment = cat(2, dataSegment,dataSegment1,dataSegment2);
        else    
            dataSegment=data(start:endData);
            dataSegment=cat(1,timeAndSampleArr,  dataSegment);
        end
        add=strcat(fileType,".csv");
        prefix= extractBefore(filePath,add);
        folder=strcat(prefix,num2str(n),'\')
        if ~exist(folder , 'dir')
            mkdir (folder);
        end
        newFileName=strcat(prefix,num2str(n),'\',fileType,'.csv');
        csvwrite(newFileName,dataSegment);
    end
    totalTimePassed=totalTimePassed+durationArray(n);
    
    %create label file for Russell Puzzle Task.
    %labelFileName=strcat(prefix,num2str(n),'\','labels','.csv');
    %labelStr=strcat(prefix,'_',num2str(n),',', num2str(labelArray(n)))
    %csvwrite(labelFileName,labelStr);
    
end


end