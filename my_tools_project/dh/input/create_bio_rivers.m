project_data

%% 排污口
% input=readmatrix("outlets.grd",FileType='text');
% input=fliplr(input');
%
% outlets=struct([]);
% index=0;
% for i=1:size(input,1)
%     for j=1:size(input,2)
%         value=input(i,j);
%         if value>0 && value<255
%             index=index+1;
%             outlets(index).x=i;
%             outlets(index).y=j;
%             outlets(index).partIndex=value;
%         end
%     end
% end
outlets=struct([]);
index=0;
[lon_rho,lat_rho,mask_rho]=roms_load_grid_rho;
for i=1:size(lon_rho,1) %扫描每一行
    for j=2:size(lon_rho,2) %从左往右扫描每一行的每一个网格
        if mask_rho(1,i)==1
            continue
        end
        if mask_rho(j,i)==1 && mask_rho(j-1,i)==0 %当前网格是水，左侧是陆
            index=index+1;
            outlets(index).x=j;
            outlets(index).y=i;
            if lat_rho(j,i)>31.7
                outlets(index).partIndex=1;
            elseif lat_rho(j,i)>30.7
                outlets(index).partIndex=2;
            elseif lat_rho(j,i)>27.2
                outlets(index).partIndex=3;
            else
                outlets(index).partIndex=4;
            end
            break
        end
    end
end

outletCount=length(outlets);
%outletTransports=[2.713089802,8.750951294,64.12385845,60.17535515];
outletPerTypeCount=zeros(max([outlets.partIndex]),1);
for i=1:outletCount
    index=outlets(i).partIndex;
    outletPerTypeCount(index)=outletPerTypeCount(index)+1;
end

%% 河流位置
rivers=bioData.rivers;

[riversXY,waterPoint,outOfRange]=roms_get_xy_by_lonlat_core(rivers(:,1:2),"",'rho',1,1,enable=1,label=0,style_normal='.g',style_out_of_range='.r');

set(gca,'clipping','on')
riverCount=size(rivers,1);
count=riverCount+outletCount;
outletsXY=[[outlets.x]',[outlets.y]'];
for i=1:outletCount
    xy=outletsXY(i,:);
    x=lon_rho(xy(1),xy(2));
    y=lat_rho(xy(1),xy(2));
    plot(x,y,'om')
    text(x+0.1,y,string(outlets(i).partIndex))
end
xy=[riversXY;outletsXY-1];
for i=1:count
    loc=xy(i,:);
    if mask_rho(loc(1)+1,loc(2)+1)==0
        plot(lon_rho(loc(1)+1,loc(2)+1),lat_rho(loc(1)+1,loc(2)+1),'xr')
        error("点"+num2str(i)+"在陆地上："+num2str(loc))
    end
end

%% 配置河流
configs(count,1);
roms.rivers.time=0;
months=[31,28,31,30,31,30,31,31,30,31,30,31];
while roms.rivers.time(end)<roms.time.days
    roms.rivers.time(end+1)=months(mod(length(roms.rivers.time)-1,12)+1)+roms.rivers.time(end);
end
roms.rivers.direction=ones(count,1)*2;
roms.rivers.location=xy;
%TODO
