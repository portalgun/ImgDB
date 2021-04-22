function smpPosUntDwn = smpPosDownsample(smpPosUnt,dnK)

% function smpPosUntDwn = smpPosDownsample(smpPosUnt,dnK)
% 
%   example call: smpPosDownsample(smpPos(104,104),8), smpPos(13,13)
%
% smpPosUnt:    sample positions in an arbtirary unit
% dnK:          downsampling factor
% %%%%%%%%%%%%%%%%%%%%
% smpPosUntDwn: downsampled positions


if dnK < 1, error(['smpPosDownsample: WARNING! invalid dnK value. dnK=' num2str(dnK)]); end

% APPLY DOWNSAMPLING & AVERAGING TO SENSOR LOCATIONS
if     mod(length(smpPosUnt)./dnK,2) == 0, indSmp =              1:dnK:numel(smpPosUnt); 
elseif mod(length(smpPosUnt)./dnK,2) == 1, indSmp = floor(dnK/2+1):dnK:numel(smpPosUnt);
else
    error(['smpPosDownsample: WARNING! invalid dnK value. dnK=' num2str(dnK)]);
end

% DOWNSAPMLE
smpPosUntDwn = smpPosUnt(indSmp);