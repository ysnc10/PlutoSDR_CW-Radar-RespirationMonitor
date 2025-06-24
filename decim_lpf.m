T=32;
fs=70e3;
t=0:1/fs:T-1/fs;
x=phase;
% x=detrend(x,6);
figure;
plot(t,x);grid on;title("raw");
figure;
plot((-length(x)/2:length(x)/2-1)*fs/length(x),fftshift(abs(fft(x))));
%%
[b,a]=butter(10,2*1000/fs);%2*70/fs
x1=filter(b,a,x);% x1=x;
figure;
plot(t,x1);grid on;title("filter 70k");ylim([1.8 2.05]);
figure;
plot((-length(x1)/2:length(x1)/2-1)*fs/length(x1),fftshift(abs(fft(x1))));grid on;title("filter 70k");
%%
tic;
M=700;
x2=decimate(x,M);
x3=movmean(x2,4000/M);
[fenvu,fenvl] = envelope(x3,round(7000/M),"peak");% round(15000/M)
figure;
findpeaks(fenvu,"MinPeakProminence",0.05,"MinPeakDistance",50000/M,"Annotate","extents");
t2=t(1:M:end);
figure;
plot(t2,x2);grid on;title("decim 100");%detrend(x3,5)
hold on;
plot(t2,x3);
hold on;
plot(t2,fenvu);legend("dec","mov","fenv");
figure;
plot((-length(x3)/2:length(x3)/2-1)*fs/length(x3)/M,fftshift(abs(fft(x3))));grid on;title("decim 100");toc%Elapsed time is 0.309386 seconds.
%%
[b1,a1]=butter(10,2*M*1.5/fs);%2*70/fs
x4=filter(b1,a1,x3);% x1=x;
figure;
plot(t2,x4);grid on;title("decim filter 100");%ylim([-2.7 -2]);
figure;
plot((-length(x4)/2:length(x4)/2-1)*fs/length(x4)/M,fftshift(abs(fft(x4-mean(x4)))));grid on;title("decim filter 100");