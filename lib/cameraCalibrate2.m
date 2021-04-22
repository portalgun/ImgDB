function [RGBcalib W] = cameraCalibrate2(RGB,Aperture,Shutter,whichCamera,transformType,bitsIn,bitsOut,whichMeasure,bComputeTransform,bPLOT)

% function [RGBcalib W] = cameraCalibrate2(RGB,Aperture,Shutter,whichCamera,transformType,bitsIn,bitsOut,whichMeasure,bComputeTransform,bPLOT)
%
%   example call: [Icalib cameraCalibW] = cameraCalibrate2(I,Aperture,Shutter,'D7H','LMS',16,16,2,0,0); % transform to 16-bit LMS cone  responses
%                 [Icalib cameraCalibW] = cameraCalibrate2(I,Aperture,Shutter,'D7H','LMS',16,8, 2,0,0); % transform to 16-bit LMS cone  responses  
%                 [Icalib cameraCalibW] = cameraCalibrate2(I,      [],     [],'D7H','XYZ',16,8, 2,0,0); % transform to 16-bit XYZ color space
%                 [Icalib cameraCalibW] = cameraCalibrate2(I,      [],     [],'D7H', 'M1',16,8, 2,0,0); % transform to  8-bit phosphor spectra
%                                                                                                     outputs for three monitor rig in GeislerLab
% convert RGB image to XYZ image, LMS image, Photopic Image, etc.
%
%               algorithm operates by first transforming to XYZ
%              and then transforming to other spaces of interest
%
% RGB:               image to transform nxnx1 if B&W image
%                                       nxnx3 if RGB image
% Aperture:          aperture of camera (f-stop number)
% Shutter:           shutter speed of camera
% whichCamera:      'D7H': GeislerLab D700 handheld      camera (normalized to max of 1, where K stores relative sensitivity)
%                   'D7R': GeislerLab D700 rangefinder   camera (normalized to max of 1, where K stores relative sensitivity)
%                   'NaN': do nothing -> return original image  (use if original image is already in appropriate color space)
% transformType:    'LMS'       (normalized to max of 1)
%                   'PHT' or 'Photopic'  (normalized to max of 1)
%                   'SCT' or 'Scotopic'  (normalized to max of 1)
%                   'XYZ'
%                   'M1' Monitor 1 from 3M rig in GeiserLab optical bench setup
%                   'M2' Monitor 2                 "
%                   'MF' Monitor F                 "
% bitsIn:            number of bitsIn  for input image
% bitsOut:           number of bitsOut with which to return image
% whichMeasure:      two measurements were made in each calibration procedure
%                    1 -> load first measurement  (longer exposure)
%                    2 -> load second measurement (shorter exposure)
%                    NOTE: 2 appears to give slightly better results...
% bComputeTransform: 1 -> recompute transform matrix from raw calibration data
%                    0 -> load pre-compute transform matrix
% bPLOT:             plot or not
%%%%%%%%%%%%%%%%
% RGBcalib:          calibrated image
% W:                 transform matrix

% ABORT IF whichCamera IS NaN
if isnan(whichCamera)
    RGBcalib = RGB;
    W = NaN;
    return;
end

if isempty(Aperture)
    Aperture = 2.8;
end
if isempty(Shutter)
    Shutter = 1;
end
if ~exist('bitsIn','var') || isempty(bitsIn)
   bitsIn = 16;
end
if bitsIn > 16 || bitsIn < 1
    error(['cameraCalibrate2: WARNING! bitsIn outside handled range of [1 16]. bitsOut = ' num2str(bitsOut)]);
end
if bitsOut > 16 || bitsOut < 1
    error(['cameraCalibrate2: WARNING! bitsOut outside handled range of [1 16]. bitsOut = ' num2str(bitsOut)]);
end
if rem(bitsOut,1) ~= 0
    error(['cameraCalibrate2: WARNING! bitsOut must be integer valued. bitsOut = ' num2str(bitsOut)]);
end
if ~exist('bPLOT','var') || isempty(bPLOT)
    bPLOT = 0;
end

if bComputeTransform
    % COMPUTES THE TRANSFORMS FRESH EACH TIME (SLOW)
    [W K ApertureMax] = cameraCalibTransform(whichCamera,transformType,whichMeasure,0);
    
else
    % LOADS IN STORED TRANSFORM MATRIX AND NORMALIZATION FACTORS (FAST)
    [W K ApertureMax] = preComputedTransform(whichCamera,transformType,whichMeasure);
end

% RATIO OF MEAN LUMINANCE :: 2^bitsIn-1
if strcmp(whichCamera,'D7H')
   meanLumInK = mean(mean(D7H2PHT(RGB)))./(2^bitsIn-1);
elseif strcmp(whichCamera,'D7R')
   meanLumInK = mean(mean(D7R2PHT(RGB)))./(2^bitsIn-1); 
end
if meanLumInK > 1
    error(['cameraCalibrate2: WARNING! mean(RGB) cannot be greater than 2^bitsIn']);
end
    
% APERTURE AND SHUTTER SPEED DATA
A = (ApertureMax.^2)./(Aperture.^2);
T = Shutter;

% RESIZE THE INPUT TO SIMPLY LINEAR ALGEBRA
RGBsize = size(RGB);
RGBvec  = reshape(RGB,[numel(RGB(:,:,1)) size(RGB,3)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CAMERA PIXEL VALUES -> COLOR SPACE VALUES %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(transformType,'XYZ') || strcmp(transformType,'M1') || strcmp(transformType,'M2') || strcmp(transformType,'MF')
    RGBcalibVec = (683./( (A)*T )) .* bsxfun(@rdivide,RGBvec,K) * W;
    meanLumCalib = mean(mean(RGBcalibVec(:,2)));   % mean of calibrated image
elseif     strcmp(transformType,'LMS')
    RGBcalibVec = (1  ./( (A)*T )) .* bsxfun(@rdivide,RGBvec,K) * W;
    meanLumCalib = mean(mean(LMS2PHT(RGBcalibVec))); % mean of calibrated image
elseif strcmp(transformType,'PHT') || strcmp(transformType,'Photopic')
    RGBcalibVec = (683./( (A)*T )) .*  bsxfun(@rdivide,RGBvec,K) * W; % standard formula for luminance
    meanLumCalib = mean(mean(RGBcalibVec));          % mean of calibrated image
elseif strcmp(transformType,'SCT') || strcmp(transformType,'Scotopic')
    error(['cameraCalibTransform: unhandled transformType ' transformType]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COLOR SPACE VALUES TO MONITOR PIXEL VALUES %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(transformType,'M1') || strcmp(transformType,'M2') || strcmp(transformType,'MF')
    if strcmp(transformType,'M1') brightnessLevel = 0;   %   0% brightness
    else                          brightnessLevel = 100; % 100% brightness
    end
    disp(['cameraCalibrate2: WARNING! ' transformType ' brightnessLevel hard-coded to ' num2str(brightnessLevel)]);
    % FIND XYZ COORDINATES OF THE MONITOR'S R,G,B PRIMARIES
    [~,~,~,~,XYZprimaries] = threeMonitorSpectra(transformType,brightnessLevel);  % (phosphor spectra of three monitor setup: GeislerLab Optical Bench)
    
    % FIND COEFFICIENTS ON PRIMARIES TO PRESENT DESIRED COLORS
    XYZcoeffs = RGBcalibVec*pinv(XYZprimaries);
    
    % FIND PIXELS WITH NEGATIVE COEFFICIENTS
    indNeg = find(XYZcoeffs < 0);
    
    % ZERO COEFFICIENTS (moves pixels to gamut along line connecting point to the primary with the negative coefficient)
    XYZcoeffs(indNeg)=0;
    
    RGBcalibVec = XYZcoeffs*XYZprimaries;
    
end

% RESHAPE BACK TO ORIGINAL IMAGE SIZE
RGBcalib = reshape(RGBcalibVec,[RGBsize(1:2) size(W,2)]);

% SCALE FACTOR TO EQUATE LUMINANCES
meanK            = (2^bitsOut-1).*meanLumInK./meanLumCalib;

% SCALE FACTOR TO EQUATE LUMINANCES
RGBcalib     = floor(meanK.*RGBcalib);

% SET NEG VALUES TO eps AND POS VALUES TO 2^bitsOut-1
if ~exist('indNeg','var')
    indNegRGB = find(RGBcalib == 0);
    indPosRGB = find(RGBcalib == 2^bitsIn-1);
    
    indNeg = find(RGBcalib < 0);
    RGBcalib(indNeg) = eps;
    indPos = find(RGBcalib > (2^bitsOut-1));
    RGBcalib(indPos) = 2^bitsOut - 1;
end

if bPLOT
    % GET PIXEL LOCATIONS OF INPUT  IMAGE OUTSIDE OF BOUNDS
    [indNegRGBR indNegRGBG indNegRGBB] = ind2sub(size(RGB),indNegRGB);
    [indPosRGBR indPosRGBG indPosRGBG] = ind2sub(size(RGB),indPosRGB);
    
    % GET PIXEL LOCATIONS OF OUTPUT IMAGE OUTSIDE OF BOUNDS
    [indNegR indNegG indNegB] = ind2sub(size(RGBcalib),indNeg);
    [indPosR indPosG indPosB] = ind2sub(size(RGBcalib),indPos);
    
    figure('position',[61         590        1002         507]);
    subplot(1,2,1);
    % image(sqrt(RGB./max(RGB(:))));
    image(sqrt(RGB./(2^bitsIn-1)));
    formatFigure([num2str(length(indNegRGBR)) ' neg & ' num2str(length(indPosRGBR)) ' pos pixels'], ' ','Original',0,0,22,18);
    axis square
    hold on; 
    plot(indNegRGBG,indNegRGBR,'b.');
    plot(indPosRGBG,indPosRGBR,'c.');
    if size(RGB,3) == 1
        colormap gray;
    end
    
    subplot(1,2,2);
    % imagesc(sqrt(RGBcalib./max(RGBcalib(:))));
    image(sqrt(RGBcalib./(2^bitsOut-1)));
    formatFigure([num2str(length(indNegR)) ' neg & ' num2str(length(indPosR)) ' pos pixels'], ' ',transformType,0,0,22,18);
    axis square
    if size(RGBcalib,3) == 1
        colormap gray;
    end
    hold on; 
    plot(indNegG(:),indNegR(:),'b.');
    plot(indPosG(:),indPosR(:),'c.');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PLOT PIXELS IN CIE SPACE %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strcmp(transformType,'XYZ') || strcmp(transformType,'M1') || strcmp(transformType,'M2') || strcmp(transformType,'MF') 
        plotCIE; 
        hold on; 
        axis([0 .85 0 .85])
        % PLOT PRIMARIES 
        if exist('XYZprimaries','var')
            % xy coordinates for plotting in CIE space
            xy = [bsxfun(@rdivide,XYZprimaries(:,1),sum(XYZprimaries,2)),...
                  bsxfun(@rdivide,XYZprimaries(:,2),sum(XYZprimaries,2))];
            plotPolygon(xy(:,1),xy(:,2),'w-',2);
        end
        % PLOT PIXELS
        plot(RGBcalibVec(1:8:end,1)./sum(RGBcalibVec(1:8:end,:),2), ...
             RGBcalibVec(1:8:end,2)./sum(RGBcalibVec(1:8:end,:),2),'o','markersize',4,'markerfacecolor','y','markeredgecolor','k');
    end
    
end

function [W K ApertureMax] = preComputedTransform(whichCamera,transformType,whichMeasure)

% PRELOADED TRANSFORMS
if strcmp(whichCamera,'D7H')
    ApertureMax = 2.8;
    if strcmp(transformType,'LMS')
        if whichMeasure == 1,
            W = [0.7287    0.1884   -0.0156
                 0.9234    1.0413   -0.0276
                 0.0147    0.0815    0.9389];
            K = [3.5293    1.6853    2.2469].*1.0e+07;
        elseif whichMeasure == 2,
            W = [0.7312    0.1891   -0.0181
                 0.9183    1.0358   -0.0300
                 0.0094    0.0700    0.8372];
            K = [3.5184    1.6677    1.9706].*1.0e+07;
        else
            error(['cameraCalibrate2: WARNING! unhandled whichMeasure ' num2str(whichMeasure) ' for ' transformType ' and ' whichCamera]);
        end
    elseif strcmp(transformType,'Photopic') || strcmp(transformType,'PHT')
        if whichMeasure == 1,
            W = [0.5144
                 0.9929
                 0.0098];
            K = [ 3.5293    1.6853    2.2469].*1.0e+07;
        elseif whichMeasure == 2,
            W = [ 0.5163
                 0.9874
                 0.0050];
            K = [3.5184    1.6677    1.9706].*1.0e+07;
        else
            error(['cameraCalibrate2: WARNING! unhandled whichMeasure ' num2str(whichMeasure) ' for ' transformType ' and ' whichCamera]);
        end
    elseif strcmp(transformType,'Scotopic') || strcmp(transformType,'SCT')
        if whichMeasure == 1,
            W = [-0.1201
                 0.8503
                 0.6369];
            K = [3.5293
                 1.6853
                 2.2469].*1.0e+07;
        elseif whichMeasure == 2,
            W = [-0.1131
                 0.8686
                 0.6622];
            K = [2.6869    1.4507    1.6196].*1.0e+07;
        else
            error(['cameraCalibrate2: WARNING! unhandled whichMeasure ' num2str(whichMeasure) ' for ' transformType ' and ' whichCamera]);
        end
    elseif strcmp(transformType,'XYZ') || strcmp(transformType,'M1') || strcmp(transformType,'M2') || strcmp(transformType,'MF')
        % IF TRANSFORM IS A MONITOR, PASS THROUGH XYZ SPACE
        % THEN DETERMINE MONITOR PIXEL VALUES FOR DISPLAY TO ACHIEVE XYZ
        if whichMeasure == 1,
            W = [1.0568    0.5144   -0.0300
                 0.3019    0.9929   -0.0140
                 0.2533    0.0098    1.6040];
            K = [3.5293    1.6853    2.2469].*1.0e+07;
        elseif whichMeasure == 2,
            W = [1.0595    0.5163   -0.0344
                 0.2989    0.9874   -0.0183
                 0.2228    0.0050    1.4315];
            K = [3.5184    1.6677    1.9706].*1.0e+07;
        else
            error(['cameraCalibrate2: WARNING! unhandled whichMeasure ' num2str(whichMeasure) ' for ' transformType ' and ' whichCamera]);
        end
    else
        error(['cameraCalibrate2: WARNING! unhandled transformType ' transformType ' for ' whichCamera]);
    end

elseif strcmp(whichCamera,'D7R')
    %  END  DEBUGGING MESSAGE
    K = 2.8;
    if strcmp(transformType,'LMS')
        if whichMeasure == 1,
            W = [0.7749    0.2135   -0.0152
                 0.8920    1.0056   -0.0312
                 0.0184    0.0831    0.8648];
            K = [2.7360    1.3113    1.4835].*1.0e+07;
        elseif whichMeasure == 2,
            W = [0.7609    0.2109   -0.0229
                 0.9827    1.1016   -0.0293
                 0.0232    0.0939    0.9270];
            K = [2.6869    1.4507    1.6196].*1.0e+07;
        else
            error(['cameraCalibrate2: WARNING! unhandled whichMeasure ' num2str(whichMeasure) ' for ' transformType ' and ' whichCamera]);
        end
    elseif strcmp(transformType,'Photopic') || strcmp(transformType,'PHT')
        if whichMeasure == 1,
            W = [0.5526
                 0.9598
                 0.0140];
            K = [2.7360    1.3113    1.4835].*1.0e+07;
        elseif whichMeasure == 2,
            W = [0.5433
                 1.0553
                 0.0189];
            K = [2.6869    1.4507    1.6196].*1.0e+07;
        else
            error(['cameraCalibrate2: WARNING! unhandled whichMeasure ' num2str(whichMeasure) ' for ' transformType ' and ' whichCamera]);
        end
    elseif strcmp(transformType,'Scotopic') || strcmp(transformType,'SCT')
        if whichMeasure == 1,
            W = [-0.1160
                 0.8047
                 0.6155];
            K = [2.7360    1.3113    1.4835].*1.0e+07;
        elseif whichMeasure == 2,
            W = [-0.1131
                0.8686
                0.6622];
            K = [2.6869
                1.4507
                1.6196].*1.0e+07;
        else
            error(['cameraCalibrate2: WARNING! unhandled whichMeasure ' num2str(whichMeasure) ' for ' transformType ' and ' whichCamera]);
        end
    elseif strcmp(transformType,'XYZ') || strcmp(transformType,'M1') || strcmp(transformType,'M2') || strcmp(transformType,'MF')
        if whichMeasure == 1,
            W = [1.1078    0.5526   -0.0294
                 0.2908    0.9598   -0.0227
                 0.2311    0.0140    1.4781];
            K = [2.7360    1.3113    1.4835].*1.0e+07;
        elseif whichMeasure == 2,
            W = [1.0832    0.5433   -0.0422
                 0.3308    1.0553   -0.0176
                 0.2477    0.0189    1.5851];
            K = [2.6869    1.4507    1.6196].*1.0e+07;
        else
            error(['cameraCalibrate2: WARNING! unhandled whichMeasure ' num2str(whichMeasure) ' for ' transformType ' and ' whichCamera]);
        end
    else
        error(['cameraCalibrate2: WARNING! unhandled transformType ' transformType ' for ' whichCamera]);
    end
end

