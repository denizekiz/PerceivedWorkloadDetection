function [ratio,LF,HF] =Lomb_S(y,t)

[pxx,f]=plomb(y,t);

VLF = sum(pxx(find(f<=0.04)));

LF=sum(pxx(find(f<=0.15)))- VLF;

HF=sum(pxx(find(f<=0.40)))-LF;

ratio=LF/HF;

end
