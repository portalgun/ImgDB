function [D7HnormWeighted D7Hnorm lambdaNm d65] = D7Hsensitivity_d65(D7HlambdaSamplingNm,bPLOT)

% function [D7HnormWeighted D7Hnorm lambdaNm d65] = D7Hsensitivity_d65(D7HlambdaSamplingNm,bPLOT)
%
%   example call: D7Hsensitivity_d65(10,1)
%
% Nikon D700 Handheld pixel sensitivities measured in the GeislerLab in during 2011
%
%
% D7HlambdaSamplingNm: desired wavelength resolution of data
% bPLOT:               plot or not
%%%%%%%%%%%%%%%%%%%
% D7HnormWeighted: D7H sensitivities weighted by the d65 spectrum
% D7Hnorm:         D7H sensitivities NOT weighted by the d65 spectrum
% lambdaNm:        wavelength 
% d65:             d65 illuminant

if ~exist('bPLOT','var') || isempty(bPLOT)
   bPLOT = 0; 
end

% RAW D7H CONE SENSITIVITY AND CORRESPONDING WAVELENGTHS OFF CVRL WEBSITE
[D7H lambdaNm] = D7Hsensitivity; 

% d65 SPECTRUM
load d65; % d65(:,1) = lambdaNm in 10nm steps
          % d65(:,2) = ?relative? illumination in units of ???

% REMOVE DATA NOT SPACED PROPERLY OR DATA OUTSIDE RANGE WHERE d65 WAS MEASURED
indBad              = mod(lambdaNm(:,1),D7HlambdaSamplingNm) ~= 0 | ...
                          lambdaNm(:,1)                      < min(d65(:,1)) | ...
                          lambdaNm(:,1)                      > max(d65(:,1));
lambdaNm(indBad,:) = [];
D7H(indBad,:)      = [];

% INTERPOLATE D65 SPECTRUM TO MATCH THE WAVELENGTH SAMPLES IN CVRL DATABASE
d65                 = interp1(d65(:,1),d65(:,2),lambdaNm(:,1));

% NORMALIZE TO VECTOR MAGNITUDE OF 1
D7Hnorm             = bsxfun(@rdivide,D7H,sum(D7H));

% WEIGHT    D7H SENSITIVITIES BY d65
D7Hweighted         = bsxfun(@times,d65,D7H);

% NORMALIZE WEIGHTED D7H SENSITIVITIES TO VECTOR MAGNITUDE OF 1
D7HnormWeighted     = bsxfun(@rdivide,D7Hweighted,sum(D7Hweighted));

% SAVE DATA
% save(['D7Hsensitivity_d65_' num2str(D7HlambdaSamplingNm) 'nmSpacing.mat'],'lambdaNm','D7Hnorm','D7HnormWeighted','d65','D7HlambdaSamplingNm')

if bPLOT == 1
    figure('position',[216   197   634   587]); hold on;
    plot(lambdaNm,D7Hnorm(:,1),'r-','linewidth',2)
    plot(lambdaNm,D7Hnorm(:,2),'g-','linewidth',2)
    plot(lambdaNm,D7Hnorm(:,3),'b-','linewidth',2)
    plot(lambdaNm,D7HnormWeighted(:,1),'r--','linewidth',2);
    plot(lambdaNm,D7HnormWeighted(:,2),'g--','linewidth',2);
    plot(lambdaNm,D7HnormWeighted(:,3),'b--','linewidth',2);
    plot(lambdaNm,d65./sum(d65),'ko-');
    Fig.format('Wavelength (nm)','Sensitivity');
    legend({'L','M','S','L_{d65}','M_{d65}','S_{d65}','d65'});
    axis square
end
