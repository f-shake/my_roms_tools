clear
clc
clf

pointPerPart=10; %每个排放部分分成多少个排放口
partsCount=8;
parts=zeros(partsCount,5); %X1,Y1,X2,Y2,流量
pointsCountPerPart=10;
parts(1,:)=[120.499,32.038,120.764,31.998,30166]; %长江
parts(2,:)=[121.773,31.196,121.944,30.927,100]; %上海北
parts(3,:)=[121.851,30.929,121.385,30.848,100]; %上海南
parts(4,:)=[121.245,30.741,120.950,30.590,100]; %嘉兴南
parts(5,:)=[120.499,30.391,120.665,30.384,1200]; %钱塘江
parts(6,:)=[120.872,30.169,121.136,30.300,100]; %绍兴北
parts(7,:)=[121.276,30.327,121.602,30.006,100]; %慈溪镇海北
parts(8,:)=[121.993,29.982,122.323,29.906,100]; %舟山



%用户输入结束
points=struct([]);
lonlats=zeros(partsCount*pointsCountPerPart,2);
transports=zeros(partsCount*pointsCountPerPart);
for i=1:partsCount 
    stepX=(parts(i,3)-parts(i,1))/(pointsCountPerPart-1);
    stepY=(parts(i,4)-parts(i,2))/(pointsCountPerPart-1);
    for j=1:pointsCountPerPart
        index=(i-1)*pointsCountPerPart+j;
        points(index).x=parts(i,1)+stepX*(j-1);
        points(index).y=parts(i,2)+stepY*(j-1);
        points(index).partIndex=i;
        points(index).pointIndex=j;
        points(index).transport=parts(i,5)/pointsCountPerPart;

        %lonlats((i-1)*pointsCountPerPart+j,:)=[points(i,j).x,points(i,j).y];
        %transports((i-1)*pointsCountPerPart+j)=points(i,j).transport;
    end
end


xy=roms_get_xy_by_lonlat_core([[points.x]',[points.y]'],"",'rho',1,1,1);


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

roms_create_rivers_core(roms)
