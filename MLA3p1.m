% get audio file and info
[audioData, fs] = audioread('vol90len60-1.caf');
info = audioinfo('vol90len60-1.caf');
disp(info)

% Calculate number of samples to skip (0.5 seconds)
samplesToSkip = round(0.5 * fs);

% Trim the first 0.5 seconds from the audio data
audioData = audioData(samplesToSkip+1:end); % Keep data from 0.5s onward

% Band Pass Filter
filteredAudioData = bandpass(audioData, [17000 19000], fs)

% Smoothing using a Savitzky-Golay filter
%polynomialOrder = 3; % Order of polynomial fit
%frameSize = 2001; % Frame size (must be an odd number)
%smoothedData = sgolayfilt(audioData, polynomialOrder, frameSize);

%compute envelope
env = envelope(filteredAudioData)

% Plot the waveform
t = (0:length(filteredAudioData)-1) / fs;
figure;
plot(t, filteredAudioData, 'b');
hold on;
%plot(t, smoothedData, 'g', 'LineWidth', 1.5); % Smoothed signal in green
plot(t, env, 'r', 'LineWidth', 1.5); % Envelope in red
xlabel('Time (s)');
ylabel('Amplitude');
title('Audio Signal with Envelope');
legend('Original Signal', 'Envelope');
hold off;

%FFT
env_fft = mag2db(abs(fft(env)))

% Create frequency vector for x-axis
N = length(env); % Number of samples in the envelope
f = (0:N-1) * (fs / N); % Frequency vector

% Find the indices corresponding to the .2-.33 Hz range
freq_range = (f >= .2 & f <= 0.3333); % Logical index for .2-.33 Hz range

% Plot only the desired frequency range
figure;
plot(f(freq_range), env_fft(freq_range));
xlabel('Frequency (Hz)');
ylabel('Amplitude (dB)');
title('Frequency Spectrum of the Envelope (.2 - .33 Hz)');

