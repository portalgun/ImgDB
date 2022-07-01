function [W Krgb ApertureMax]  = cameraCalibTransform(whichCamera,transformType,whichMeasure,bPLOT)

% function [W Krgb ApertureMax] = cameraCalibTransform(whichCamera,transformType,whichMeasure,bPLOT)
%
%   example call: % TRANSFORM TO LMS SPACE
%                   [W K] = cameraCalibTransform('D7H','LMS',2,1)
%                 
%                 % TRANSFORM TO XYZ SPACE
%                   [W K] = cameraCalibTransform('D7R','XYZ',2,1)
%
% returns matrix transform of specified type for a particular camera.
% follows methodology of CameraCalibrationNotes.doc
% 
% whichCamera:   'D7H' -> GeislerLab (D7)00 (H)andheld
%                'D7R' -> GeislerLab (D7)00 (R)angefinder
%                 ? OTHERS ?
% transformType: 'PHT' or 'Photopic' -> photopic sensitivity curve... also called V(lambda)  
%                'SCT' or 'Scotopic' -> scotopic sensitivity curve
%                'LMS' ->               LMS cone responses
%                'XYZ' ->               CIE 1931 standard of bureaus and measurements... Y = V(lambda) 
%                 The monitor transforms are all mapped through XYZ. Further transforms are needed for monitor pixel values  
%                'M1'  ->               three monitor rig phosphor spectra (GeislerLab optical bench setup) 
%                'M2'  ->               three monitor rig phosphor spectra (GeislerLab optical bench setup) 
%                'MF'  ->               three monitor rig phosphor spectra (GeislerLab optical bench setup) 
% whichMeasure:   calibration was performed (at least) twice for each camera   
%                 1 -> plot measurement one
%                 2 -> plot measurement tow
% bPLOT:          1 -> plot
%                 0 -> not
%%%%%%%%%%%%%%%%
% W:              transform matrix
% Krgb:           scaling factor for each pixel type (max sensitivity == 1)
% ApertureMax:    max aperture for the specified camera (whichCamera)

if ~exist('bPLOT','var')
   bPLOT = 0; 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CAMERA PIXEL SENSITIVITY DATA % Srgb maps radiance, aperture, shutter speed, and iso to camera pixel values   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(whichCamera,'D7H')
    [Srgb SrgbLambdaNm ApertureMax] = D7Hsensitivity;
elseif strcmp(whichCamera,'D7R')
    [Srgb SrgbLambdaNm ApertureMax] = D7Rsensitivity; 
else
    error(['cameraCalibTransform: WARNING! unhandled whichCamera: ' whichCamera]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTANT NORMALIZING THE PEAK CAMERA SENSITIVITY TO 1 % (constant preserves relative sensitivity)  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Krgb = max(Srgb);
% RGB SENSITIVITY SCALED TO PEAK OF 1
Srgb = bsxfun(@rdivide,Srgb,Krgb); 

% LOAD TARGET COLOR MATCHING FUNCTIONS
if     strcmp(transformType,'Photopic') || strcmp(transformType,'PHT') % also called V(lambda)
    % LOAD V(lambda) FUNCTION
    [Stgt StgtLambdaNm] = PHTsensitivity;
elseif strcmp(transformType,'Scotopic') || strcmp(transformType,'SCT') 
    % LOAD SCOTOPIC SENSITIVITY FUNCTION
    [Stgt StgtLambdaNm] = ScotopicSensitivity;
elseif strcmp(transformType,'LMS')
    % LOAD LMS CONE SENSITIVITIES
    [Stgt StgtLambdaNm] = LMSsensitivity;  % LMS cone sensitivities
elseif strcmp(transformType,'VRP')
    % LOAD VRP CONE SENSITIVITIES
    [Stgt StgtLambdaNm] = VRPsensitivity;  % LMS cone sensitivities
elseif strcmp(transformType,'XYZ') || strcmp(transformType,'M1') || strcmp(transformType,'M2') || strcmp(transformType,'MF') 
    [Stgt StgtLambdaNm] = XYZsensitivity;  % XYZ color matching functions
else
    error(['cameraCalibTransform: WARNING! unhandled transformType: ' transformType]);
end

% INTERPOLATE -> TGT SENSITIVITIES AT SAME WAVELENGTHS AS CAMERA RGB 
[Stgt] = interp1(StgtLambdaNm,Stgt,SrgbLambdaNm);
StgtLambdaNm = SrgbLambdaNm;

% TRANSFORMATION MATRIX MAPPING CAMERA RGB TO COLOR SPACE (i.e. 'transformType')  
W      =  Srgb\Stgt;    % OF INTEREST [3x3] or [3x1]

if bPLOT
    % FIND REMAPPED SENSITIVITIES
    Rtgt = Srgb* W;

    % PLOT RGB SENSITIVITY
    figure('position',[177         158        1311         433]);
    subplot(1,3,1); hold on;
    colors = 'rgb';
    for c = 1:size(Srgb,2)
        plot(SrgbLambdaNm,Srgb(:,c),'color',colors(c),'linewidth',2);
    end
    writeText(.15,.9,{['K_R=' num2str(Krgb(1),4)]},'ratio',15)
    writeText(.15,.8,{['K_G=' num2str(Krgb(2),4)]},'ratio',15)
    writeText(.15,.7,{['K_B=' num2str(Krgb(3),4)]},'ratio',15)
    Fig.format('\lambda (nm)',' ','RGB sensitivity',0,0,18,14)
    xlim([350 750])
    set(gca,'xtick',[400:100:700])
    axis square;
    
    if size(Rtgt,2)== 1
        colors = 'k';
    else
        colors = 'rgb';
    end
    subplot(1,3,2); hold on;
    for c = 1:size(Rtgt,2)
        plot(SrgbLambdaNm,Stgt(:,c),'--','color',colors(c),'linewidth',2)
    end
    Fig.format('\lambda (nm)',' ',[transformType ' sensitivity'],0,0,18,14)
    xlim([350 750])
    set(gca,'xtick',[400:100:700])
    axis square;
    
    subplot(1,3,3); hold on
    for c = 1:size(Rtgt,2)
        plot(SrgbLambdaNm,Rtgt(:,c),'.','color',colors(c),'linewidth',2)  
        plot(SrgbLambdaNm,Stgt(:,c),'--','color',colors(c),'linewidth',1.5)
    end
    Fig.format('\lambda (nm)',' ',['RGB -> ' transformType ' sensitivity'],0,0,18,14)
    axis tight
    xlim([350 750])
    set(gca,'xtick',[400:100:700])
    axis square;
    
    % PLOT APERTURE, SHUTTER SPEED, RADIANCE
    disp(['cameraCalibTransform: WARNING! not plotting aperture, shutter speed and radiance']);
%     figure;
%     set(gcf,'position',[52   436   507   520]);
%     hold on;
%     plot(SrgbLambdaNm,Aperture,'k--',SrgbLambdaNm,Shutter,'k:','linewidth',2); %,SrgbLambdaNm,Radiance,'k-.','linewidth',2);
%     xlim([350 750])
%     set(gca,'xtick',[400:100:700])
%     set(gca,'yscale','log');
%     Fig.format('\lambda (nm)','Value')
%     legend({'Aperture','Shutter Speed'},4);
end