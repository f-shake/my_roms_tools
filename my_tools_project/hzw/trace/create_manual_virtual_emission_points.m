clear
clc
clf

pointPerPart=10; %每个排放部分分成多少个排放口
partsCount=8;
parts=zeros(partsCount,5); %X1,Y1,X2,Y2,流量
pointsCountPerPart=10;
flux=[30166,100,100,100,1403,100,100,100];
filename="C:\Users\autod\OneDrive\大学\20221111\4.grd";

%用户输入结束
input=readmatrix(filename,FileType='text');
input=fliplr(input');

points=struct([]);
index=0;
for i=1:size(input,1)
    for j=1:size(input,2)
        value=input(i,j);
        if value>0 && value<=partsCount
            index=index+1;
            points(index).x=i;
            points(index).y=j;
            points(index).partIndex=value;
            points(index).pointIndex=length(points([points.partIndex]==value));
            points(index).transport=flux(value)/pointsCountPerPart;
        end
    end
end

for i=1:8
    if(length(points([points.partIndex]==i))~=pointsCountPerPart)
        error(['第',num2str(i),'部分内的点数量不符合配置'])
    end
end
xy=[[points.x]',[points.y]'];

configs
roms.rivers.count=pointPerPart*partsCount;
roms.rivers.time=[0,roms.time.days+1];
roms.rivers.direction=ones(roms.rivers.count,1)*2;
roms.rivers.location=xy;

roms.rivers.transport=repmat([points.transport]',1,length(roms.rivers.time));

roms.rivers.v_shape=ones(roms.rivers.count,roms.grid.N)/roms.grid.N;
roms.rivers.temp=zeros(roms.rivers.count,roms.grid.N,numel(roms.rivers.time));
roms.rivers.salt=zeros(roms.rivers.count,roms.grid.N,numel(roms.rivers.time));

for i=1:roms.tracer.count
    roms.rivers.dye{i}=zeros(roms.rivers.count,roms.grid.N,numel(roms.rivers.time));
end

for i=1:length(points)
    point=points(i);
    roms.rivers.dye{point.partIndex}(i,:,:)=1;
end

roms_create_rivers_core(roms,1)


lon=ncread(roms.input.grid,'lon_rho');
lat=ncread(roms.input.grid,'lat_rho');
mask=ncread(roms.input.grid,'mask_rho');
pcolorjw(lon,lat,input);
hold on
for i=xy'
    plot(lon(i(1),i(2)),lat(i(1),i(2)),'sw');
end
