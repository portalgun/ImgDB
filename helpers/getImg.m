function varargout=getImg(type,varargin)
% getImg('LRSI','img','pht',1,'L')
    dbI=dbImg(type,varargin{:});
    flds=fieldnames(dbI.im);
    ind=ismember(flds,'edges');

    bEdges=0;
    if any(ind)
        bEdges=1;
        flds(ind)=[];
    end
    if numel(flds)==1 && iscell(dbI.im.(flds{1})) && numel(flds)==1 && nargout >= 2
        varargout{1}=dbI.im.(flds{1}){1};
        varargout{2}=dbI.im.(flds{1}){2};
        n=2;
    elseif numel(flds)==1 && iscell(dbI.im.(flds{1})) && numel(flds)==1 && nargout == 1
        varargout{1}=dbI.im.(flds{1});
        return
    elseif  numel(flds)==1 && iscell(dbI.im.(flds{1})) && numel(flds)==1
        varargout{1}=dbI.im.(flds{1}){1};
        n=1;
    elseif  numel(flds)==1 && ~iscell(dbI.im.(flds{1}))
        varargout{1}=dbI.im.(flds{1});
        n=1;
    end
    if bEdges && nargout > n
        varargout{n+1}=dbi.im.edges;
    end
end
