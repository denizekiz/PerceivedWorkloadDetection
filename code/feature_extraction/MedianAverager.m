 function movingAvg =MedianAverager(y,index,interval)
sum=0;
 for i=index-interval:index+interval
     sum=sum+y(i);
 end
 movingAvg=sum/(2*interval+1);
end