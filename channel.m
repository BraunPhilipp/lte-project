classdef channel < handle
    
   properties 
      frq  = 10000000 % Channel frequency
      K = 128; % number of subcarriers
      % Power delay profile
      % compare Table B.2-3 Extended Typical Urban model (ETU)
      % delay[ns] | relative power[dB]
      % pdp := Power Delay Profile
      pdp = [0 -1; 50 -1; 120 -1; 200 0; 230 0; 500 0; 1600 -3; 2300 -5; 5000 -7];
      
      %L = length of received signal
      %L = 0
      % delta f kHz
      df = 180000;
      cqi =2; % [0-15]Channel Quality Indicator
      pmi =0; %Precoding Matrix Indicator
      ri  =0; %Rank Indicator
   end
   
   methods     
       
       function y = sinc_interp(~,x,u)
           y = zeros(length(u),1);
           m = 0:length(x)-1;
           for i=1:length(u)
               y(i) = sum(x.*sinc(m- u(i)));
           end
       end
       
       % Rayleigh-Channel
       function ratioOfAtten = ray_chan(self)
           % initialising H(k) 
           H = zeros(self.K,1);
           
           % e is the power received --> second column of pdp
           % initialize e:
           e = zeros(501,2);
           
           % e saves time in first column and power of signal
           % in the second column:
           e(1:1:501)=(0:10:5000)*10^(-9);
           e(1,2)=db2pow(-1);
           e(6,2)=db2pow(-1);
           e(13,2)=db2pow(-1);
           e(21,2)=db2pow(0);
           e(24,2)=db2pow(0);
           e(51,2)=db2pow(0);
           e(161,2)=db2pow(-3);
           e(231,2)=db2pow(-5);
           e(501,2)=db2pow(-7);

           % Energy spectral density describes how the energy of a signal
           % or a time series is distributed with frequency.
           energy_spectral_density = sum(e(:,2).*conj(e(:,2)));
           % normalisation of the channel
           e(:,2) = e(:,2)/sqrt(energy_spectral_density);
           
           % plot the received signal
           figure
           subplot(2,2,1);
           stem(e(:,1),e(:,2));
           title('e[t]');
           
           % Fourier transformation to H(k)
           % e(l) := power of the l-th arrival path
           % pdp(l,1) := delay
           % k = subcarrier index
           % length of incoming signal = 501
           l = 1:501;
           
           for k = 1:self.K
              H(k) = sum(e(l,2).*exp(-1i*2*pi*k*e(l,1)*self.df));
              H(k) = abs(H(k));
           end
           
           %sinc-Interpolation:
           t= 1:128;
           ts = linspace(1,128,128);
           [Ts,T] = ndgrid(ts,t);
           y = sinc(Ts-T)*H;
           %Hi = self.sinc_interp(transpose(H),x);
           %t = 3;
           %(sinc(t-x)*H(x))
           %Hi(3)
           
           ratioOfAtten = (sinc(self.frq/(128*self.df)*ones(1,self.K)-(1:self.K))*H);
           
           % plot the result
           subplot(2,2,2)
           x= (1:self.K);
           stem(x,H);
           title('|H[f]|');
           
           subplot(2,2,3)
           plot(t,y)
           title('|H(f)|');
           
           % effective time domain response of the channel
           % inverse Fourier transformation
           Ts = 52*10^-6; % Ts=1/(N*df)
           Nfft = self.K;
           k = 1:self.K;
           m = 0:0.01:1;
           h = zeros(length(m),1); % result of the Fourier transformation
           
           for i = 1:length(m)
               % from row vector to column vector and back
            h(i,1) = (1/Nfft)*sum(transpose(H(transpose(k))).*exp(1i*2*pi*k*(m(i)*Ts)/Ts));
            h(i,1) = abs(h(i,1));
           end
           
           %plot the result
           x = 0:0.01*Ts:Ts;
           subplot(2,2,4)
           stem(x,h);
           title('|h[t]|');
       end
       
       function feed = channel_feedback(self)
            % Random feedback indicators for each channel
            self.cqi = randi(15);   %Channel Quality Indicator
            self.pmi = randi(7);    %Precoding Matrix Indicator
            self.ri = randi(7);     %Rank Indicator
            feed.cqi = self.cqi;
            feed.pmi = self.pmi;
            feed.ri = self.ri;
       end
        
   end
end
