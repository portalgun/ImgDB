classdef SubjInfo < handle
properties
    name
    LExyz
    RExyz
    CExyz
    IPDm

    L
    R
end
properties(Constant,Hidden)
    defL=[-0.065/2 0 0]
    defR=[+0.065/2 0 0]
    defIPDm=0.065;
end
methods
    function obj=SubjInfo(name,Opts)
        if nargin < 2
            Opts=[];
        end
        if nargin > 1 && ~isempty(name)
            Opts=obj.read(name);
            obj.name=name;
        end
        obj.parse(Opts);

        global VDISP;
        if ~isempty(VDISP)
            VDISP.SubjInfo=obj;
            VDISP.subjname=obj.name;
        end
    end
    function parse(obj,Opts)
        if ~isempty(Opts)
            Args.parse(obj,obj.get_P,Opts);
            if isempty(obj.IPDm) && ~isempty(obj.LExyz) && ~isempty(obj.RExyz)
                obj.IPDm=abs(obj.RExyz(1)-obj.LExyz(1));
            elseif ~isempty(obj.IPDm) && isempty(obj.LExyz) && isempty(obj.RExyz)
                obj.LExyz= [-obj.IPDm/2 0 0];
                obj.RExyz= [ obj.IPDm/2 0 0];
            end
        else
            obj.name='DEFAULT';
            obj.LExyz=obj.defL;
            obj.RExyz=obj.defR;
            obj.IPDm=obj.defIPDm;
        end
        obj.CExyz = [0 0 0];

        obj.L.AExyz  = [0 0 0];
        obj.L.BExyz  = [obj.IPDm 0 0];
        obj.L.CExyz  = [obj.IPDm/2 0 0];

        obj.R.AExyz  = [0 0 0];
        obj.R.BExyz  = [-obj.IPDm 0 0];
        obj.R.CExyz  = [-obj.IPDm/2 0 0];
    end
end
methods(Static)
    function get_P()
        P={...
            'LExyz',[],'Num.is_3_e';
            'RExyz',[],'Num.is_3_e';
            'IPDm',[],'Num.is_e';
        };
    end
    function read(name)
        dire=getenv('PX_ETC');
        fil=[dire 'Subj.d' filesep name '.cfg'];
        if ~Fil.exist(fil)
            error(['Subj config ' fil ' does not exist']);
        end
        Opts=Cfg.read(fil);
    end
end
end
