function [Srgb LambdaPeakNm Radiance RGB Aperture Shutter ApertureMax] = cameraCalibLoadData(whichCamera,whichMeasure,bPLOT)

% function [Srgb LambdaPeakNm Radiance RGB Exposure ApertureMax] = cameraCalibLoadData(whichCamera,whichMeasure,bPLOT)
% 
%   example call:  cameraCalibLoadData('D7H',1)
%
% loads spectroradiometer and corresponding rgb image for each
% monochrometer setting in the visible spectrum.
%
% whichCamera:   cameras for which we have camera calibration data
%               'D7H'- GeislerLab handheld    d700 camera
%               'D7R'- GeislerLab rangefinder d700 camera
% whichMeausure: calibration data was measured (at least) twice.
%                which measurement do you want to load
%                1 -> loads first measurements
%                2 -> loads second measurements
% bPLOT:         1 -> plot
%                0 -> not
%%%%%%%%%%%%%%%%%%%%%%
% Srgb:          spectral sensitivities of the different pixels
% 

if ~exist('bPLOT','var') || isempty(bPLOT)
    bPLOT = 0;
end

if strcmp(whichCamera,'D7H') % GeislerLab d700 handheld camera
    cameraDir = 'D7HCAL';    
    fNameFragment = 'D7H';
elseif strcmp(whichCamera,'D7R')    % GeislerLab d700 rangefinder camera
    cameraDir = 'D7RCAL';
    fNameFragment = 'D7R';
end

slash = slashMACorPC;
if ismac
%     calibDir = [ slash 'Users' slash 'lab' slash 'Desktop' slash 'JohannesBackup' slash 'MyDocuments' slash 'Data' slash 'Project_CameraCalibration' slash cameraDir slash];
    calibDir = [ slash 'Users' slash 'johannesburge' slash 'MyDocuments' slash 'Data' slash 'Project_CameraCalibration' slash cameraDir slash];
%     calibDir = [ slash 'Volumes' slash 'WSGLAB2' slash 'CameraCalibration' slash 'D7HCAL' slash ];
    disp([' '])
    disp(['cameraCalibLoadData: loading data from ' calibDir]);
    disp([' '])
else
    error(['cameraCalibLoadData: unhandled directory. Enter directory where calib files live. ' ]);
end

% LOAD MASTER FILE (Wavelength, CameraImgNum, and Spectroradiometer Filename 
[LambdaInFilename,CameraImageFilenames,SpectroFilenames] = cameraCalibLoadMasterFile(calibDir,fNameFragment,whichMeasure);

% LOAD SPECTRORADIOMETER DATA
[LambdaPeakNm Radiance] = cameraCalibLoadSpectroData(calibDir,LambdaInFilename,SpectroFilenames,bPLOT);

% LOAD CAMERA DATA
[RGB Aperture Shutter ApertureMax] = cameraCalibLoadCameraData(whichCamera,calibDir,fNameFragment,LambdaInFilename,CameraImageFilenames,bPLOT);

% RELATIVE APERTURE
Arel = (ApertureMax.^2)./(Aperture.^2); 

% DURATION
T = Shutter;

% SPECTRAL SENSITIVITY OF R,G, and B PIXELS... (eqns 3,4,5 of CameraCalibrationNotes.doc)
Srgb = bsxfun(@rdivide,RGB,Radiance.*Arel.*T); % GIVES THE PIXEL VALUE PER RADIANCE*APERTUR*SHUTTER SPEED

if bPLOT
    figure; hold on;
    color = 'rgb';
    for c = 1:3
        plot(LambdaPeakNm,Srgb(:,c),'-','color',color(:,c),'linewidth',2)
    end
    formatFigure('\lambda (nm)','Pixel Value Sensitivity');
    xlim(minmax(LambdaPeakNm));
end