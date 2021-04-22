database='LRSI';

db=dbInfo(database);
p=pr(length(db.allImages),1,'Generating and saving CPLOOKUP');
for i = db.allImages
    p.u();

    xyz=XYZ(database,i);
    xyz.save_cpLookup_all();
end
p.c();
