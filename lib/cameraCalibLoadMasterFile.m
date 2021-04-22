function [LambdaInFilename,CameraImageFilenames,SpectroFilenames,indWhichMeasure] = cameraCalibLoadMasterFile(calibDir,fNameFragment,whichMeasure);

% function [LambdaInFilename,CameraImageNums,SpectroFilenames,indWhichMeasure] = cameraCalibLoadMasterFile(calibDir,fNameFragment,whichMeasure);
%
% load master calibration file... contains data on correspondence between 
% wavelength in filename, camera image numbers, and spectroradiometer Filenames
%
% calibDir: 
% fNameFragment:
% whichMeasure: 
% %%%%%%%%%%%%%%%%
% LambdaInFilename: all kind of self explanatory
% CameraImageNums:
% SpectroFilenames: 
% indWhichMeasure:  indices for specified measurement version
 

fNameMaster = [calibDir 'cameraCalibMaster_' fNameFragment '.txt'];
tline = ['loading cameraCalibMaster_' fNameFragment '.txt ... ']


% OPEN MASTER FILE (Wavelength, CameraImgNum, and Spectroradiometer Filename)
fid = fopen(fNameMaster);
if fid == -1
    error(['cameraCalibLoadSpectroData: WARNING! cannot load master file: ' fNameMaster '. Check file name variables']);
end

ind = 0;
tline = fgetl(fid);
while ischar(tline)
    try
        % GET ALL DATA
        ind = ind+1;
        LambdaInFilename(ind,:)      = fscanf(fid,'%f',1);
        CameraImageFilenames(ind,:)  = fscanf(fid,'%s',1);
        SpectroFilenames(ind,:)      = fscanf(fid,'%s',1);
        CameraImageNums(ind,:)       = fscanf(fid,'%f',1);
        CameraShutter(ind,:)         = fscanf(fid,'%f',1);
        CameraAperture(ind,:)        = fscanf(fid,'%f',1);
        
        % BOOLEAN VECTOR INDICATING WHETHER FILE NAME IS OF DESIRED whichMeasure 
        indWhichMeasure(ind) = ~isempty(findstr(SpectroFilenames(ind,:),['V' num2str(whichMeasure)]));
    catch
        fclose(fid);
        break; % break out of loop when end of file is reached
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET MASTER FILE NUMBER, ACTUAL CAMERA IMAGE NUMBER CORRESPONDENCE %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       *** CRITICAL THAT THIS CORRESPONDENCE IS CORRECT ***        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [CameraFileNums CameraFilenames] = cameraCalibRenameCameraFiles(fNameFragment,LambdaInFilename,CameraImageNums);

% CULL DATA THAT IS NOT OF SPECIFIED whichMeasure
LambdaInFilename = LambdaInFilename(indWhichMeasure,:);

% CAMERA ImageNums AND FileNums AND Filenames
% CameraImageNums = CameraImageNums(indWhichMeasure,:);
% CameraFileNums  = CameraFileNums(indWhichMeasure,:);
CameraImageFilenames = CameraImageFilenames(indWhichMeasure,:);

% SPECTRORADIOMETER FILENAMES
SpectroFilenames = SpectroFilenames(indWhichMeasure,:);


