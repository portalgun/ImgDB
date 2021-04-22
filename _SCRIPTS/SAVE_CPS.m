database='LRSI';

db=dbInfo(database);
p=pr(length(db.allImages),1,'Generating and saving CPLOOKUP');
for i = db.allImage
    p.u();
    xyz=XYZ(database,i);
    xyz.gen_CPs_all_bi();
    xyz.save_CPs_all();
end
p.c();
