classdef XYZ_CPs_lookup < handle
methods
    function obj=reset_cpLookup(obj)
        obj.cpLookup=cell(2,1);
    end
    function ind=get_nearest_anch_ind(obj,IctrRC,LorR)
        k=obj.get_k(LorR);
        ind=dsearchn(obj.CPs{k}{k},IctrRC);
    end
    function ind=get_nearest_CP_ind(obj,IctrRC,LorR)
        [~,k]=obj.get_k(LorR);
        ind=dsearchn(obj.CPs{k}{k},IctrRC);
    end
    function [obj,BitpRC,ind]=get_CP_pixel(obj,LorR,IctrRC)
        % GET CPS if ~exist
        if LorR=='L' && (isempty(obj.CPs) || isempty(obj.CPs{1}))
            obj.get_CPs(LorR,IctrRC);
        elseif LorR=='R' && (isempty(obj.CPs) || isempty(obj.CPs{2}))
            obj.get_CPs(LorR,IctrRC);
        end

        [k,nk]=obj.get_k(LorR);

        % GET LOOKUP if ~exist
        %if isempty(obj.cpLookup)
        %    33
        %    obj.get_cpLookup_bi();
        %end
        ind=obj.get_nearest_anch_ind(IctrRC,LorR);
        % XXX
        BitpRC=obj.CPs{k}{nk}(ind,:);
    end
    function cpRC=lookup_CP(obj,valRCorInd,anchor)
        if anchor=='L'
            anchor=1;
        elseif anchor=='R'
            anchor=2;
        end

        if size(valRCorInd,2)==2
            inds=sub2ind(obj.db.IszRC, valRCorInd(:,1),valRCorInd(:,2));
        else
            inds=valRCorInd;
        end
        cpRC=obj.cpLookup{anchor}(inds,:);
    end
    function [obj,inds]=get_cpLookup_bi(obj)
        if isempty(obj.CPs)
            obj.get_CPs_all_bi();
        end
        obj.cpLookup=cell(2,1);
        inds=cell(2,1);
        [obj.cpLookup{1}, inds{1}]=obj.get_cpLookup_h('L');
        [obj.cpLookup{2}, inds{2}]=obj.get_cpLookup_h('R');
    end
    function [obj,inds]=get_cpLookup(obj,LorR)
        obj.cpLookup=cell(2,1);
        if LorR=='L'
            [obj.cpLookup{1}, inds{1}]=get_cpLookup_h('L');
        elseif LorR=='R'
            [obj.cpLookup{2}, inds{2}]=get_cpLookup_h('R');
        end
    end

    function [cpLookup, indsA]=get_cpLookup_h(obj,LorR)

        [k,nk]=obj.get_k(LorR);
        AitpRC=obj.CPs{k}{k};
        BitpRC=obj.CPs{k}{nk};

        Isz=obj.db.IszRC;

        [~,indsA]=sort(sub2ind(Isz, AitpRC(:,1), AitpRC(:,2)));

        cpLookup=shrink_cps(BitpRC(indsA,:), Isz);

        function in=shrink_cps(in,IszRC)
            %in=round(in);
            %in(in(:,1) == 0)=1;
            %in(in(:,2) == 0)=1;
            %in(in(:,1) == IszRC(1)+1)=IszRC(1);
            %in(in(:,2) == IszRC(2)+1)=IszRC(2);

            in(in(:,1) <= 0)=nan;
            in(in(:,2) <= 0)=nan;
            in(in(:,1) > IszRC(1))=nan;
            in(in(:,2) > IszRC(2))=nan;
        end

    end
%% FILE
    function save_cpLookup_all(obj)
        fname=obj.get_cpLookup_fname();

        if isempty(obj.cpLookup)
            obj.get_cpLookup_bi();
        end
        cpLookup=obj.cpLookup;
        save(fname,'cpLookup');
    end
    function out=exist_cpLookup_file(obj)
        fname=obj.get_CPs_fname();
        out=exist([fname '.mat'],'file');
    end
    function load_cpLookup_all(obj)
        fname=obj.get_cpLookup_fname();
        load(fname);
        obj.cpLookup=cpLookup;
    end
    function fname=get_cpLookup_fname(obj)
        dir=[obj.db.DBdir 'cpLookup' filesep];
        chkDirAll(dir,1);
        name=num2str(obj.I,'%03i');
        fname=[dir name];
    end
end
end
