function [LambdaPeakNm Radiance] = cameraCalibLoadSpectroData(fdir,LambdaInFilename,SpectroFilenames,bPLOT)

% function [LambdaPeakNm Radiance] = cameraCalibLoadSpectroData(fdir,LambdaInFilename,SpectroFilenames,bPLOT);
%
% load the spectroradiometer data for each monochrometer setting.
% return the peak wavelength and the energy (watts/std/m^2)

disp(['loading spectroradiometer data *.txt ... ']);

%%%%%%%%%%%%%%%%
% LOAD IN DATA %
%%%%%%%%%%%%%%%%
for f = 1:length(LambdaInFilename)
    [~,~,~,RadianceA(f,1) LambdaPeakNmA(f,1),rawDataA(:,:,f)] = spectroPhotometerData(fdir,SpectroFilenames(f,:)); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TWO SPECTROPHOTOMETER MEASUREMENTS WERE  % 
% MADE FOR EACH PIXEL VALUE. THE FOLLOWING %
% CODE DOES A HACKY JOB OF AVERAGING THE   % 
% TWO MEASUREMENTS                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
indWhichMeasure = findstr(SpectroFilenames(1,:),'V')+1;
whichMeasureA = str2num(SpectroFilenames(1,indWhichMeasure));
SpectroFilenamesB = SpectroFilenames;
if whichMeasureA == 1
    whichMeasureB = 2;
elseif whichMeasureA == 2
    whichMeasureB = 1;
else
    error(['cameraCalibLoadSpectroData: WARNING! unhandled whichMeasure: ' whichMeasure]);
end
SpectroFilenamesB(:,indWhichMeasure) = num2str(whichMeasureB);

%%%%%%%%%%%%%%%%%%%%%%
% LOAD IN OTHER DATA %
%%%%%%%%%%%%%%%%%%%%%%
for f = 1:length(LambdaInFilename)
    [~,~,~,RadianceB(f,1) LambdaPeakNmB(f,1),rawDataB(:,:,f)] = spectroPhotometerData(fdir,SpectroFilenamesB(f,:)); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AVERAGE TWO MEASUREMENTS TO ELIMINANT NOISE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Radiance     = mean([RadianceA RadianceB],2);
LambdaPeakNm = mean([LambdaPeakNmA LambdaPeakNmB],2);
rawData = mean(cat(4,rawDataA,rawDataB),4);
if bPLOT
    figure('position',[ 122   166   776   678]);
    subplot(2,1,1); hold on;
    plot(LambdaInFilename,LambdaInFilename,'r--','linewidth',2)
    plot(LambdaInFilename,LambdaPeakNm,'k-','linewidth',2)
    formatFigure('\lambda (setting)','\lambda (measured)','Spectroradiometer Data')
    axis tight
    
    subplot(2,1,2); hold on;
    plot(squeeze(rawData(:,1,1)),squeeze(rawData(:,2,1:1:size(rawData,3))),'linewidth',1)
    plot(squeeze(rawDataA(:,1,1)),squeeze(rawDataA(:,2,1:1:size(rawDataA,3))),':','linewidth',1)
    plot(squeeze(rawDataB(:,1,1)),squeeze(rawDataB(:,2,1:1:size(rawDataB,3))),':','linewidth',1)
    formatFigure('Wavelength (nm)', 'Radiance (w/std/m^2)')
%     legend({'Avg',['V' num2str(whichMeasureA)],['V' num2str(whichMeasureB)]})
end


