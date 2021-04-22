classdef XYZ < handle & dbImg & idxConversions & XYZ_CPs & XYZ_CPs_lookup & XYZ_plot & XYZ_project & XYZ_vrg
%xyz=XYZ('LRSI',1)
%xyz.get_CPs_all_bi
% LorRorC:      left,right or cyclopean co-ordinate system to use
%            'L' -> left      image used   as reference
%            'R' -> right     image used   as reference
%          ? 'C' -> cyclopean image ?
% IPDm:      inter-ocular distance to simulate
% Ixyz:      range data in cartesian coordinates [ r x c x 3 ]
%
%            Ixyz(:,:,1) -> x-values
%            Ixyz(:,:,2) -> y-values
%            Ixyz(:,:,3) -> z-values
properties
    xyz
    itpXYZ
    dispXYZ

    CPs
    LitpRC
    RitpRC
    CitpRC
    LitpRCchk
    RitpRCchk

    % db
    disp

    IvrgDeg
end
properties(Hidden=true)
    MLR
    cpLookup

    LANDR={'L','R'};
    NOTLANDR={'R','L'};
    NOTK=[2 1];
end
methods
    function obj=XYZ(database,I, db,MLR,allRC,allXYZ)
        if ~exist('db','var')
            db=[];
        end
        obj@dbImg(database,'img','xyz',I,[],0,db);
        obj.xyz{1}=obj.im.xyz{1};
        obj.xyz{2}=obj.im.xyz{2};
        obj.im=[];

        if exist('MLR','var') && ~isempty(MLR)
            obj.MLR=MLR;
        end

        if exist('allRC','var') && ~isempty(allRC)
            obj.allRC=allRC;
        end
        if exist('allXYZ','var') && ~isempty(allXYZ)
            obj.allXYZ=allXYZ;
        end

    end
    function [k,nk]=get_k(obj,LorR)
        if isnumeric(LorR)
            k=LorR;
        elseif LorR=='L'
            k=1;
        elseif LorR=='R'
            k=2;
        end

        if k==1
            nk=2;
        elseif k==2
            nk=1;
        end
    end
    function [LorR,notLorR]=get_LorR(obj,k)
        if ischar(k)
            LorR=k;
        elseif k==3
            LorR='C';
        else
            LorR=char(transpose(obj.LANDR(k)));
        end
        notLorR=char(transpose(obj.NOTLANDR(k)));
    end
    function obj=set_image(obj,I)
        % XXX ?
        obj.I=I;
        obj.reset_CPs();
        obj.reset_cpLookup();
    end
end
methods(Static=true)
end
end
