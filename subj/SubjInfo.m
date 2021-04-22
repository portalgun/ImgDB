classdef SubjInfo < handle
properties
end
methods
end
methods(Static)
    function S=get_default()
        S=struct();
        S.LExyz=[-0.065/2 0 0];
        S.RExyz=[+0.065/2 0 0];
        S.IPDm =0.065;
    end
end
end
