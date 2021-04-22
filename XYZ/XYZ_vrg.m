classdef XYZ_vrg < handle
methods
    function obj=get_vergence(LorRmap, LorRorCcoord)
        k=obj.get_k(LorRmap);
        LorRorCcoord=obj.get_LorR(LorrRorCcoord);

        % HERE
        xyz=xyz{k};
        if k == 1
            xyz=obj.xyz(:,:,1)-obj.db.IPDm;
        elseif k == 2
            xyz=obj.xyz(:,:,1)+obj.db.IPDm;
        end

        IvrgDeg=XYZ.get_vergence(LorRorCcoord, xyz, obj.db.IPDm, obj.db.Ippzm);
    end
    function obj=add_vrg(obj)
        [LitpRCdsp, RitpRCdsp, bIndGdFXN] = add_dsp(LitpRC,RitpRC,vrgArcMin,LppXm,LppYm,RppXm,RppYm,IppZm,IPDm);
    end
end
methods(Static=true)
    function IvrgDeg=get_vergence_f(LorRorCcoord,Ixyz,IPDm,z)
    % get_vergence_f('C',
        LR={'L','R'};
        if LorRorCcoord=='L'
            AExyz  = [0 0 0];
            BExyz = [+IPDm 0 0];
        elseif LorRorCcoord=='R'
            AExyz = [0 0 0];
            BExyz = [-IPDm 0 0];
        elseif LorRorCcoord=='C'
            AExyz = [-IPDm/2 0 0];
            BExyz = [ IPDm/2 0 0];
        end
        B=sqrt(sum(bsxfun(@minus,Ixyz,reshape(BExyz,[1 1 z])).^2,3));

        N=size(Ixyz,1);
        if length(size(Ixyz))==2 && size(Ixyz,2) == 3, Ixyz = reshape(Ixyz,[N 1 3]); end

        if ismember(LorRorR,LR)
            A=sqrt(sum(Ixyz.^2,3));
        else
            A=sqrt(sum(bsxfun(@minus,Ixyz,reshape(AExyz,[1 1 3])).^2,3));
        end

        IvrgDeg = law_of_cosines_SSSd_fun(A, B, IPDm);

        function thetaDeg=law_of_cosines_SSSd_fun(a,b,c)
            thetaDeg = acos( (a.^2 + b.^2 - c.^2)./(2.*a.*b)).*180./pi;
        end
    end
    function [IvrgDeg] = xyz_to_vrg(LorRorC,IPDm,Ixyz)
        % XXX IPDm to LExyz Rxyz

        % function [IvrgDeg] = vergenceFromRangeXYZ(LorRorC,IPDm,Ixyz)
        %
        %   example call: vergenceFromRangeXYZ('L',0.065,Lxyz)
        %
        % vergence angle in the epipolar plane in deg given a range xyz image and an IPDm
        %
        % NOTE! if LorRorC -> 'L' Ixyz is expressed in a coordinate system centered at the LE nodal point
        %       if LorRorC -> 'R' Ixyz is expressed in a coordinate system centered at the RE nodal point
        %       if LorRorC -> 'C' Ixyz is expressed in a coordinate system centered at the CE nodal point
        %
        %            NOTE: If size(Ixyz) = [1 3], automatically resized to [1 1 3]
        %%%%%%%%%%%%%%%%%%%%%%%
        % IvrgDeg:   vergence angle to point

        N=size(Ixyz,1);
        if length(size(Ixyz))==2 && size(Ixyz,2) == 3, Ixyz = reshape(Ixyz,[N 1 3]); end
        if size(Ixyz,3) ~= 3, error(['vergenceFromRangeXYZ: WARNING! size(Ixyz,3) = ' num2str(size(Ixyz,4)) ' instead of 3']); end

        if strcmp(LorRorC,'L')
            LxyzEye = [   0 0 0];
            RxyzEye = [+IPDm 0 0];

        % BINOCULAR ANGLE TO EACH XYZ POINT FOR LEFT  EYE
            IvrgDeg = lawofcosinesSSSd(sqrt(sum(Ixyz.^2,3)), sqrt(sum(bsxfun(@minus,Ixyz,reshape([ IPDm 0 0],[1 1 3])).^2,3)),IPDm  );
        % LangDeg = lawofcosinesSSSd(sqrt(sum(Lxyz.^2,3)), sqrt(sum(bsxfun(@minus,Lxyz,reshape([ IPDm 0 0],[1 1 3])).^2,3)),IPDm  );

        elseif strcmp(LorRorC,'R')
            LxyzEye = [-IPDm 0 0];
            RxyzEye = [    0 0 0];

        % BINOCULAR ANGLE TO EACH XYZ POINT FOR RIGHT EYE
            IvrgDeg = lawofcosinesSSSd(sqrt(sum(Ixyz.^2,3)), sqrt(sum(bsxfun(@minus,Ixyz,reshape([-IPDm 0 0],[1 1 3])).^2,3)),IPDm  );
        % RangDeg = lawofcosinesSSSd(sqrt(sum(Rxyz.^2,3)), sqrt(sum(bsxfun(@minus,Rxyz,reshape([-IPDm 0 0],[1 1 3])).^2,3)),IPDm  );

        elseif strcmp(LorRorC,'C')
            LxyzEye = [-IPDm/2 0 0];
            RxyzEye = [ IPDm/2 0 0];
        % BINOCULAR ANGLE TO EACH XYZ POINT FOR RIGHT EYE
            IvrgDeg = lawofcosinesSSSd(sqrt(sum(bsxfun(@minus,Ixyz,reshape([-IPDm/2 0 0],[1 1 3])).^2,3)), ...
                                    sqrt(sum(bsxfun(@minus,Ixyz,reshape([+IPDm/2 0 0],[1 1 3])).^2,3)),IPDm  );
        % RangDeg = lawofcosinesSSSd(sqrt(sum(Rxyz.^2,3)), sqrt(sum(bsxfun(@minus,Rxyz,reshape([-IPDm 0 0],[1 1 3])).^2,3)),IPDm  );
        else
            error(['vergenceAngleFromRangeXYZ: WARNING! unhandled LorRorC string: ' LorRorC]);
        end

    end
    function [LitpRCdsp, RitpRCdsp, bIndGdFXN] = add_dsp(LitpRC,RitpRC,dspDeg,ILorR,IppXm,IppYm,IppZm,IPDm)
    % XXX change IDPm to LExyz RExyz
    % function [LitpRCdsp, RitpRCdsp, bIndGdFXN] =  LRSIcorrespondingPointAddDisparityExact(LitpRC,RitpRC,dspDeg,LppXm,LppYm,RppXm,RppYm,IppZm,IPDm)
    %
    %   example call:  % ADD UNCROSSED (-) DISPARITY TO SCENE POINT ASSOCIATED W. CORRESPONDING POINTS
    %                  [LitpRCdsp, RitpRCdsp] = LRSIcorrespondingPointAddDisparityExact([144 1677.9],[144 1711.1],-15,LppXm,LppYm,RppXm,RppYm,LRSIprojPlaneDist(),LRSIcameraIPD())
    %
    %                  % ADD  CROSSED  (+) DISPARITY TO SCENE POINT ASSOCIATED W. CORRESPONDING POINTS
    %                  [LitpRCdsp, RitpRCdsp] = LRSIcorrespondingPointAddDisparityExact([144 1677.9],[144 1711.1],+15,LppXm,LppYm,RppXm,RppYm,LRSIprojPlaneDist(),LRSIcameraIPD())
    %
    % WORKS VECTORIZED
    % add disparity to scene point associated with corresponding image points
    % while maintaining cyclopean direction
    % uncrossed disparity (-) makes the target point farther than fixation
    % crossed   disparity (+) makes the target point closer  than fixation
    %
    % LitpRC:    LE corresponding point pixel co-ordinates [ 1 x 2 ]->[ N x 2 ]
    % RitpRC:    RE corresponding point pixel co-ordinates [ 1 x 2 ]->[ N x 2 ]
    % dspDeg: disparity to add (in arcmin)
    %            (-) -> uncrossed disparity
    %            (+) ->   crossed disparity
    % ILorR:     plane using given provided coordinate system
    % IppXm:     x-positions of projection plane samples in metres in ILorR coord system
    % IppYm:     y-positions of projection plane samples in metres in ILorR coord system
    % IppZm:     projection plane distance in metres
    % IPDm:      interpupillary distance in metres
    % LitpRCdsp: LE crop-location pixel co-ordinates w. desired disparity
    % RitpRCdsp: RE crop-location pixel co-ordinates w. desired disparity
    % bIndGdFXN: boolean indicating if the fixation point is ahead of the eyes
    %            1 -> Fixation point is in front of the eyes
    %            0 -> Fixation point is behind      the eyes (BAD POINT)

        if abs(LitpRC(1)-RitpRC(1)) ~= 0
            warning('LRSIcorrespondingPointAddDisparityExact: Warning! LE and RE images are at different elevations. Check corresponding point');
            disp(num2str(LitpRC(1)-RitpRC(1)));
        end

        if ILorR=='L'
            LppXm=IppXm;
            LppYm=IppYm;

            RppXm=LppXm-IPDm;
            RppYm=IppYm;
        elseif ILorR=='R'
            RppXm=IppXm;
            RppYm=IppYm;

            LppXm=RppXm+IPDm;
            LppYm=IppYm;
        elseif ILorR=='C'
            LppXm=IppXm+IPDm/2;
            RppXm=IppXm-IPDm/2;
            RppYm=IppYm;
            LppYm=IppYm;
        end

        % XY LOCATION IN METERS OF LE AND RE CORRESPONDING IMAGE POINTS
        % LEFT-EYE
        LitpXYm(:,1) = interp1(1:size(LppXm,2),LppXm(1,:),LitpRC(:,2));
        LitpXYm(:,2) = interp1(1:size(LppYm,1),LppYm(:,1),LitpRC(:,1));
        % RIGHT-EYE
        RitpXYm(:,1) = interp1(1:size(RppXm,2),RppXm(1,:),RitpRC(:,2));
        RitpXYm(:,2) = interp1(1:size(RppYm,1),RppYm(:,1),RitpRC(:,1));

        % ERROR CHECKING
        % if abs(LitpXYm(2)-RitpXYm(2)) ~= 0, error('LRSIcorrespondingPointAddDisparity: Warning! LE and RE images are at different elevations. Check corresponding point'); end

        % XY LOCATION IN METERS OF LE AND RE CORRESPONDING IMAGE POINTS IN CYCLOPEAN EYE COORDINATE SYSTEM
        LitpXYmC = [LitpXYm(:,1)-(IPDm/2), LitpXYm(:,2)];
        RitpXYmC = [RitpXYm(:,1)+(IPDm/2), RitpXYm(:,2)];

        % CYCLOPEAN CO-ORDINATES OF INITIAL TARGET POSITION IN 3-SPACE (USING INTERSECTION POINT)
        tgtXYZm  = intersectLinesFromPoints([ -(IPDm/2), 0 , 0 ],[ LitpXYmC(:,1), LitpXYmC(:,2), repmat(IppZm,size(LitpXYmC,1),1)],[ +(IPDm/2), 0 , 0 ],[ RitpXYmC(:,1), RitpXYmC(:,2), repmat(IppZm,size(LitpXYmC,1),1)]);
        tgtXm    = tgtXYZm(:,1);
        tgtYm    = tgtXYZm(:,2);
        tgtZm    = tgtXYZm(:,3);

        % DISPLAY CARTESIAN COORDINATES OF INITIAL FIXATION POSITION
        %  display(['LRSIcorrespondingPointAddDisparityExact: Fixation location in 3-space: [' num2str(tgtXYZm,'%.2f') '] in meters']);

        % CALCULATE ELEVATION ANGLE
        tgtElevDeg = atand(tgtYm./tgtZm);

        %% REPORT IF INITIAL TARGET POSITION IS 'OUT-OF-RANGE'
        bIndGdFXN = 1;  % SET bIndGdFXN = 1 BY DEFAULT

        % CHECK FOR CL BEYOND INFINITY %
        if dspDeg > 0  % ONLY A POSSIBILITY FOR CROSSED DISPARITIES
        tgtDstMtr = sqrt(sum(tgtXYZm.^2));
        maxDstMtr = (IPDm./2)/(tand((dspDeg)./2));
        % FLAG CASES WHERE FIXATION POINT IS BEHIND THE EYE
            if tgtDstMtr >= maxDstMtr
                bIndGdFXN = 0;
                % disp(['LRSIcorrespondingPointAddDisparityExact: Warning! Target distance = ', num2str(tgtDstMtr) ' m. For disparity ' num2str(dspArcMin) ' arcmin distance for parallel gaze is ' num2str(maxDstMtr) ' m. Fixation point will be behind the eyes' ]);
            end
        end

        %% TAKES INITIAL TARGET POSITION, MOVES TO ADD REQUIRED VERGENCE DEMAND AND RETURNS CYCLOPEAN CO-ORDINATES OF LE AND RE IMAGES
        % DISPARITY TO ADD IN DEGREE

        % VERGENCE OF INITIAL TARGET POSITION (IN EPIPOLAR PLANE)
        vrgCPdeg   = acosd((tgtXm.^2 + tgtYm.^2 + tgtZm.^2 - (IPDm./2).^2)./((sqrt((tgtXm + (IPDm./2)).^2 + tgtYm.^2 + tgtZm.^2)).*(sqrt((tgtXm - (IPDm./2)).^2 + tgtYm.^2 + tgtZm.^2))));

        % VERSION ANGLE OF INITIAL TARGET POSITION (IN EPIPOLAR PLANE)
        vrsCPdeg = -sign(tgtXm).*acosd(sqrt((tgtYm.^2 + tgtZm.^2)./(tgtXm.^2 + tgtYm.^2 + tgtZm.^2)));

        % TOLERANCE FOR CHECKING IF THE VERSION ANGLE  IS CLOSE TO ZERO
        tolVrsDeg = 0.001;
        tolVrgDeg = 1/60;

        % CYLOPEAN  XY CO-ORDINATES OF MOVED TARGET IMAGE (IN THE ORIGINAL SPACE)

        if abs(vrgCPdeg - dspDeg) < tolVrgDeg                                                                 % DEALS WITH CASE OF PARALLEL GAZE
            % IF GAZE IS PARALLEL, IMAGE PLANE CO-ORDINATES ARE OBTAINED WITHOUT SOLVING FOR THE NEW FIXATION-POINT CO-ORDINATES IN 3-SPACE
            LitpXYmCdsp = [ -(IPDm./2) - (IppZm./cosd(tgtElevDeg)).*tand(vrsCPdeg), LitpXYmC(:,2)];
            RitpXYmCdsp = [ +(IPDm./2) - (IppZm./cosd(tgtElevDeg)).*tand(vrsCPdeg), RitpXYmC(:,2)];
        else % DEALS WITH CASE WHERE FIXATION LOCATION IS AT FINITE RANGE
            if abs(vrsCPdeg)<tolVrsDeg % ZERO VERSION ANGLE IN EPIPOLAR PLANE
                XclTrnsMtr = 0;
                ZclTrnsMtr = (IPDm./2)./(tand((vrgCPdeg - dspDeg)./2));
            else    % NONZERO VERSION ANGLE IN EPIPOLAR PLANE
                if bIndGdFXN == 1
                    % TARGET AHEAD OF THE EYES IN THE EPIPOLAR PLANE
                    ZclTrnsMtr = ((cosd(vrsCPdeg)).^2).*(IPDm./2).*( cotd(vrgCPdeg - dspDeg) + sqrt( (cotd(vrgCPdeg - dspDeg)).^2+(secd(vrsCPdeg)).^2 ) ); % POSITIVE ROOT IS CHOSEN OF THE QUADRATIC IN ZclTrnsMtr
                elseif bIndGdFXN == 0
                    % TARGET BEHIND THE EYES IN THE EPIPOLAR PLANE
                    ZclTrnsMtr = ((cosd(vrsCPdeg)).^2).*(IPDm./2)*( cotd(vrgCPdeg - dspDeg) - sqrt( (cotd(vrgCPdeg - dspDeg)).^2+(secd(vrsCPdeg)).^2 ) ); % NEGATIVE ROOT IS CHOSEN OF THE QUADRATIC IN ZclTrnsMtr
                end
                XclTrnsMtr = -tand(vrsCPdeg).*ZclTrnsMtr;
            end
            %IMAGE PLANE INTERSECTION XY CO-ORDINATES FOR TARGET IN FRONT
            LitpXYmCdsp = [ -(IPDm./2) + (IppZm./(ZclTrnsMtr.*cosd(tgtElevDeg))).*(XclTrnsMtr + (IPDm./2))  , LitpXYmC(:,2)];
            RitpXYmCdsp = [ +(IPDm./2) + (IppZm./(ZclTrnsMtr.*cosd(tgtElevDeg))).*(XclTrnsMtr - (IPDm./2))  , RitpXYmC(:,2)];
        end

        %% TAKES CYCLOPEAN XY IMAGE CO-ORDINATES AND RETURNS LE AND RE IMAGE CO-ORDINATES FOR THE REQUIRED EYE
        LitpXYmDsp = LitpXYmCdsp + [+(IPDm/2),0];
        RitpXYmDsp = RitpXYmCdsp + [-(IPDm/2),0];

        %% TAKES LE AND RE IMAGE PLANE CO-ORDINATES IN METERS AND RETURNS PIXEL CO-ORDINATES
        LitpRCdsp(:,1) = interp1(LppYm(:,1),1:size(LppYm,1),LitpXYmDsp(:,2));
        LitpRCdsp(:,2) = interp1(LppXm(1,:),1:size(LppXm,2),LitpXYmDsp(:,1));
        RitpRCdsp(:,1) = interp1(RppYm(:,1),1:size(RppYm,1),RitpXYmDsp(:,2));
        RitpRCdsp(:,2) = interp1(RppXm(1,:),1:size(RppXm,2),RitpXYmDsp(:,1));

    end
    function [vrgDeg,vrsDeg]=get_vrg_vrs_map(xyz,LExyz,RExyz)
        % XXX should I use xyz2vrgVrs code?
        % get_vrg_vrs_map(xyz, LExyz, RExyz)
        %if ndimsSane(xyz)==2 && size(xyz,2)==3

        CExyz=(LExyz+RExyz)./2;
        IPDm=sqrt(sum(RExyz-LExyz,2).^2);
        I=IPDm/2;
        %%%%
        L=sqrt(sum(xyz-LExyz,2).^2);
        R=sqrt(sum(xyz-RExyz,2).^2);
        C=sqrt(sum(xyz-CExyz,2).^2);

        vrgDeg=acosd((L.^2+R.^2-IPDm)./(2.*L.*R));

        rdeg=acosd((I.^2+R.^2-C.^2)./(2.*I.*R));
        ldeg=180-vrgDeg-rdeg;
        cdeg=asind(R.*sind(rdeg)./C);

        vrsDeg=cell(1,3);
        vrsDeg{1}=90-ldeg;
        v1=vrsDeg{1}(ldeg > 90);
        if ~isempty(v1)
            vrsDeg{1}(ldeg > 90)=v1.*-1;
        end

        vrsDeg{3}=90-cdeg;
        v3=vrsDeg{1}(cdeg > 90);
        if ~isempty(v3)
            vrsDeg{3}(cdeg > 90)=v3.*-1;
        end

        vrsDeg{2}=90-rdeg;
        v2=vrsDeg{2}(rdeg <= 90);
        if ~isempty(v2)
            vrsDeg{2}(ldeg <= 90)=v2.*-1;
        end
        %%%%
    end
    function z=vrg_vrs_map_to_xyz(vrgDeg,vrsDeg,LExyz,RExyz)
        % XXX is version defined correctly here?
        IPDm=sqrt(sum(RExyz-LExyz,2).^2);

        C=acotd(2*tand(vrs));
        L=-1*vrgDeg + C; %left angle
        R=180-vrgDeg-L;                       %right angle
        s=sind(L)*IPDm/sind(vrgDeg);          %solve for one side
        z=sind(R)*s;

    end
end
end
