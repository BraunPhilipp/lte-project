classdef channel
   properties
       % some sort of list % 
      frq
   end
   
   methods
       function prob = rayl(b, sel)
           % norming rayleigh???
           prob = raylpdf(x,0.5);
       end
   end
end