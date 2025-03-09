configs;
project_data

table=readtable("C:\Users\autod\OneDrive\大学\污染物模拟\排放清单.xlsx",Sheet=3);
names=unique(table.Name);
s=size(names);
s=s(1);
totalS=size(table);
totalS=totalS(1);
lons=zeros(s,1);
lats=zeros(s,1);
types=strings([s,1]);
for i=1:totalS
    line=table(i,:);
    n1=line.Name{1};
    for j=1:s
        n2=names(j);
        n2=n2{1};
        if isequal(n1,n2)
            lonlats=split(line.LonLat{1},',');
            lons(j)=str2double( lonlats{1});
            lats(j)=str2double( lonlats{2});
            types(j)=line.Type{1};

        end
    end
end

obss=get_observations_of_all(projectData.obsRange(:,1),projectData.obsRange(:,2),2017,3:5);

[lon_rho,lat_rho,mask]=roms_load_grid_rho;
[xy,waterPoint,outOfRange]=roms_get_xy_by_lonlat_core([lons,lats],"",'rho',false,enable=0);
xy=xy(~outOfRange,:);
lons=zeros(size(xy,1),1);
lats=zeros(size(xy,1),1);
for i=1:size(xy,1)
    disp(xy(i,:))
    lons(i)=lon_rho(xy(i,1),xy(i,2));
    lats(i)=lat_rho(xy(i,1),xy(i,2));
end
clf;
pcolorjw(lon_rho,lat_rho,mask);
hold on
scatter(lons,lats,20,'r','filled')
hold on
scatter(obss(:,1),obss(:,2),20,'k','filled')

draw_border
legend(["","排放点","观测点"]);
title("杭州湾沿海排污点及近岸海域水质观测点")
xlabel('经度')
ylabel('纬度')
equal_aspect_ratio(gca)

apply_font