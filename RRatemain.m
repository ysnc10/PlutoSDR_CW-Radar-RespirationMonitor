clear; clc;
Fs = 70e3;    % Sample rate 
Fc = 4.6e9;    % Carrier frequency
F0=300;         % transmitted tone
T=2;
SamplesPerFrame = T*Fs;
Repetation=32;
M=100;

% PlutoSDR RX 
rx = sdrrx('Pluto', ...
    'CenterFrequency', Fc, ...
    'BasebandSampleRate', Fs, ...
    'GainSource','Manual', ...
    'Gain', 61, ...
    'OutputDataType', 'double');

% PlutoSDR TX 
tx = sdrtx('Pluto', ...
    'CenterFrequency', Fc, ...
    'BasebandSampleRate', Fs, ...
    'Gain', 0);

rx.SamplesPerFrame = SamplesPerFrame;

t = (0:SamplesPerFrame-1)' / Fs;
t_new=(0:(Repetation*SamplesPerFrame-1))' / Fs;
tx_signal = exp(1j*2*pi*F0*t); % sinusoidal signal
tx.transmitRepeat(tx_signal); % continuous transmit

disp('Radar operation has been started....');
ind=0;
prev=zeros((Repetation-1)*SamplesPerFrame,1);
bpm=0;t_plot=t_new-Repetation*SamplesPerFrame/ Fs;t_bpm=0;
Detect=0;stop=0;RRate=0;t_plot1=t_plot(1:M:end);

while ind<90
    tic;
    ind=ind+1;
    data = rx();  % IQ data
    data1=[prev;data];
    prev=data1((SamplesPerFrame+1):end);

    phase=unwrap(angle(data1.*exp(-1j*2*pi*F0*t_new)));
    phase1=decimate(phase,M);
    m = movmean(phase1,8000/M);

    [fenvu,fenvl] = envelope(m, 14000/M, 'peak');                                     % Envelope Of received Signal
    [pks,locs] = findpeaks(fenvu,"MinPeakProminence",0.1,"MinPeakDistance",Fs/M);                            % Detect Upper Envelope Peaks

    t_new1=t_new(1:M:end);
    if ind>15
        if length(locs(locs>T*Fs/M*Repetation-30*Fs/M))>=1
            if length(locs(locs>T*Fs/M*Repetation-30*Fs/M))>1
                Detect=1;

                if 60/(RRate+0.1)<(t_plot1(end)-t_plot1(locs(end)))
                    locs1=[locs;length(t_plot1)];
                else
                    locs1=locs;
                end
                RRate = 1/mean(diff(t_new1(locs1(locs1>T*Fs/M*Repetation-30*Fs/M))))*60;
                disp("Presence: Detected");
                if stop>=1 && stop<10
                    disp("Type: apneoa");
                    stop=0;
                else
                    stop=0;
                    if RRate < 10
                        disp('Type: Slow');
                    elseif RRate > 15
                        disp('Type: Fast');
                    else
                        disp('Type: Normal');
                    end
                end
            else
                Detect=1;
                RRate=0;
                disp("Presence: Detected");
                if stop>=1 && stop<10
                    disp("Type: apneoa");%30 50 sec
                    stop=0;
                else
                    stop=0;
                    disp('Type: -');
                end
            end
        else
            RRate=0;
            if Detect==1
                stop=stop+1;
            else
                disp("Presence: unDetected");
            end
            if stop>=10

                disp('Type: Dead');

                Detect=0;
            end

        end
    else
        disp("stabilizing..."),
    end
   
    bpm=[bpm;RRate];
    t_bpm=[t_bpm;t_bpm(end)+2];
    t_plot=t_plot+2;
    t_plot1=t_plot(1:M:end);

    figure(1);
    subplot(2,1,1);
    plot(t_plot,phase);
    
    hold on;
    plot(t_plot1(locs), pks, 'vg', 'MarkerFaceColor','g') ;                                    % Plot Peaks
    hold off;
    ylabel('amplitude ');
    xlabel('time (s)');
    grid on;
    subplot(2,1,2);
    plot(t_bpm, bpm) ;                                    % Plot bpm
    ylabel('bpm');
    xlabel('time (s)');
    grid on; toc

end

% clean up
release(rx);
release(tx);
disp('Radar operation has been stopped.');