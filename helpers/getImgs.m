function im=getImgs(varargin)
% getImgs('LRSI','img',{'pht','xyz'},1,'L')
    if nargin > 5
        error('Too many inputs.')
    end
    varargin{6}=1;
    dbI=dbImg(varargin{:});
    im=dbI.im;

    %dbName,dbType,fileType,num,LorR,bSkipDB)
    %I=dbImg(varargin{:});
    %I=db.I;
