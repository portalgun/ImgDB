classdef subdbInfo < handle & dbInfo & imgInfo
properties
    type
    hash
    DBdir
end
methods
    function obj= subdbInfo(database,type,hash,bNoPlane)
        if ~exist('bNoPlane','var')
            bNoPlane=0;
        end
        obj@dbInfo(database,bNoPlane);
        obj.type=type;
        obj.hash=hash;
        obj.get_dire();
    end
    function obj = get_dire(obj)

        if iscell(obj.hash)
            for i = 1:length(obj.hash)
                obj.DBdir{i}=Env.var('ImgDB.img', obj.database, obj.hash{i});
                %obj.DBdir{i}=[obj.rootDBdir obj.type filesep obj.hash{i} filesep];
            end
        else
            obj.DBdir=Env.var('ImgDB.img', obj.database, obj.hash);
            %obj.DBdir=Env.var('Imgdb.img',obj.database,obj.hash);
            %obj.DBdir=[obj.rootDBdir obj.type filesep obj.hash filesep];
        end

    end
end
end
