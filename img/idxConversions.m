classdef idxConversions < handle
properties(Hidden =true)
% deps
    % ISZRC
       allRC
       blankmap
       indLookup
       X
       Y
end
methods
    function obj=get_allRC(obj)
        obj.allRC=distribute(1:obj.IszRC(1),1:obj.IszRC(2));
    end
    function obj=get_blankmap(obj)
        obj.blankmap=zeros(obj.IszRC);
    end
    function obj=get_indLookup(obj)
        obj.indLookup=reshape(1:(obj.IszRC(1)*obj.IszRC(2)),obj.IszRC);
    end
    function obj=get_XY(obj)
        [obj.X, obj.Y]=meshgrid(1:obj.IszRC(2), 1:obj.IszRC(1));
    end
%%
    function [ind,RC]=get_from_map_bi(obj,map)
        ind=obj.get_ind_from_map_bi(map);
        RC=obj.get_RC_from_map_bi(map);
    end
    function [map,RC]=get_from_ind_bi(obj,ind)
        map=obj.get_map_from_ind_bi(ind);
        RC=obj.get_RC_from_map_bi(ind);
    end
    function [map,ind]=get_from_RC_bi(obj,RC)
        ind=obj.get_ind_from_RC_bi(RC);
        map=obj.get_map_from_ind_bi(ind);
    end
    %
    function [ind,RC]=get_from_map(obj,map)
        ind=obj.get_ind_from_map(map);
        RC=obj.get_RC_from_map(map);
    end
    function [map,RC]=get_from_ind(obj,ind)
        map=obj.get_map_from_ind(ind);
        RC=obj.get_RC_from_map(ind);
    end
    function [map,ind]=get_from_RC(obj,RC)
        ind=obj.get_ind_from_RC(RC);
        map=obj.get_map_from_ind(ind);
    end
%%
    function map=get_map_from_ind_bi(obj,ind)
        map{1}=obj.get_map_from_ind(ind{1});
        map{2}=obj.get_map_from_ind(ind{2});
    end
    function map=get_map_from_RC_bi(obj,RC)
        map{1}=obj.get_map_from_RC(RC{1});
        map{2}=obj.get_map_from_RC(RC{2});
    end
    %
    function ind=get_ind_from_map_bi(obj,map)
        ind{1}=obj.get_ind_from_map(map{1});
        ind{2}=obj.get_ind_from_map(map{2});
    end
    function ind=get_ind_from_RC_bi(obj,RC)
        ind{1}=obj.get_ind_from_map(RC{1});
        ind{2}=obj.get_ind_from_map(RC{2});
    end
    %
    function RC=get_RC_from_map_bi(obj,map)
        RC{1}=obj.get_RC_from_map(map{1});
        RC{2}=obj.get_RC_from_map(map{2});
    end
    function RC=get_RC_from_ind_bi(obj,ind)
        RC{1}=obj.get_RC_from_ind(ind{1});
        RC{2}=obj.get_RC_from_ind(ind{2});
    end
%%
    function map=get_map_from_ind(obj,ind)
        map=obj.blankmap;
        map(ind)=1;
    end
    function map=get_map_from_RC(obj,RC)
        map=obj.blankmap;

        % XXX faster?
        ind=sub2ind(obj.IszRC,RC(:,1),RC(:,2));
        map(ind)=1;
    end
    %
    function RC=get_RC_from_map(obj,map)
        if ~islogical(map)
            map=logical(map);
        end
        RC(:,1)=obj.Y(map);
        RC(:,2)=obj.X(map);
    end
    function RC=get_RC_from_ind(obj,ind)
        [RC(:,1),RC(:,2)]=ind2sub(obj.IszRC,ind);
    end
    %
    function ind=get_ind_from_map(obj,map)
        if islogical(map)
            ind=obj.indLookup(map);
        else
            ind=obj.indLookup(logical(map));
        end
    end
    function ind=get_ind_from_RC(obj,RC)
        ind=sub2ind(obj.IszRC,RC(:,1),RC(:,2));
    end
end
end
