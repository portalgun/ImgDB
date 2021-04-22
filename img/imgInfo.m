classdef imgInfo < handle & idxConversions
% basic Root db image properties
properties
    nPix
    IszRC
    IPDm
    bLandR
    screenRCm
    pixPerDeg

    LExyz
    RExyz
    CExyz
    L
    R

    IppZm
    IppYm
    IppXm

    xOffset=0;
    yOffset=0;
end
methods
    function obj=init(obj)
        obj.nPix=prod(obj.IszRC);
        obj.get_eye();
        obj.get_proj_planes();
        obj.proj_plane_to_grid();
    end
    function obj=get_eye(obj)
        obj.LExyz = [-obj.IPDm/2 0 0];
        obj.RExyz = [ obj.IPDm/2 0 0];
        obj.CExyz = [ 0 0 0];

        obj.L.AExyz  = [0 0 0];
        obj.L.BExyz  = [obj.IPDm 0 0];
        obj.L.CExyz  = [obj.IPDm/2 0 0];

        obj.R.AExyz  = [0 0 0];
        obj.R.BExyz  = [-obj.IPDm 0 0];
        obj.R.CExyz  = [-obj.IPDm/2 0 0];
        
    end
    function obj=get_proj_planes(obj)
        obj.IppXm=ppfun(obj,'x');
        obj.IppYm=ppfun(obj,'y');

        function [Ipp]=ppfun(obj,dim)
            Ipp{1}=obj.(['get_proj_plane_' dim])('L');
            Ipp{2}=obj.(['get_proj_plane_' dim])('R');
            Ipp{3}=obj.(['get_proj_plane_' dim])('C');
        end
    end
%% PP
    function [IppX]=get_proj_plane_x(obj,LorR)
        % XXX xoffset check
        K=obj.([LorR 'Exyz'])(1);
        IppX    =    K + smpPos(obj.IszRC(2)./obj.screenRCm(2),obj.IszRC(2));
        IppX    =    IppX + diff(IppX(1:2))/2;
        IppX=IppX+obj.xOffset;
    end
    function [IppY]=get_proj_plane_y(obj,LorR)
        K=obj.([LorR 'Exyz'])(2);
        IppY    =   K + fliplr(smpPos(obj.IszRC(1)./obj.screenRCm(1),obj.IszRC(1)));
        IppY    =   transpose((IppY - diff(IppY(1:2))/2));
        IppY=IppY+obj.yOffset;
    end
    function obj=proj_plane_to_grid(obj)
        if iscell(obj.IppXm) && iscell(obj.IppYm)
            for ind = 1:3
                [obj.IppXm{ind},obj.IppYm{ind}] = meshgrid(obj.IppXm{ind},obj.IppYm{ind});
            end
        else
            [obj.IppXm,obj.IppYm] = meshgrid(obj.IppXm,obj.IppYm);
        end
    end
    function plot_pp(obj)
        subplot(2,1,1)
        imagesc(obj.IppXm{3})
        formatFigure('X');
        axis image
        h=size(obj.IppXm{3},1);
        w=size(obj.IppXm{3},2);
        xticks(w);
        yticks(1);
        yticklabels(h);
        xticklabels(w);
        colorbar;


        subplot(2,1,2)
        imagesc(obj.IppYm{3})
        formatFigure('Y');
        axis image
        h=size(obj.IppYm{3},1);
        w=size(obj.IppYm{3},2);
        xticks(w);
        yticks(1);
        yticklabels(h);
        xticklabels(w);
        colorbar;
    end
end
end
