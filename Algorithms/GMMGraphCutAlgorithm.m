classdef GMMGraphCutAlgorithm %< CoreBaseClass
   properties 
       FgGMM; 
       BgGMM;
       
       lambda;
       sigma;
       k;
   end
   methods
       function obj = GMMGraphCutAlgorithm()
           obj.FgGMM = gmdistribution();
           obj.BgGMM = gmdistribution();
       end
       function out = Segment(obj, image, seeds)
           D = length(size(image));
           if(D==2)
               [H,W]=size(image);
               C=1;
           else
               [H, W, C]=size(image);
           end
           Ireshape = double(reshape(image,[H*W,C]));
           
           obj.lambda = 10.0;
           obj.sigma = 40.0;
           obj.k = 3;

           Mreshape = reshape(seeds,[H*W,1]);
           FData = Ireshape(Mreshape==127,:);
           BData = Ireshape(Mreshape==255,:);
           obj.FgGMM = fitgmdist(FData,obj.k, 'RegularizationValue',0.1);
           obj.BgGMM = fitgmdist(BData,obj.k, 'RegularizationValue',0.1);
           
           Fprob = obj.FgGMM.pdf(Ireshape);
           Bprob = obj.BgGMM.pdf(Ireshape);

           [flow, out]=interactive_graphcut(double(image),seeds,Fprob, Bprob,obj.lambda,obj.sigma);
           out=1-out;
       end
   end
end