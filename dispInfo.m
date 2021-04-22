classdef dispInfo < handle & imgInfo & idxConversions
methods
    function obj=dispInfo(prsntCtrXYZm,prsntSzRC,pixPerMxy,IPDm)
        obj.IppZm=prstnCtrXYZm(3);
        % add option for dispaly name or display object
        obj.IszRC=prstntSzRC;
        obj.screenRCm=prsntSzRC./pixPerMRC

        IctrRCm=prscnCtrXYZm(1:2)./pixPerMxy
        obj.yOffset=-IctrRCm(1); % XXX check
        obj.xOffset=-IctrRCm(2);
        obj.IppZm=IppZm;
        if exist('IPDm','var') && ~isempty(IPDm)
            obj.IPDm=IPDm;
        else
            obj.IPDm=.065;
        end
        obj.init():;
    end
end
end
