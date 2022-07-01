function smpPosUntDwn = smpPosDownsample(Wave.smpPosUnt,dnK)

    % function Wave.smpPosUntDwn = Wave.smpPosDownsample(Wave.smpPosUnt,dnK)
    %
    %   example call: Wave.smpPosDownsample(Wave.smpPos(104,104),8), Wave.smpPos(13,13)
    %
    % Wave.smpPosUnt:    sample positions in an arbtirary unit
    % dnK:          downsampling factor
    % %%%%%%%%%%%%%%%%%%%%
    % Wave.smpPosUntDwn: downsampled positions


    if dnK < 1, error(['Wave.smpPosDownsample: WARNING! invalid dnK value. dnK=' num2str(dnK)]); end

    % APPLY DOWNSAMPLING & AVERAGING TO SENSOR LOCATIONS
    if     mod(length(Wave.smpPosUnt)./dnK,2) == 0, indSmp =              1:dnK:numel(Wave.smpPosUnt);
    elseif mod(length(Wave.smpPosUnt)./dnK,2) == 1, indSmp = floor(dnK/2+1):dnK:numel(Wave.smpPosUnt);
    else
        error(['Wave.smpPosDownsample: WARNING! invalid dnK value. dnK=' num2str(dnK)]);
    end

    % DOWNSAPMLE
    Wave.smpPosUntDwn = Wave.smpPosUnt(indSmp);
end
