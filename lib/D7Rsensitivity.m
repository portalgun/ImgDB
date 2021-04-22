function [Srgb LambdaNm maxAperture] = D7Rsensitivity(LambdaMinMax,LambdaStep,bPLOT)

% function [Srgb LambdaNm maxAperture] = D7Rsensitivity(LambdaMinMax,LambdaStep,bPLOT)
%
%   example call: D7Rsensitivity([400 700],5,1)
% 
% RGB pixel sensitivities of the GeislerLab D7R camera (Nikon D700 rangefinder)      
% Measuremenets were obtained by projecting a monochrome illuminant onto a 
% target with a flat reflectance spectrum, a photograph of the target was
% taken, and the average pixel response was obtained. The pixel response
% was scaled by the aperture and shutter speeds, and a measure of
% sensitivity was obtained. Camera ISO was set to 200.
% 
% LambdaMinMax: min and max values for which to return sensitivities
%                   default: [400 700]
% LambdaStep:   spacing between successive sensitivity samples
%                   default: 5
% 
% Note: the values stored in this file were computed by calling 
%   >> [Srgb LambdaNm,~,~,~,~,maxAperture] = cameraCalibLoadData('D7H',2,0);
% 
% %%%%%%%%%%
% Srgb:        Raw wavelength sensitivities for the red, green, and blue pixels                       
%                When multiplied by the radiance at each wavelength the Srgb                
%                functions give 16bit pixel responses.  For some applications,                        
%                is may be desirable to each channel to a max of one.
% LambdaNm:    Peak wavelength of the monochrometer illuminant at which 
%                a measure of sensitivity was obtained
% maxAperture: maximum aperture that accompanying camera lens can acheive
%
%                   *** see cameraCalibLoadData.m ***


if ~exist('LambdaMinMax','var') || isempty(LambdaMinMax)
   LambdaMinMax = [400 700]; 
end
if ~exist('LambdaStep','var') || isempty(LambdaStep)
   LambdaStep = 5; 
end
if ~exist('bPLOT','var') || isempty(bPLOT), bPLOT = 0; end

% MAXIMUM APERTURE OF D7H CAMERA LENS
maxAperture = 2.8;

% SENSITIVITY OF RANGEFINDER NIKON D700 ('D7R')
rawData(:,2:4) = 1.0e+07 * ... % WILL BE CONVERTED TO Srgb
    [0.0054    0.0033    0.0056
    0.0053    0.0019    0.0062
    0.0057    0.0028    0.0078
    0.0058    0.0014    0.0153
    0.0218         0    0.1165
    0.0557         0    0.4088
    0.0781         0    0.7859
    0.0835         0    1.2975
    0.0201         0    1.1512
    0.0005         0    1.3411
    0.0001         0    1.4783
    0.0144    0.0000    1.4300
    0.0044         0    1.3315
    0.0018    0.0000    1.2556
    0.0006    0.0004    1.3340
    0.0000    0.0210    1.6196
    0.0000    0.1055    1.2676
    0.0000    0.1585    1.1043
    0.0000    0.2232    1.0229
    0.0001    0.2858    0.8607
         0    0.4225    0.8292
         0    0.5214    0.5960
         0    0.7019    0.4399
         0    0.9299    0.2507
         0    1.1124    0.1146
         0    1.0778    0.0001
         0    1.3070         0
         0    1.2348         0
         0    1.4507         0
         0    1.2985         0
         0    1.2029         0
         0    1.1532         0
         0    1.1552         0
         0    1.1862         0
         0    0.9979         0
         0    1.0067         0
    0.4175    0.8721         0
    1.0202    0.6417    0.0000
    1.9570    0.5100    0.0003
    2.4861    0.3877    0.0066
    2.6405    0.3000    0.0200
    2.6869    0.2263    0.0375
    2.5207    0.1521    0.0542
    2.3547    0.0888    0.0626
    2.2564    0.0656    0.0644
    1.9864    0.0395    0.0619
    1.8128    0.0294    0.0579
    1.6130    0.0230    0.0536
    1.4966    0.0184    0.0470
    1.3039    0.0144    0.0417
    1.1323    0.0119    0.0378
    1.0030    0.0104    0.0339
    0.7997    0.0076    0.0266
    0.6757    0.0079    0.0234
    0.5905    0.0063    0.0191
    0.4048    0.0058    0.0139
    0.2524    0.0043    0.0079
    0.1447    0.0035    0.0054
    0.0849    0.0025    0.0021
    0.0485    0.0018    0.0012
    0.0255    0.0013    0.0007
    0.0174    0.0010    0.0005
    0.0101    0.0008    0.0003
    0.0063    0.0006    0.0003];

% PEAK OF MONOCHROMETER ILLUMINATION DISTRIBUTION
rawData(:,1) = [392
   398
   404
   410
   414
   420
   424
   428
   434
   438
   442
   448
   452
   458
   464
   468
   472
   478
   482
   488
   492
   496
   502
   508
   512
   516
   522
   526
   532
   536
   541
   546
   550
   556
   560
   564
   570
   574
   580
   586
   590
   596
   600
   606
   610
   616
   620
   626
   632
   636
   642
   646
   652
   656
   661
   666
   672
   678
   680
   686
   692
   696
   702
   706];

LambdaNm    = [LambdaMinMax(1):LambdaStep:LambdaMinMax(2)]';
Srgb = interp1(rawData(:,1),rawData(:,2:4),LambdaNm,'spline');

% CHECK FOR NEGATIVE INDICES
if ~isempty(find(Srgb < 0, 1))
    Srgb(Srgb < 0) = 0;
end

% WARN IF EXTRAPOLATING BEYOND LIMITS OF DATA
if min(LambdaMinMax) < min(rawData(:,1)) || max(LambdaMinMax) > max(rawData(:,1))
   disp(['D7Rsensitivity: WARNING! extrapolating beyond measured data. minmax(rawdata) = [' num2str(min(rawData(:,1))) ' ' num2str(max(rawData(:,1))) '] vs LambdaMinMax [' num2str(LambdaMinMax(1)) ' ' num2str(LambdaMinMax(2)) ']']); 
end

if bPLOT
    figure;
    plot(LambdaNm,Srgb(:,1),'r',LambdaNm,Srgb(:,2),'g',LambdaNm,Srgb(:,3),'b','linewidth',2);
    formatFigure('Wavelength (nm)','Sensitivity');
    axis square;
end