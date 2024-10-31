% get audio file and info
[audioData, fs] = audioread('push.caf');
info = audioinfo(['push.caf']);
disp(info)

% Band Pass Filter
filteredAudioData = bandpass(audioData, [17500 18500], fs)

% Parameters
windowLength = round(0.02 * fs); % 50 ms window length
overlap = round(0.2 * windowLength); % 50% overlap
centerFreq = 18000; % Center frequency at 18 kHz
freqRange = 100; % Frequency range around 18 kHz to check for Doppler shift
pushThreshold = 5; % Threshold in dB for push gesture
pullThreshold = 5; % Threshold in dB for pull gesture

% Create frequency vector for x-axis (for one window)
f = (0:windowLength-1) * (fs / windowLength);

% Initialize arrays to store push and pull amplitudes for each window
pushAmplitudes = [];
pullAmplitudes = [];
timeStamps = [];

% Loop through the audio data in windows
numWindows = floor((length(filteredAudioData) - windowLength) / (windowLength - overlap)) + 1;
for i = 1:numWindows
    % Define the start and end indices of the current window
    startIdx = (i-1) * (windowLength - overlap) + 1;
    endIdx = startIdx + windowLength - 1;

    % Extract the current window of data
    windowData = filteredAudioData(startIdx:endIdx);

    % Compute FFT and magnitude in dB
    window_fft = fft(windowData);
    window_fft_magnitude = mag2db(abs(window_fft));

    % Identify frequency bins for Doppler shift range (17.8kHz - 18.2kHz)
    pushBins = f >= (centerFreq + 0) & f <= (centerFreq + freqRange); % Above 18kHz
    pullBins = f >= (centerFreq - freqRange) & f <= (centerFreq - 0); % Below 18kHz

    % Calculate average amplitude in dB for push and pull bins
    pushAmplitude = mean(window_fft_magnitude(pushBins));
    pullAmplitude = mean(window_fft_magnitude(pullBins));

    % Store results
    pushAmplitudes = [pushAmplitudes, pushAmplitude];
    pullAmplitudes = [pullAmplitudes, pullAmplitude];
    timeStamps = [timeStamps, (startIdx + endIdx) / (2 * fs)]; % Midpoint of each window

    % Threshold check for gesture detection in this window
    if pushAmplitude > pushThreshold
        disp(['Push gesture detected in window ' num2str(i)]);
    elseif pullAmplitude > pullThreshold
        disp(['Pull gesture detected in window ' num2str(i)]);
    else
        disp(['No gesture detected in window ' num2str(i)]);
    end
end

% Parameters for spectrogram
windowLength = round(0.05 * fs); % 50 ms window
overlap = round(0.5 * windowLength); % 50% overlap
nfft = 2^nextpow2(windowLength); % FFT length for spectrogram

% Compute spectrogram
[s, f, t] = spectrogram(filteredAudioData, windowLength, overlap, nfft, fs);

% Convert to dB
s_db = mag2db(abs(s));

% Plot spectrogram
figure;
imagesc(t, f, s_db);
axis xy; % Flip the y-axis for better readability
colormap jet;
colorbar;
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title('Spectrogram with Gesture Annotations');

% Highlight Doppler frequency range (17.8kHz to 18.2kHz)
hold on;
yline(17800, '--r', '17.8kHz');
yline(18200, '--g', '18.2kHz');
hold off;



% Plot time-series of amplitudes
figure;
plot(timeStamps, pushAmplitudes, 'r', 'DisplayName', 'Push Amplitude');
hold on;
plot(timeStamps, pullAmplitudes, 'b', 'DisplayName', 'Pull Amplitude');
yline(pushThreshold, '--k', 'Push Threshold');
yline(pullThreshold, '--k', 'Pull Threshold');
xlabel('Time (s)');
ylabel('Amplitude (dB)');
title('Doppler Shift Amplitude Over Time');
legend('Push Amplitude', 'Pull Amplitude', 'Location', 'Best');
hold off;
