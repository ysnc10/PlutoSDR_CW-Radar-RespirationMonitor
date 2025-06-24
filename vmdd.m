tic;
M=700;
x2=decimate(phase,M);
[imf,residual] = vmd(x2,NumIMFs=9);
cleanphase = sum(imf(:,2:8),2);
figure;
plot(x2);toc
figure;
plot(cleanphase);toc
