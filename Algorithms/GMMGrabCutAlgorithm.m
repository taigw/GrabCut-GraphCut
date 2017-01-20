classdef GMMGrabCutAlgorithm %< CoreBaseClass
   properties 
       FgGMM; 
       BgGMM;
       k;      % number of components
       iter;   % number of iteration
       lambda; % graph cut parameter, weight of pairwise potential (1.0-20.0)
       sigma;  % grapu cut parameter, control itensity difference (5.0-20.0)
   end
   methods
       function obj = GMMGrabCutAlgorithm()
           obj.FgGMM = gmdistribution();
           obj.BgGMM = gmdistribution();
       end
       
       % image: input color image with rgb channels
       % mask: maks of foreground or background 0--background,1--foreground
       % seeds: user-provided scribbles 127--foreground, 255-background
       function out = Segment(obj, image, mask, seeds)
           D = length(size(image));
           if(D==2)
               [H,W]=size(image);
               C=1;
           else
               [H, W, C]=size(image);
           end
           Ireshape = double(reshape(image,[H*W,C]));
           seeds(mask==0)=255;
   
           obj.lambda = 10.0;
           obj.sigma = 40.0;
           obj.k = 5;
           obj.iter = 5;
            
           out = mask;
           for i = 1: obj.iter
               out = update_step(obj, image, Ireshape, out, seeds);
           end
       end
       
       function out = update_step(obj, image, Ireshape, init_seg, seeds)
           [H, W] = size(init_seg);
           Mreshape = reshape(init_seg,[H*W,1]);
           FData = Ireshape(Mreshape==1,:);
           BData = Ireshape(Mreshape==0,:);
           obj.FgGMM = fitgmdist(FData,obj.k);
           obj.BgGMM = fitgmdist(BData,obj.k);
           
           Fprob = obj.FgGMM.pdf(Ireshape);
           Bprob = obj.BgGMM.pdf(Ireshape);

           [flow, out]=interactive_graphcut(double(image),seeds,Fprob, Bprob,obj.lambda,obj.sigma);
           out=1-out;
       end
   end
end