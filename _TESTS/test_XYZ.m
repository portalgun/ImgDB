% test_XYZ

xyz=XYZ('LRSI',8);
xyz.get_cpLookup_bi;
%
close all
pht=getImg('LRSI','img','pht',8);

xs=size(pht{1},2);
sz=size(pht{1});
ind=randi(size(xyz.cpLookup{1},1),100,1);

x1=[xyz.CPs{1}{1}(ind,2)];
x2=[xyz.CPs{1}{2}(ind,2)]+xs;
y1=[xyz.CPs{1}{1}(ind,1)];
y2=[xyz.CPs{1}{2}(ind,1)];

figure(1)
imagesc([pht{1}.^.4 pht{2}.^.4]); hold on
formatImage();
plot(x1,y1,'r.')
plot(x2,y2,'y.')

x1=[xyz.CPs{2}{1}(ind,2)];
x2=[xyz.CPs{2}{2}(ind,2)]+xs;
y1=[xyz.CPs{2}{1}(ind,1)];
y2=[xyz.CPs{2}{2}(ind,1)];

figure(2)
imagesc([pht{1}.^.4 pht{2}.^.4]); hold on
formatImage();
plot(x1,y1,'r.')
plot(x2,y2,'y.')

% ------
%
[y1,x1]=ind2sub(sz,ind)
x2=[xyz.cpLookup{1}(ind,2)+xs];
y2=[xyz.cpLookup{1}(ind,1)];

figure(3)
imagesc([pht{1}.^.4 pht{2}.^.4]); hold on
formatImage();
plot(x1,y1,'r.')
plot(x2,y2,'y.')

[y1,x1]=ind2sub(sz,ind)
x1=x1+xs;
%x2=[xyz.cpLookup{2}(ind,2)+xs];
x2=[xyz.cpLookup{2}(ind,2)];
y2=[xyz.cpLookup{2}(ind,1)];

figure(4)
imagesc([pht{1}.^.4 pht{2}.^.4]); hold on
formatImage();
plot(x1,y1,'r.')
plot(x2,y2,'y.')
%GETCPLOOKPUP
