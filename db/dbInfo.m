classdef dbInfo < handle & imgInfo
% ROOT DB, no hash or type
properties
    database
    rootDBdir

    badImages
    allImages
    gdImages

end
methods
    function obj=dbInfo(database,bNoPlane)
        if ~exist('bNoPlane','var') || isempty(bNoPlane)
            bNoPlane=0;
        end
        obj.database=database;
        obj.rootDBdir=BLdirs(database);

        obj.get_db_info();
        if ~bNoPlane
            obj.init();
        else
            obj.nPix=prod(obj.IszRC);
            obj.get_eye();
        end
    end
    function obj=get_db_info(obj)
        file=[obj.rootDBdir 'dbInfo.mat'];
        S=load(file);
        flds=fieldnames(S.db);
        for i = 1:length(flds)
            fld=flds{i};
            obj.(fld)=S.db.(fld);
        end
    end
end
end
