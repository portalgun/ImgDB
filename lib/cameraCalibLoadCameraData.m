function [RGB Aperture Shutter ApertureMax] = cameraCalibLoadCameraData(whichCamera,calibDir,fNameFragment,LambdaInFilename,CameraImageFilenames,bPLOT)

% slash = slashMACorPC;
disp(['loading cropped camera data *Crop.ppm ... ']);

% GET VERSION STRING
versionString = CameraImageFilenames(1,findstr(CameraImageFilenames(1,:),'V'):findstr(CameraImageFilenames(1,:),'V')+1);

% LOAD EXIF DATA TO GET APERTURE AND SHUTTER SPEED
fidExif = fopen([calibDir 'Img' fNameFragment '_' versionString '_exifDataFile.txt']);

for f = 1:length(LambdaInFilename)
    fNameString(f,:)   = fscanf(fidExif,'%s',1);
    ISO(f,1)           = str2num(fscanf(fidExif,'%s',1));
    Aperture(f,1)      = str2num(fscanf(fidExif,'%s',1));
    Shutter(f,1)       = str2num(fscanf(fidExif,'%s',1));
    FocusDistance(f,1) = str2num(fscanf(fidExif,'%s',1));
    
    % CHECK THAT EACH FILE EXISTS
    fName = [calibDir CameraImageFilenames(f,:)];
    fid = fopen(fName,'r');
    if fid == -1
        error(['cameraCalibLoadCameraData: cannot open file ' fName]);
    end
    fclose(fid);
    
    % LOAD CROPPED IMAGE DATA
    I = (imread(fName));
    
    % AVERAGE THE R, G, and B PIXELS IN THE CROPPED IMAGE
    RGB(f,1) = mean(mean(I(:,:,1)));
    RGB(f,2) = mean(mean(I(:,:,2)));
    RGB(f,3) = mean(mean(I(:,:,3)));
    
    %%
    if bPLOT == 1 
        if f == 1
        figure('position',[775   165   654   679]);
        end
        subplot(2,1,1);
        imagesc(I); axis equal; axis tight; axis off;
        formatFigure('','',['\lambda (monochrometer setting)=' num2str(LambdaInFilename(f))]);
        
        bins = 0:500:67500;
        subplot(2,1,2);  cla; hold on;
        hist(reshape(double(I(:,:,1)),numel(I(:,:,1)),1),bins);
        h1 = findobj(gca,'Type','patch');
        hist(reshape(double(I(:,:,2)),numel(I(:,:,2)),1),bins);
        hist(reshape(double(I(:,:,3)),numel(I(:,:,3)),1),bins);
        h = findobj(gca,'Type','patch');
        set(h(3),'FaceColor','r','EdgeColor','k')
        set(h(2),'FaceColor','g','EdgeColor','k')
        set(h(1),'FaceColor','b','EdgeColor','k')
        formatFigure('Pixel Value','Occurence')
        xlim([minmax(bins)])
        killer = 1;
        if LambdaInFilename(f) >= 595
        killer = 1;
        end
        pause(.25);
    end
end
fclose(fidExif);

% MAX APERTURE DATA
if strcmp(whichCamera,'D7H')
    ApertureMax = 2.8;
elseif strcmp(whichCamera,'D7R')
    ApertureMax = 2.8;
else
    error(['cameraCalibLoadCameraData: ApertureMax not entered for whichCamera: ' whichCamera ]);
end

%%
if bPLOT == 1
%     clf;
    figure(223); hold on;
    set(gcf,'position',[200         550        1096         556]);
    subplot(1,2,1); hold on
    plot(LambdaInFilename,RGB(:,1),'r',LambdaInFilename,RGB(:,2),'g',LambdaInFilename,RGB(:,3),'b','linewidth',2);
    formatFigure('\lambda (monochrometer setting)','PixelValue','Raw');
    xlim([350 750])
    set(gca,'xtick',[400:100:700])
    set(gca,'yscale','log')
    legend({'R' 'G' 'B'},2);
    axis square;
    
    subplot(1,2,2);
    plot(LambdaInFilename,RGB(:,1).*((Aperture./ApertureMax).^2)./Shutter,'r', ...
         LambdaInFilename,RGB(:,2).*((Aperture./ApertureMax).^2)./Shutter,'g', ...
         LambdaInFilename,RGB(:,3).*((Aperture./ApertureMax).^2)./Shutter,'b','linewidth',2);
    formatFigure('\lambda (monochrometer setting)','PixelValue*A/T','RawScaled');
    xlim([350 750])
    set(gca,'xtick',[400:100:700])
    legend({'R' 'G' 'B'},2);
    axis square;
end