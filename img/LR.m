classdef LR < handle
properties
    LorRorB
end
properties(Hidden=true)
    nLandR
    LandR
    notLandR
    LorR
    notLorR
end
properties(Hidden=true)
end
methods
    %function obj=LR(LorRorB)
    %    obj.LorRorB=LorRorB;
    %    obj.parse_LorRorB()
    %end
    function obj=parse_LorRorB(obj)
        if strcmp(obj.LorRorB,'B')
            obj.LandR={'L','R'};
            if isprop(obj,'notLandR')
                obj.notLandR={'R','L'};
            end
        elseif  strcmp(obj.LorRorB,'L')
            obj.LandR={'L'};
            if isprop(obj,'notLandR')
                obj.notLandR={'R'};
            end
        elseif  strcmp(obj.LorRorB,'R')
            obj.LandR={'L'};
            if isprop(obj,'notLandR')
                obj.notLandR={'R'};
            end
        end
        obj.nLandR=length(obj.LandR);
    end
end
end
