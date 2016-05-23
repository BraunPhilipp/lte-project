classdef channel
   properties 
      frq   % Channel frequency
      K = 128; % number of subcarriers
      % Power delay profile
      % compare Table B.2-3 Extended Typical Urban model (ETU)
      % delay[ns] | relative power[dB]
      % pdp := Power Delay Profile
      pdp = [0 -1; 50 -1; 120 -1; 200 0; 230 0; 500 0; 1600 -3; 2300 -5; 5000 -7];
      
      %L = length(pdp(:,1));
      L = 9;
      % delta f kHz
      df = 180000;
   end
   
   methods     
       % Rayleigh-Channel
       function obj = ray_chan()
           % multiply with 10^.-9 to get ns
           pdp(:,1)=pdp(:,1)*10^-9;
           % initialising H(k) 
           H = zeros(K,1);
           
           % takes the power --> second column of pdp
           e = pdp(:,2);
           % converting db to power measurment
           e = db2pow(e);
           % Energy spectral density describes how the energy of a signal
           % or a time series is distributed with frequency.
           energy_spectral_density = sum(e.*conj(e));
           % normalisation of the channel
           e = e/sqrt(energy_spectral_density);
           
           % Fourier transformation to H(k)
           % e(l) := power of the l-th arrival path
           % pdp(l,1) := delay
           % k = subcarrier index
           l = 1:L;
           
           for k = 1:K
              H(k) = sum(e(l).*exp(-1i*2*pi*k*pdp(l,1).*df));
              H(k) = abs(H(k));
           end
           
           % plot the result
           x = 1:128;
           stem(x,H);
           
           % effective time domain response of the channel
           % inverse Fourier transformation
           Ts = 52*10^-6; % Ts=1/(N*df)
           Nfft = K;
           k = 1:K;
           m = 1:0.01:1;
           h = zeros(length(m),1); % result of the Fourier transformation
           
           for i = 1:length(m)
            h(i) = (1/Nfft)*sum(H(k).*exp(1i*2*pi*(k*m(i).*Ts)/Ts));
            h(i) = abs(H(i));
           end
           
           %plot the result
           x = 0:0.01*Ts:Ts;
           stem(x,h);
       end
       
   end
end
