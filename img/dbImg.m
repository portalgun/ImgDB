classdef dbImg < handle & matlab.mixin.CustomDisplay
% individual image
% obj=dbImg(database,type,hash,I,LorR,bSkipDB)
% NOTE for color images
%[Limg,~,bIndBdL]  = cameraCalibrate(Limg,[],[],'D7R',calibType,16,2,0,0);
%[Rimg,~,bIndBdR]  = cameraCalibrate(Rimg,[],[],'D7R',calibType,16,2,0,0);
%
% TODO
% dnk
% inpaint

properties
    im
    LorR
    I
    fname
    db
end
methods(Access=protected)
    function db= getFooter(obj)
        db=obj.db;
    end
end
methods
    function obj=dbImg(database,type,hash,I,LorR, bSkipDB,db)
        if exist('db','var') && ~isempty(db)
            obj.db=db;
        end
        if exist('type','var') && exist('hash','var')
            obj.get_db_info(database,type,hash);
        else
            obj.get_db_info(database);
        end

        if exist('I','var') && ~isempty(I)
            obj.I=I;
        end
        if ~exist('LorR','var') || isempty(LorR) || (ischar(LorR) && strcmp(LorR,'B'))
            obj.LorR={'L','R'};
        elseif ischar(LorR) && isLorR(LorR)
            obj.LorR=LorR;
        elseif LorR==1
            obj.LorR='L';
        elseif LorR==2
            obj.LorR='R';
        end
        if ~exist('bSkipDB','var') || isempty(bSkipDB)
            bSkipDB=0;
        end

        if ~isempty(obj.I)
            obj.load_all();
        end
        %if ~bSkipDB
        %    obj.get_db_info();
        %end
    end
    function obj=get_db_info(obj,database,type,hash)
        if ~exist('type','var') || isempty(type)
            type='img';
        end
        if ~exist('hash','var') || isempty(hash)
            hash={'pht','xyz'};
        end
        obj.db=subdbInfo(database,type,hash);
    end
    function obj=load_all(obj)
        if iscell(obj.db.hash)
            for i = 1:length(obj.db.hash)
                obj.fname{i}=obj.get_fnames(obj.db.hash{i},i);
                obj.load_image(obj.fname{i},obj.db.hash{i});
            end
        else
            obj.fname=obj.get_fnames(obj.db.hash);
            obj.load_image(obj.fname,obj.db.hash);
        end
    end
    function fname=get_fnames(obj,hash,i)
        if ~exist('i','var') || isempty(i)
            i=0;
        end
        if ~iscell(obj.LorR)
            fname=obj.get_fname(obj.LorR,hash);
        else
            fname{1}=obj.get_fname('L',hash,i);
            fname{2}=obj.get_fname('R',hash,i);
        end
    end
    function fname=get_fname(obj,LorR,hash,i)
        if ~exist('i','var') || isempty(i)
            i=0;
        end
        Istr=num2str(obj.I,'%03i');
        if iscell(obj.db.DBdir)
            dire=[obj.db.DBdir{i}];
        else
            dire=[obj.db.DBdir];
        end
        if ~exist(dire,'dir')
            disp(['No such directoy ' dire])
            return
        end
        nm=[LorR Istr];
        name=regexpdir(dire,nm);
        if isempty(name)
            disp(['No such file ' nm ' in ' dire]);
            return
        end
        name=name{1};
        fname=[dire name];
    end
    function obj=load_image(obj,fname,hash)
        if ~exist('fname','var') || isempty(fname)
            fname=obj.fname;
        end
        if ~exist('hash','var') || isempty(hash)
            hash=obj.db.hash;
        end

        if regExp(hash,'^[0-9]');
            hashstr=['p' hash];
        else
            hashstr=hash;
        end

        if ~iscell(obj.LorR)
            obj.im.(hashstr)=obj.load_image_helper(fname,hash);
        else
            obj.im.(hashstr)=cell(2,1);
            obj.im.(hashstr){1}=obj.load_image_helper(fname{1},hash);
            obj.im.(hashstr){2}=obj.load_image_helper(fname{2},hash);
        end
    end
    function [i]=load_image_helper(obj,fname,hash)
        [~,~,ext]=fileparts(fname);

        if ~strcmp(ext,'.mat')
            i=double(imread(fname));
        else
            i=load(fname);
        end
        if regExp(hash,'^[0-9]');
            hashstr=['p' hash];
        else
            hashstr=hash;
        end

        if isstruct(i) && isfield(i,'bImap')
            i=i.bImap;
        elseif isstruct(i) && isfield(i,hashstr)
            i=i.(hashstr);
        elseif isstruct(i) && isfield(i,'imap')
            i=i.imap;
        elseif isstruct(i) && isfield(i,[obj.LorR hash])
            i=i.([obj.LorR hash]);
        end

        % XXX
        if startsWith(hash,'pht')
            i= cameraCalibrate(i,[],[],'D7R','PHT',16,2,0);
        %elseif startsWith(hash,'xyz')
        %    i= cameraCalibrate(i,[],[],'D7R','XYZ',16,2,0);
        end
    end
%% PLOT
    function plot(obj)
        if iscell(obj.i)
            imagesc([obj.i{1} obj.i{2}]);
        else
            imagesc(obj.i);
        end
        formatImage();
    end

end
methods(Static=true)
    function varargout=get_img(database,type,hash,I,LorR, bSkipDB,db)
        if ~exist('LorR','var')
            LorR=[];
        end
        if ~exist('bSkipDB','var')
            bSkipDB=[];
        end
        if ~exist('db','var')
            db=[];
        end
        dbI=dbImg(database,type,hash,I,LorR,bSkipDB,db);
        flds=fieldnames(dbI.im);
        if numel(flds)==1 && iscell(dbI.im.(flds{1})) && numel(flds)==1 && nargout >= 2
            varargout{1}=dbI.im.(flds{1}){1};
            varargout{2}=dbI.im.(flds{1}){2};
        elseif numel(flds)==1 && iscell(dbI.im.(flds{1})) && numel(flds)==1 && nargout == 1
            varargout{1}=dbI.im.(flds{1});
        elseif  numel(flds)==1 && iscell(dbI.im.(flds{1})) && numel(flds)==1
            varargout{1}=dbI.im.(flds{1}){1};
        elseif  numel(flds)==1 && ~iscell(dbI.im.(flds{1}))
            varargout{1}=dbI.im.(flds{1});
        end
    end

end
end
