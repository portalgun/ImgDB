classdef XYZ_project < handle
methods
    function obj=get_itpXYZ_all_bi(obj)
        obj.get_CPs_all_bi(); % XXX if empty
        obj.get_itpXYZ_bi();
        % XXX
        %obj.imagesc_itpXYZ();
    end
    function obj=get_itpXYZ_bi(obj)
        obj.itpXYZ{1}=obj.get_itpXYZ(obj.CPs{1}{1},obj.CPs{1}{2});
        obj.itpXYZ{2}=obj.get_itpXYZ(obj.CPs{2}{1},obj.CPs{2}{2});
    end
    function itpXYZ=get_itpXYZ(obj,LitpRC,RitpRC)
        CppXm=obj.db.IppXm{3};
        CppYm=obj.db.IppYm{3};

        % CONVERT CORRESPONDING POINTS TO METERS IN CYCLOPIAN XY
        LitpXYZ = [interp1(CppXm(1,:),LitpRC(:,2)) interp1(transpose(CppYm(:,1)), LitpRC(:,1)) obj.db.IppZm.*ones(size(LitpRC,1),1)];
        RitpXYZ = [interp1(CppXm(1,:),RitpRC(:,2)) interp1(transpose(CppYm(:,1)), RitpRC(:,1)) obj.db.IppZm.*ones(size(LitpRC,1),1)];

        % FIND CYCLOPIAN SCENE COORDINATES OF POINTS BY TRACING FROM EYES THROUGH CORRESPONDING POINTS
        itpXYZ = intersectLinesFromPoints(obj.db.LExyz,LitpXYZ,obj.db.RExyz,RitpXYZ);
        itpXYZ = reshape(itpXYZ,obj.db.IszRC(2),obj.db.IszRC(1),3);
        itpXYZ = permute(itpXYZ,[2 1 3]);
    end
end
methods(Static=true)
    function pointsXYZ=forward_project(LExyz,RExyz,PPxyL,PPxyR,IppXm,IppYm,IppZm,X,Y)
        % pixels to scen points
        n=size(PPxyL,1);
        LExyz=repmat(LExyz,n,1);
        RExyz=repmat(RExyz,n,1);
        %[LExyz,RExyz]=obj.get_eye_vec(obj.db,n);


        PPxyLM=zeros(size(PPxyL));
        PPxyRM=zeros(size(PPxyR));
        [PPxyLM(:,1),PPxyLM(:,2)]=XYZ.imgInterp2(X,Y,IppXm,IppYm,PPxyL(:,1),PPxyL(:,2));
        [PPxyRM(:,1),PPxyRM(:,2)]=XYZ.imgInterp2(X,Y,IppXm,IppYm,PPxyR(:,1),PPxyR(:,2));

        Z=repmat(IppZm,n,1);
        PPxyzLM=[PPxyLM Z];
        PPxyzRM=[PPxyRM Z];

        pointsXYZ=intersectLinesFromPoints(LExyz,PPxyzLM,RExyz,PPxyzRM);
    end
    function [PPxyL,PPxyR]=back_project(LExyz,RExyz,pointsXYZ,IppXm,IppYm,IppZm,X,Y)
    %% scene points to pixels
        n=size(pointsXYZ,1);
        LExyz=repmat(LExyz,n,1);
        RExyz=repmat(RExyz,n,1);

        Lline=createLine3d(LExyz,pointsXYZ);
        Rline=createLine3d(RExyz,pointsXYZ);
        plane=createPlane([1 0 IppZm],[0 1 IppZm],[0 -1 IppZm]);

        PPxyzLM=intersectLinePlane(Lline,plane);
        PPxyzRM=intersectLinePlane(Rline,plane);

        PPxyL=zeros(size(PPxyzLM,1),2);
        PPxyR=zeros(size(PPxyzRM,1),2);

        [PPxyL(:,1),PPxyL(:,2)]=XYZ.revImgInterp2(IppXm,IppYm,X,Y,PPxyzLM(:,1),PPxyzLM(:,2));
        [PPxyR(:,1),PPxyR(:,2)]=XYZ.revImgInterp2(IppXm,IppYm,X,Y,PPxyzRM(:,1),PPxyzRM(:,2));

    end
    function xyzM=interp(PPxy,IppXm,IppYm)
        xyzM=XYZ.imgInterp2(IppXm,IppYm,X,Y,PPxy(:,1),PPxy(:,2));
    end
    %function PPxy=revInterp(xyzM,IppXm,IppYm,X,Y)
    %    PPxy=XYZ.revImgInterp2(IppXm,IppYm,X,Y,xyzM(:,1),xyzM(:,2));
    %end
    function [Xitp,Yitp]=revImgInterp2(Xm,Ym,X,Y,Vxm,Vym)
        % XXX CHECK MINUS -0.5
        %ind=size(X,2)/2
        %X(1,ind)
        %X(1,ind+1)
        if ndimsSane(Vxm)==1
            Xitp=interp1(Xm(1,:),X(1,:)-0.5,Vxm,'linear');
            Yitp=interp1(Ym(:,1),Y(:,1)-0.5,Vym,'linear');
        else
            Xitp=interp2(Xm,Ym,X(:)-0.5,Vxm,Vym,'linear');
            Yitp=interp2(Xm,Ym,Y(:)-0.5,Vxm,Vym,'linear');
        end
    end
    function [Xitp,Yitp]=imgInterp2(X,Y,Xm,Ym,Vx,Vy)

    % X Y in pixels
    % Ym Xm is meters projection plane
    %
        if ndimsSane(Vx)==1
            Xitp=interp1(X(1,:),X(1,:),Vx,'linear');
            Yitp=interp1(Y(:,1),Y(:,1),Vy,'linear');
        else
            Xitp=interp2(X,Y,Xm(:),Vx,Vy,'linear');
            Yitp=interp2(X,Y,Ym(:),Vx,Vy,'linear');
        end
    end


end
end
