function [Lret,Rret,Lccd,Rccd,LretDC,RretDC,LccdDC,RccdDC] = Iccd2IretDSP(LccdBffr,RccdBffr,PszXY,PSF_L,PSF_R,W,bPreWndw,bPLOT)

% function [Lret,Rret,Lccd,Rccd,Ldc,Rdc] = Iccd2IretDSP(LccdBffr,RccdBffr,PszXY,PSF_L,PSF_R,W,bPreWndw,bPLOT)
%
%   example call: IctrRC = [800 500]; PszXYbffr = [160 160]; PszXY = [104 104]; W =cosWindow(PszXY);
%                 lensInfo = lensInfoStruct({'NVR' 'NVR'},4,'IDP','FLT',104,[104 104],1);
%                 [~,~,~,~,LphtBffr,~,~,RphtBffr]=LRSIsamplePatch(8,'L',IctrRC,[PszXYbffr],-5,'PHT','linear',1,1);
%                 Iccd2IretDSP(LphtBffr,RphtBffr,[PszXY],lensInfo.PSF_L,lensInfo.PSF_R,W,1,1);
%
% LccdBffr:   left  image with spatial buffer
% RccdBffr:   right image with spatial buffer
% PszXYbffr:  sized of patch with buffer to prevent optical artifacts
% PSF_L:      optical transfer function for left image
% PSF_R:      optical transfer function for right image
% W:          window to compute local stats with and prewindow (if desired)
% bPreWndw:   boolean to indicate whether to pre-window the stimulus
%             1 -> bakes window into stimulus (good for psychophysics)
%             0 -> does not                   (good for ...)
% bPLOT:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lret:       left  eye retinal       image in column vector form
% Rret:       right eye retinal       image in column vector form
% Lccd:       left  eye ccd luminance image in column vector form
% Rccd:       right eye ccd luminance image in column vector form
% Ldc:        left  eye mean luminance
% Rdc:        right eye mean luminance

% INPUT HANDLING
if ~exist('bPLOT','var') || isempty(bPLOT) bPLOT = 0; end
if size(LccdBffr,1) < PszXY(2) || size(LccdBffr,2) < PszXY(1) error(['Iccd2IretDSP: WARNING! LccdBffr smaller than PszXY']); end
if size(RccdBffr,1) < PszXY(2) || size(RccdBffr,2) < PszXY(1) error(['Iccd2IretDSP: WARNING! RccdBffr smaller than PszXY']); end
% CHECK WINDOW VALUES
if numel(W) == 1
    if isequal(W,1), W = ones(fliplr(PszXY)); disp( ['Iccd2IretDSP: WARNING! W = 1. Will not window!']);
    else             W = ones(fliplr(PszXY)); error(['Iccd2IretDSP: WARNING! W = ' num2str(W) '. Unhandled window value!']);
    end
end
% if sum(W(:))==numel(W) disp(['Iccd2IretDSP: WARNING! window W is all ones. No windowing will occur']); end
% CHECK WINDOW SIZE
if size(W,1) ~= PszXY(2) ||size(W,2) ~= PszXY(1), error(['Iccd2IretDSP: WARNING! invalid window size [' num2str(size(W,2)) 'x' num2str(size(W,1)) ']. PszXY [' num2str(PszXY(1)) 'x' num2str(PszXY(2)) ']']); end

% SAVE ORIGINAL BUFFERED IMAGE
LccdBffrOrig = LccdBffr;
RccdBffrOrig = RccdBffr;

% INPUT HANDLING: CHECK BUFFER SIZE
PszRCbffr = size(LccdBffr);
PszRC     = fliplr(PszXY);
PszRCdff = PszRCbffr-PszRC;
if mod(PszRCdff(1),2) ~= 0 || mod(PszRCdff(2),2) ~= 0,
    error(['Iccd2IretDSP: WARNING! PszXYbffr differs from PszXY by odd number of pixels! Fix it!']);
end

%%%%%%%%%%%%%%%%%%%%%
% APPLY LENS OPTICS %
%%%%%%%%%%%%%%%%%%%%%
LretBffr = conv2(LccdBffr,PSF_L,'same');
RretBffr = conv2(RccdBffr,PSF_R,'same');

% CROP BUFFERED L/R CCD IMAGES
Lccd = cropImageCtr(LccdBffr,[],PszXY);
Rccd = cropImageCtr(RccdBffr,[],PszXY);
% CROP BUFFERED L/R RET IMAGES
Lret = cropImageCtr(LretBffr,[],PszXY);
Rret = cropImageCtr(RretBffr,[],PszXY);

% WINDOW CONTRAST IMAGE (BAKES WINDOW INTO STIMULUS)
if bPreWndw == 1
    % LOCAL CONTRAST IMAGES
    [LccdWeb,LccdDC] = contrastImage(Lccd,W);
    [RccdWeb,RccdDC] = contrastImage(Rccd,W);
    [LretWeb,LretDC] = contrastImage(Lret,W);
    [RretWeb,RretDC] = contrastImage(Rret,W);
    % WINDOW CONTRAST IMAGES
    LccdWeb = LccdWeb.*W;
    RccdWeb = RccdWeb.*W;
    LretWeb = LretWeb.*W;
    RretWeb = RretWeb.*W;
    % CONVERT BACK TO INTENSITY IMAGE
    Lccd = LccdWeb.*LccdDC + LccdDC;
    Rccd = RccdWeb.*RccdDC + RccdDC;
    Lret = LretWeb.*LretDC + LretDC;
    Rret = RretWeb.*RretDC + RretDC;
elseif bPreWndw == 0
	% LOCAL CONTRAST IMAGES
    [~,LccdDC] = contrastImage(Lccd,W);
    [~,RccdDC] = contrastImage(Rccd,W);
    [~,LretDC] = contrastImage(Lret,W);
    [~,RretDC] = contrastImage(Rret,W);
else error(['Iccd2IretSPD: WARNING! unhandled bPreWndw value. bPreWndw=' num2str(bPreWndw)]);
end

%%
if bPLOT
    figure(5555); set(gcf,'position',[1000 300 600 1080]);
    subplot(4,1,1); cla; imagesc([LccdBffrOrig RccdBffrOrig].^.4);  hold on; colormap gray(256); axis image; Fig.format([],[],['Lccd & Rccd Buffer [' num2str(PszRCbffr(2)) 'x' num2str(PszRCbffr(1)) ']'] );
    plotSquare(fliplr(floor(size(LccdBffr)./2+1)),PszXY,'y',1); plotSquare([PszRCbffr(2) 0]+fliplr(floor(size(LccdBffr)./2+1)),PszXY,'y',1);
    plotSquare(fliplr(floor(size(LccdBffr)./2+1)),[4 4],'y',1); plotSquare([PszRCbffr(2) 0]+fliplr(floor(size(LccdBffr)./2+1)),[4 4],'y',1);

    subplot(4,1,2); cla; imagesc([LretBffr RretBffr].^.4); hold on; colormap gray(256); axis image; Fig.format([],[],['Lret & Rret Buffer [' num2str(PszRCbffr(2)) 'x' num2str(PszRCbffr(1)) ']'] ); cax = caxis;
    plotSquare(fliplr(floor(size(LccdBffr)./2+1)),PszXY,'y',1); plotSquare([PszRCbffr(2) 0]+fliplr(floor(size(LccdBffr)./2+1)),PszXY,'y',1);
    plotSquare(fliplr(floor(size(LccdBffr)./2+1)),[4 4],'y',1); plotSquare([PszRCbffr(2) 0]+fliplr(floor(size(LccdBffr)./2+1)),[4 4],'y',1);

    subplot(4,1,3); cla; imagesc([Lccd Rccd].^.4);          hold on; colormap gray(256); axis image; Fig.format([],[],['Lccd & Rccd [' num2str(PszXY(1)) 'x' num2str(PszXY(2)) ']']); set(gca,'xtick',[]);
    plotSquare(fliplr(floor(size(Lccd)./2+1)),PszXY,'y',1); plotSquare([PszRC(2) 0]+fliplr(floor(size(Lccd)./2+1)),PszXY,'y',1);
    plotSquare(fliplr(floor(size(Lccd)./2+1)),[4 4],'y',1); plotSquare([PszRC(2) 0]+fliplr(floor(size(Rccd)./2+1)),[4 4],'y',1); caxis(cax);

    subplot(4,1,4); cla; imagesc([Lret Rret].^.4);          hold on; colormap gray(256); axis image; Fig.format([],[],'Lret & Rret');
    plotSquare(fliplr(floor(size(Lccd)./2+1)),PszXY,'y',1); plotSquare([PszRC(2) 0]+fliplr(floor(size(Lccd)./2+1)),PszXY,'y',1);
    plotSquare(fliplr(floor(size(Lccd)./2+1)),[4 4],'y',1); plotSquare([PszRC(2) 0]+fliplr(floor(size(Rccd)./2+1)),[4 4],'y',1); caxis(cax);

    killer = 1;
end
