classdef XYZ_CPs < handle
methods
    function obj=get_CPs_all_bi(obj)
        %% LOAD OR GENERATE ALL CPs for each pixel in FOR BOTH ANCHOR EYES
        if obj.exist_CPs_file
           obj.load_CPs_all();
        else
            obj.gen_CPs_all_bi();
        end
    end
    function obj=gen_CPs_all_bi(obj)
        %% GENERATE ALL CPs for each pixel in FOR BOTH ANCHOR EYES
        obj.CPs{1}=cell(1,2);
        obj.CPs{2}=cell(1,2);

        obj.get_CPs_all('L');
        obj.CPs{1}{1}=obj.db.allRC;
        obj.CPs{1}{2}=obj.RitpRC;

        ind=any(isnan(obj.CPs{1}{2}) | obj.CPs{1}{2} > obj.db.IszRC | obj.CPs{1}{2} <= 0,2);
        obj.CPs{1}{2}(ind,:)=nan;

        obj.get_CPs_all('R');
        obj.CPs{2}{2}=obj.db.allRC;
        obj.CPs{2}{1}=obj.LitpRC;

        ind=any(isnan(obj.CPs{2}{1}) | obj.CPs{2}{1} > obj.db.IszRC | obj.CPs{2}{1} <= 0,2);
        obj.CPs{2}{1}(ind,:)=nan;

        obj.reset_CPs();
        obj.reset_cpLookup();
    end
    function obj=get_CPs_all(obj,LorR,bCleanup)
        %% ALL CPs for each pixel in an anchor eye
        if ~exist('bCleanup','var') || isempty(bCleanup)
            bCleanup=0;
        end
        if isempty(obj.db.allRC)
            obj.db.get_allRC;
        end
        if LorR=='B'
            obj.get_CPs('L',obj.db.allRC,bCleanup);
        else
            obj.get_CPs(LorR,obj.db.allRC,bCleanup);
        end
    end
    function obj=get_CPs(obj,LorR,IctrRC,bCleanup)
        if ~exist('bCleanup','var') || isempty(bCleanup)
            bCleanup=0;
        end
        obj.reset_CPs();
        obj.reset_cpLookup();

        if isnumeric(LorR)
            LorR=get_LorR(LorR);
        end
        if numel(LorR)==1 && LorR=='L'
            indL=true(size(IctrRC,1),1);
            indR=false(size(IctrRC,1),1);
        elseif numel(LorR)==1 && LorR=='R'
            indL=false(size(IctrRC,1),1);
            indR=true(size(IctrRC,1),1);
        elseif  numel(LorR)==1 && LorR=='B'
            indL=repmat([true; false], size(IctrRC,1)/2, 1);
            indR=~indL;
        elseif size(LorR,1) == size(IctrRC,1)
            indL=LorR=='L';
            indR=LorR=='R';
        end

        if isempty(obj.MLR)
            obj.get_MLR();
        end

        obj.LitpRC=zeros(size(IctrRC));
        obj.RitpRC=zeros(size(IctrRC));
        obj.LitpRCchk=zeros(size(IctrRC));
        obj.RitpRCchk=zeros(size(IctrRC));
        obj.CitpRC=zeros(size(IctrRC));
        if any(indL)
            [obj.LitpRC(indL,:),obj.RitpRC(indL,:),obj.CitpRC(indL,:),obj.LitpRCchk(indL,:),obj.RitpRCchk(indL,:)]=...
                get_CP_fun(obj,'L','R', IctrRC(indL,:), obj.xyz{1},obj.xyz{2}, obj.db.IppXm{1},obj.db.IppYm{1}, obj.db.IppXm{2},obj.db.IppYm{2}, obj.MLR{1},obj.MLR{2});
        end
        if any(indR)

            [obj.RitpRC(indR,:),obj.LitpRC(indR,:),obj.CitpRC(indR,:),obj.RitpRCchk(indR,:),obj.LitpRCchk(indR,:)]=...
                get_CP_fun(obj,'R','L', IctrRC(indR,:), obj.xyz{2},obj.xyz{1}, obj.db.IppXm{2},obj.db.IppYm{2}, obj.db.IppXm{1},obj.db.IppYm{1}, obj.MLR{2},obj.MLR{1});
        end
        if bCleanup==1
            obj.cleanup_CPs();
        end

        function [Aitp,Bitp,Citp,Aitpchk,Bitpchk]=get_CP_fun(obj,A,B,IctrRC,Axyz,Bxyz,AppXm,AppYm,BppXm,BppYm,MA,MB)
            [Aitp,Bitp,Citp,~,~,indNaN]=XYZ.get_CPs_AB(A,IctrRC,        Axyz,AppXm,AppYm,1,MA,obj.db);
            [Bitpchk,Aitpchk]          =XYZ.get_CPs_AB(B,round(Bitp),   Bxyz,BppXm,BppYm,1,MB,obj.db);
            if ~isempty(indNaN)
                Aitp(indNaN,:)=NaN;
                Bitp(indNaN,:)=NaN;
                Citp(indNaN,:)=NaN;
                Aitpchk(indNaN,:)=NaN;
                Bitpchk(indNaN,:)=NaN;
            end
        end

    end
%% HELPERS
    function [AitpRC,BitpRC]=get_AitpRC(obj,LorR)
        if LorR=='L'
            AitpRC=obj.LitpRC;
            if nargout > 1
                BitpRC=obj.RitpRC;
            end
        elseif LorR=='R'
            AitpRC=obj.RitpRC;
            if nargout > 1
                BitpRC=obj.LitpRC;
            end
        end
    end
    function BitpRC=get_BitpRC(obj,LorR)
        if isnumeric(LorR)
            LorR=get_LorR(k);
        end
        if LorR=='L'
            BitpRC=obj.RitpRC;
        elseif LorR=='R'
            BitpRC=obj.LitpRC;
        end
    end
    function obj=get_MLR(obj)
        obj.MLR{1}=get_M(obj,'L',obj.xyz{2});
        obj.MLR{2}=get_M(obj,'R',obj.xyz{1});
        function M=get_M(obj,LorR,Bxyz)
            if LorR=='L'
                BxyzEye     =  obj.db.L.BExyz;
            elseif LorR=='R'
                BxyzEye     =  obj.db.R.BExyz;
            end
            BxyzEye2(1,1,:)=BxyzEye;
            M=Bxyz+BxyzEye2;
        end
    end
%% CP CLEANUP
    function obj=cleanup_CPs(obj)
        obj.LitpRC=round(obj.LitpRC);
        obj.RitpRC=round(obj.RitpRC);

        ind=any(isnan(obj.LitpRC),2) | ...
            any(isnan(obj.RitpRC),2) | ...
            any(obj.LitpRC==0,    2) | ...
            any(obj.RitpRC==0,    2) | ...
            obj.RitpRC(:,1) > obj.db.IszRC(1) |...
            obj.LitpRC(:,1) > obj.db.IszRC(1) |...
            obj.RitpRC(:,2) > obj.db.IszRC(2) |...
            obj.LitpRC(:,2) > obj.db.IszRC(2) |...
            obj.RitpRC(:,1) <= 0 |...
            obj.LitpRC(:,1) <= 0 |...
            obj.RitpRC(:,2) <= 0 |...
            obj.LitpRC(:,2) <= 0;
        obj.LitpRC(ind,:)=[];
        obj.RitpRC(ind,:)=[];
    end
    function obj=reset_CPs(obj)
        obj.LitpRC=[];
        obj.RitpRC=[];
        obj.LitpRCchk=[];
        obj.RitpRCchk=[];
    end
%% PATCH
    function [AitpRC,BitpRC,BctrRC]=get_CPs_patch(obj,LorR,PctrRC,PszRC)
        [LorR,nLorR]=obj.get_LorR(LorR);
        obj.get_CPs(LorR,PctrRC);

        ActrRC=PctrRC;
        BctrRC=obj.get_BitpRC(LorR);

        AitpRC{1}=recFun(ActrRC,PszRC);
        BitpRC{1}=recFun(BctrRC,PszRC);

        obj.get_CPs(LorR,AitpRC{1});
        AitpRC{2}=obj.get_BitpRC(LorR);

        obj.get_CPs(nLorR,BitpRC{1});
        BitpRC{2}=obj.get_BitpRC(nLorR);

        function IitpRC=recFun(IctrRC,PszRC)
            [x,y]=rect(IctrRC,PszRC(1),PszRC(2));
            IitpRC=distribute(y(3):y(1), x(2):x(1));
            ind = ...
                  IitpRC(:,1) <= 0 ...
                | IitpRC(:,2) <= 0 ...
                | IitpRC(:,1) > obj.db.IszRC(1) ...
                | IitpRC(:,2) > obj.db.IszRC(2) ...
            ;
            IitpRC(ind,:)=[];
        end
    end
%% FILE
    function save_CPs_all(obj)
        fname=obj.get_CPs_fname();

        if isempty(obj.CPs)
            obj.get_CPs_all_bi();
        end
        CPs=obj.CPs;
        save(fname,'CPs');
    end
    function out=exist_CPs_file(obj)
        fname=obj.get_CPs_fname();
        out=exist([fname '.mat'],'file');
    end
    function load_CPs_all(obj)
        fname=obj.get_CPs_fname();
        load(fname);
        obj.CPs=CPs;
    end
    function fname=get_CPs_fname(obj)
        dir=[obj.db.DBdir 'cps' filesep];
        chkDirAll(dir,1);
        name=num2str(obj.I,'%03i');
        fname=[dir name];
    end
end
methods(Static=true)
    function [AitpRC,BitpRC,CitpRC,CsmpErrDeg,DvrgDffDeg,indNaN] = get_CPs_AB(LorR,ActrRC,Axyz,AppXm,AppYm,bNaNhide,M,db)
        res=numel(Axyz);
        IszRC=db.IszRC;

        if strcmp(LorR,'L') %Assign L and R to a and B according to starting pont
            A='L';
            %B='R';
        else
            A='R';
            %B='L';
        end


        % XYZ COORDINATES OF PROJ PLANE & LEFT/RIGHT/CYCLOPEAN EYE (in left eye coordinate frame)
        %L
        AppZm           = db.IppZm;
        IPDm            = db.IPDm;

        AxyzEye     = db.(A).AExyz;
        BxyzEye     = db.(A).BExyz;
        CxyzEye     = db.(A).CExyz;

        % PROJECTION PLANE (FRONTO PARALLEL 3 METERS AWAY)
        PrjPln  = createPlane([0 0 AppZm], [1 0 AppZm], [0 1 AppZm]);

        % -------------------------------------------------------------------------------
        %FIND NaNs in ActrRC
        [indNaN,~] = find(isnan(ActrRC) | ActrRC<=0 | ActrRC > repmat(IszRC,size(ActrRC,1),1)); %Handle NaNs in ActrRC
        if ~isempty(indNaN) %temporarily assign 1s to index values, so that the entire matrix computes
            ActrRC(indNaN,:)=1;
        end
        % -------------------------------------------------------------------------------

        N=size(ActrRC,1);

        % XYZ AT CENTER OF LE SAMPLED PATCHES IN 3D
        [n,m,~]=size(Axyz);
        try
            ind=sub2ind(size(Axyz),ActrRC(:,1),ActrRC(:,2));
        catch ME
            size(Axyz)
            rethrow(ME);
        end
        ind=round([ind ind+n*m ind+2*n*m ]);

        %POINTS OUT OF RANGE
        invInd=any(ind>res,2);
        ind(invInd,:)=1; %temorparily assign 1, doesn't matter what value, kept track of by invInd

        if any(~isint(ind))
            AxyzCtr=interp2(Axyz(:,:,:),ActrRC(:,2),ActrRC(:,1));
        else
            AxyzCtr = Axyz(ind);
        end

        %Handle NaNs in AxyzCtr
        [ind,~]    = find(isnan(AxyzCtr));
        if size(ind,1)<size(ind,2)
            ind=transpose(ind);
        end
        indNaN     = [unique(ind); indNaN];
        [ind,~]    = find(invInd);
        indNaN     = [ind; indNaN];
        indNaN=unique(indNaN);
        if ~isempty(indNaN) %temporarilty assign 1s to index values, so that the entire matrix computes
            AxyzCtr(indNaN,:)=1;
            N=size(ActrRC,1);
        end

        %Remove NaN's


        % VERGENCE ANGLE AT SAMPLED SCENE POINT
        AVrgCtrDeg = vergenceFromRangeXYZVec(A,IPDm,AxyzCtr);

        % LE AND RE LINES OF SIGHT TO LEFT EYE POINT
        A2AvctLOS = createLine3d(AxyzEye,AxyzCtr);
        A2BvctLOS = createLine3d(BxyzEye,AxyzCtr);

        % INTERSECTION OF PROJECTION PLANE (IPP) W. LINES OF SIGHT TO POINT IN L IMAGE
        A2AxyzIPP = intersectLinePlane(A2AvctLOS,PrjPln); % must be    center of pixel location
        A2BxyzIPP = intersectLinePlane(A2BvctLOS,PrjPln); % may not be center of pixel location


        % -------------------------------------------------------------------------------
        % 3D SAMPLED POINT IN IMAGE B NEAREST THE CORRESPONDING POINT (INDEX,ROW,COL)
        BctrRC=zeros(N,2);
        %BctrRC0=zeros(N,2);

        %FASTEST
        closestY = interp1(AppYm(:,1),AppYm(:,1),A2BxyzIPP(:,2),'nearest','extrap');
        closestX = interp1(AppXm(1,:),AppXm(1,:),A2BxyzIPP(:,1),'nearest','extrap');

        distYperPix=(AppYm(end,end)-AppYm(1,1))/size(AppYm,1);
        BctrRC(:,1)=ceil((closestY./distYperPix)+IszRC(1)/2);

        distXperPix=(AppXm(end,end)-AppXm(1,1))/size(AppXm,2);
        BctrRC(:,2)=ceil((closestX-CxyzEye(1))./distXperPix+IszRC(2)/2);

        ind=(BctrRC(:,1)==0 | BctrRC(:,2)==0);
        BctrRC(ind,1)=1;
        BctrRC(ind,2)=1;


        % CORRESPONDING POINTS MUST HAVE SAME VERTICAL VALUE (i.e. THEY LIE IN AN EPIPOLAR PLANE)
        %
        d=abs(ActrRC(:,1)-BctrRC(:,1));
        badCol=( d <= 15 & d > 0 );
        if sum(badCol)/size(ActrRC,1) > .1
            disp('LRSIcorrespondingPointA2B: WARNING! Significant number of columns being foreced to be the same.');
        end
        BctrRC(badCol,:)=[ActrRC(badCol,1) BctrRC(badCol,2)];
        badCol=d > 101;
        if sum(badCol)/size(ActrRC,1) > .25
            sum(badCol)/size(ActrRC,1)
            disp('Computing CPS: Something may be wrong. Too many vertical locations misalighned')
        end

        %XXX
        %FIND CPs OUTSIDE OF RANGE
        badInd=find(BctrRC(:,2)>IszRC(2) | BctrRC(:,2)<=0 | BctrRC(:,1)>IszRC(1) | BctrRC(:,1)<=0 | badCol);
        BctrRC(badInd,2)=1;
        indNaN=unique([indNaN; badInd]);

        % XYZ OF RE SAMPLED POINT NEAREST THE TRUE CORRESPONDING POINT IN PROJECTION PLANE (in left coordinate frame)
        %BxyzCtr=zeros(N,3);
        sub=[repelem(BctrRC(:,1),3,1),...
             repelem(BctrRC(:,2),3,1),...
             repmat([1;2;3] ,size(BctrRC,1),1)...
            ];
        ind=sub2ind(size(M),sub(:,1),sub(:,2),sub(:,3));

        BxyzCtr = M(ind);
        BxyzCtr = transpose(reshape(BxyzCtr,3,size(BxyzCtr,1)/3));

        %OLD
        %M=bsxfun(@plus,permute(Bxyz,[2,3,1]),BxyzEye);
        %BBxyzCtr=zeros(N,3);
        %for i = 1:N
        %    BBxyzCtr(i,:) = M(BctrRC(i,2),:,BctrRC(i,1)); % + RxyzEye puts BxyzCtr in LE coordinate system
        %end
        %[BBxyzCtr(n,:)  BxyzCtr(n,:)]


        % VERGENCE ANGLE AT SAMPLED SCENE POINT FOR OPPOSITE EYE
        BVrgCtrDeg   = vergenceFromRangeXYZVec(A,IPDm,reshape(BxyzCtr,[N 1 3]));

        % LE AND RE LINES OF SIGHT TO RIGHT EYE POINT
        % R2LvctLOS    = createLine3d(LxyzEye,BxyzCtr);
        % R2RvctLOS    = createLine3d(RxyzEye,BxyzCtr);

        % INTERSECTION OF PROJECTION PLANE (IPP) W. LINES OF SIGHT TO POINT IN R IMAGE
        %B2AxyzIPP    = intersectLinePlane(createLine3d(AxyzEye,BxyzCtr),PrjPln); % must be    center of pixel location
        B2BxyzIPP    = intersectLinePlane(createLine3d(BxyzEye,BxyzCtr),PrjPln); % may not be center of pixel location

        % SAMPLED 3D POINT NEAREST THE CORRESPONDING POINT IN 3D (may not correspond to 3D surface)
        CxyzCtr      = intersectLinesFromPoints(AxyzEye,AxyzCtr,BxyzEye,BxyzCtr,1000);      % 3D coordinates  of   sampled    point
        %CxyzCtr      = intersectionPointVec(AxyzEye,AxyzCtr,BxyzEye,BxyzCtr);      % 3D coordinates  of   sampled    point
        CvrgCtrDeg   = vergenceFromRangeXYZVec(A,IPDm,reshape(CxyzCtr,[N 1 3])); % vergence demand of   sampled    point

        % INTERPOLATED 'TRUE' POINT (if LE and RE sample are on surface, ITP point should be very near to surface)
        CxyzItp      = intersectLinesFromPoints(CxyzEye,CxyzCtr,AxyzCtr,BxyzCtr,1000);      % 3D coordinates  of interpolated point
        %CxyzItp      = intersectionPointVec(CxyzEye,CxyzCtr,AxyzCtr,BxyzCtr);      % 3D coordinates  of interpolated point

        % ERROR CHECKING... INTERPOLATED POINT CANNOT BE NEARER/FARTHER THAN MIN/MAX DISTANCE
        % if CxyzItp(1) < XminXmax(1) || CxyzItp(1) > XminXmax(2) || CxyzItp(3) < ZminZmax(1) || CxyzItp(3) > ZminZmax(2),
        %     CxyzItp = BxyzCtr; disp(['LRSIcorrespondingPointL2R: WARNING! forcing CxyzItp = BxyzCtr']);
        % end

        %% VERGENCE ANGLE
        CvrgItpDeg   = vergenceFromRangeXYZVec(A,IPDm,reshape(CxyzItp,[N 1 3])); % vergence demand of interpolated point


        % INTERSECTION OF PROJECTION PLANE (IPP) W. LINES OF SIGHT FROM LE, RE, CE TO INTERPOLATED CYCLOPEAN POINT
        C2AxyzIPP    = intersectLinePlane(createLine3d(AxyzEye,CxyzItp),PrjPln);
        C2BxyzIPP    = intersectLinePlane(createLine3d(BxyzEye,CxyzItp),PrjPln);
        C2CxyzIPP    = intersectLinePlane(createLine3d(CxyzEye,CxyzItp),PrjPln);


        % LE AND RE IMAGE SHIFTS IN METERS FOR 'TRUE' INTERPOLATED (ITP) POINT TO NULL ERROR IN 3D SAMPLED POINT
        AitpShftXm   = C2AxyzIPP(:,1) - A2AxyzIPP(:,1);
        BitpShftXm   = C2BxyzIPP(:,1) - B2BxyzIPP(:,1);
        CitpShftXm   = C2CxyzIPP(:,1) - A2AxyzIPP(:,1);


        % LE AND RE IMAGE SHIFTS IN PIXELS FOR 'TRUE' INTERPOLATED (ITP) POINT TO NULL ERROR IN 3D SAMPLED POINT
        pixPerMtr    = size(AppXm,2)./diff([AppXm(1) AppXm(end)]);
        AitpShftXpix = AitpShftXm.*pixPerMtr;
        BitpShftXpix = BitpShftXm.*pixPerMtr;
        CitpShftXpix = CitpShftXm.*pixPerMtr;


        % INTERPOLATED LOCATION OF CORRESPONDING POINT (IN PIXELS)
        AitpRC    = ActrRC + [zeros(N,1) AitpShftXpix];
        BitpRC    = BctrRC + [zeros(N,1) BitpShftXpix];
        CitpRC    = ActrRC + [zeros(N,1) CitpShftXpix];


        %% DISPARITY BETWEEN BEST 3D SAMPLED POINT AND BEST INTERPOLATED 3D POINT
        CsmpErrDeg = ( CvrgItpDeg - CvrgCtrDeg );

        % SAMPLED FIXATION DISTANCE (from cyclopean eye
        %CdstErrM   = sqrt(sum(abs((bsxfun(@minus,CxyzItp,CxyzEye)).^2),2));
        %AV30=CdstErrM;

        % VERGENCE DIFFERENCE BETWEEN NEAREST SAMPLED POINTS (SHOULD BE TINY)
        DvrgDffDeg = AVrgCtrDeg - BVrgCtrDeg;

        %AV31=DvrgDffDeg;

        % HANDLE NaN CORRESPONDING POINTS -> 1, changed to NaN in parent function
        if ~isempty(indNaN)
            if bNaNhide == 1
                AitpRC(indNaN,:)=1;
                BitpRC(indNaN,:)=1;
                CitpRC(indNaN,:)=1;
            else
                AitpRC(indNaN,:)=NaN;
                BitpRC(indNaN,:)=NaN;
                CitpRC(indNaN,:)=NaN;
            end
            CsmpErrDeg(indNaN,:) = 100; DvrgDffDeg(indNaN,:) = 100;
        end
    end
end
end
