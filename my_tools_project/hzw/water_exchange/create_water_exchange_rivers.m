%% 排放清单点位处理
[names,singles,means]=read_emission_table( ...
    "C:\Users\autod\OneDrive\大学\污染物模拟\排放清单.xlsx",3, ...
    'Name',["Type","LonLat"],["FluxPerS"]);
pollutionTypes=3;
flux=means(:,1);
lonlats=singles(:,2);
types=string(singles(:,1));
f=types=="河流"&flux>100;
%f=names=="长江";
names=names(f);
flux=flux(f);
lonlats=lonlats(f);

[xy,waterPoint,outOfRange]=roms_get_xy_by_lonlat_core(lonlats,"",'rho',1,1,enable=1,label=0,style_normal='.g',style_out_of_range='.r');

set(gca,'clipping','on')
for i=1:length(names)
    disp([num2str(i),'   ',char(names(i))])
end


%% 配置河流
configs
configs(length(names)+2,1);
roms.rivers.time=0:30:360;
roms.rivers.direction=ones(roms.rivers.count,1)*2;
roms.rivers.location=xy;
%为长江增加两个出水口
roms.rivers.location(end+1,:)=[0,167];
roms.rivers.location(end+1,:)=[0,168];

mask=ncread(roms.input.grid,'mask_rho');

roms.rivers.transport=ones(roms.rivers.count,numel(roms.rivers.time));
for i=1:length(names)
    roms.rivers.transport(i,:)=flux(i);
%     if names(i)=="长江"
%         %长江径流分配
%         cj=[1.5 1.5 1.6 2 3.1 4.2 4.9 5 4 3.2 2.4 1.8 1.5];
%         roms.rivers.transport(i,:)=roms.rivers.transport(i,:).*cj./sum(cj).*12./3;
%     else
%         %南方河流径流分配
%         roms.rivers.transport(i,:)=roms.rivers.transport(i,:).*[0.53  0.76  0.98  1.12  1.55  1.68  1.08  1.18  1.52  0.67  0.47  0.47 0.53];
%     end
end



%为长江增加两个出水口
roms.rivers.transport(end-2,:)=roms.rivers.transport(end-2,:)/3;
roms.rivers.transport(end-1,:)=roms.rivers.transport(end-2,:);
roms.rivers.transport(end,:)=roms.rivers.transport(end-2,:);

roms.rivers.v_shape=ones(roms.rivers.count,roms.grid.N)/roms.grid.N;
roms.rivers.temp=zeros(roms.rivers.count,roms.grid.N,numel(roms.rivers.time));
roms.rivers.salt=zeros(roms.rivers.count,roms.grid.N,numel(roms.rivers.time));
roms.rivers.dye=cell(1,1);
roms.rivers.dye{1}=zeros(roms.rivers.count,roms.grid.N,length(roms.rivers.time));

%% 创建河流
roms_create_rivers_core(roms)