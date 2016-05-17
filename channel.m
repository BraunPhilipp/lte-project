classdef channel
   properties 
      frq   % Channel frequency
      
      % Power delay profile
      % compare Table B.2-3 Extended Typical Urban model (ETU)
      % delay | relative power [dB]
      % pdp := Power Delay Profile
      pdp = [0 -1; 50 -1; 120 -1; 200 0; 230 0; 500 0; 1600 -3; 2300 -5; 5000 -7];
   end
   
   methods     
       function prob = rayl(b, sel)
           % norming rayleigh???
           prob = raylpdf(x,0.5);
       end
   end
end