function [Inew,bIndBd] = imageRescale(I,Q,B,bPLOT,bPLOTbad)

% function imageRescale(I,Q,B,bPLOT)
%
%   example call: Lnew = imageRescale(Lpht,quantile(Lpht(:),[.001 .999]),[0 2^16-1],1,1);  
%
% scale image to user-specified bounds
%
% I:        image
% Q:        lower and upper values of original image (quantile of pix values)
%           values below min(Q) are clipped
%           values above max(Q) are clipped
% B:        lower and upper bounds (after rescaling)
%           Q(1) -> B(1) 
%           Q(2) -> B(2)
% bPLOT:    plot or not
%           1 -> plot
%           0 -> not
% %%%%%%%%%%%%%%%%%%
% Inew:     rescaled image
% bIndBd:   boolean of size(Inew) indicating pixels outside rescaled bounds


if ~exist('bPLOT','var')    || isempty(bPLOT)    bPLOT = 0;    end
if ~exist('bPLOTbad','var') || isempty(bPLOTbad) bPLOTbad = 0; end

K = (B(2) - B(1))./(Q(2)- Q(1));
Inew = K.*( I - Q(1) ) + B(1);

bIndBd = zeros(size(Inew));
bIndBd(Inew>B(2)) = 1;
bIndBd(Inew<B(1)) = 1;

Inew(Inew>B(2)) = B(2);
Inew(Inew<B(1)) = B(1);

if bPLOT
    %% EXPONENT FOR GAMMA CORRECTION
    exp = .5;
    figure('position',[ 560   155   808   992]); 
    subplot(2,1,1);
    imagesc(I.^exp); axis image;
    Fig.format([],[],['Q=[' num2str(Q(1)) ' ' num2str(Q(2)) ']']);
    caxis(minmax(I).^exp)
    
    subplot(2,1,2);
	imagesc(Inew.^exp); axis image; hold on
	if bPLOTbad 
    [r c] = ind2sub(size(Inew),find(bIndBd));
    plot(c,r,'r.');
    end
    Fig.format([],[],['B=[' num2str(B(1)) ' ' num2str(B(2)) ']; # bad = ' num2str(sum(bIndBd(:))) '; % bad = ' num2str(100.*sum(bIndBd(:))./numel(bIndBd),'%.2f') ]);
    colormap gray;
    caxis(B.^exp)
end