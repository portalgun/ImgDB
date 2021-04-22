function [Srgb LambdaNm maxAperture] = D7Hsensitivity(LambdaMinMax,LambdaStep,bPLOT)

% function [Srgb LambdaNm maxAperture] = D7Hsensitivity(LambdaMinMax,LambdaStep,bPLOT)
%
% RGB pixel sensitivities of the GeislerLab D7H camera (Nikon D700 handheld)
% Measuremenets were obtained by projecting a monochrome illuminant onto a 
% target with a flat reflectance spectrum, a photograph of the target was
% taken, and the average pixel response was obtained. The pixel response
% was scaled by the aperture and shutter speeds, and a measure of
% sensitivity was obtained. Camera ISO was set to 200
%
% LambdaMinMax: min and max values for which to return sensitivities
%                   default: [400 700]
% LambdaStep:   spacing between successive sensitivity samples
%                   default: 5
% bPLOT:        1 -> plot
%               0 -> not
%
% NOTE: the values stored in this file were computed by calling 
%   >> [Srgb lambdaNm,~,~,~,~,maxAperture] = cameraCalibLoadData('D7R',2,0);
% 
% %%%%%%%%%%
% Srgb:        Raw wavelength sensitivities for the red, green, and blue pixels
%                When multiplied by the radiance at each wavelength the Srgb 
%                functions give 16bit pixel responses.  For some applications, 
%                is may be desirable to each channel to a max of one.
% lambdaNm:    Peak wavelength of the monochrometer illuminant at which 
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
if ~exist('bPLOT','var') || isempty(bPLOT)
   bPLOT = 0; 
end

% MAXIMUM APERTURE OF D7H CAMERA LENS
maxAperture = 2.8;

% SENSITIVITY OF HANDHELD NIKON D700 ('D7H')
rawData(:,2:4) = 1.0e+07 * ...
    [0.0112    0.0021    0.0118
    0.0121    0.0015    0.0155
    0.0120    0.0006    0.0213
    0.0214         0    0.0734
    0.0671    0.0000    0.3350
    0.1281         0    0.9391
    0.1276         0    1.4272
    0.0715         0    1.5398
    0.0337         0    1.6198
    0.0095         0    1.7733
    0.0062         0    1.9646
    0.0053         0    1.9453
    0.0035         0    1.9706
    0.0014    0.0000    1.9445
    0.0003    0.0008    1.9075
    0.0002    0.0332    1.8541
    0.0001    0.1655    1.7034
    0.0001    0.2547    1.5308
    0.0000    0.3411    1.4058
    0.0000    0.4267    1.1567
    0.0000    0.5498    1.0599
    0.0000    0.7206    0.8156
    0.0000    0.9780    0.5651
         0    1.1413    0.2912
         0    1.3313    0.1302
    0.0000    1.4723    0.0065
    0.0000    1.5863    0.0000
         0    1.6677         0
         0    1.5874         0
         0    1.5439         0
         0    1.5383         0
         0    1.4744         0
         0    1.3669         0
         0    1.2574         0
         0    1.1481         0
    0.0004    1.0340         0
    0.4254    0.9662         0
    1.4725    0.8244         0
    2.4840    0.6781    0.0000
    3.2425    0.5281    0.0019
    3.5184    0.4108    0.0192
    3.5139    0.2989    0.0431
    3.3546    0.1905    0.0621
    3.2372    0.1299    0.0720
    3.0021    0.0843    0.0752
    2.7316    0.0553    0.0736
    2.5116    0.0421    0.0702
    2.2063    0.0309    0.0639
    2.0217    0.0257    0.0599
    1.8261    0.0212    0.0536
    1.5961    0.0170    0.0478
    1.2737    0.0127    0.0379
    1.1996    0.0115    0.0348
    1.0101    0.0104    0.0296
    0.8456    0.0097    0.0252
    0.6096    0.0084    0.0188
    0.3703    0.0065    0.0104
    0.2002    0.0044    0.0060
    0.1204    0.0034    0.0034
    0.0633    0.0023    0.0016
    0.0347    0.0016    0.0008
    0.0210    0.0013    0.0005
    0.0142    0.0010    0.0004
    0.0087    0.0007    0.0003];

% PEAK OF MONOCHROMETER ILLUMINATION DISTRIBUTION
rawData(:,1) = [394
   399
   404
   408
   414
   420
   424
   430
   434
   438
   444
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
   530
   536
   540
   546
   550
   556
   560
   566
   570
   576
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
   630
   636
   642
   646
   650
   656
   660
   666
   672
   676
   682
   686
   692
   698
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
   disp(['D7Hsensitivity: WARNING! extrapolating beyond measured data. minmax(rawdata) = [' num2str(min(rawData(:,1))) ' ' num2str(max(rawData(:,1))) '] vs LambdaMinMax [' num2str(LambdaMinMax(1)) ' ' num2str(LambdaMinMax(2)) ']']); 
end

if bPLOT
    figure; 
    plot(LambdaNm,Srgb(:,1)./max(Srgb(:,1)),'r',LambdaNm,Srgb(:,2)./max(Srgb(:,2)),'g',LambdaNm,Srgb(:,3)./max(Srgb(:,3)),'b','linewidth',2);
    formatFigure('Wavelength (nm)','Sensitivity','D7H');
    axis square
    ylim([0 1.1])
end