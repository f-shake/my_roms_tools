project_data
%% 排放清单点位处理
[names,singles,means]=read_emission_table( ...
  projectData.emissionList,3, 'Name',["Type","LonLat"],["FluxPerS","CodMn","TN","TP"]);
pollutionTypes=3;
flux=means(:,1);
types=string(singles(:,1));
[xy,waterPoint,outOfRange]=roms_get_xy_by_lonlat_core(singles(:,2),"",'rho',1,1,enable=1,label=0,style_normal='.g',style_out_of_range='.r');

set(gca,'clipping','on')
for i=1:length(names)
    disp([num2str(i),'   ',char(names(i))])
end


%% 配置河流
configs
configs(length(names)+2,2*pollutionTypes);
roms.rivers.time=0;
months=[31,28,31,30,31,30,31,31,30,31,30,31];
while roms.rivers.time(end)<roms.time.days
    roms.rivers.time(end+1)=months(mod(length(roms.rivers.time)-1,12)+1)+roms.rivers.time(end);
end
roms.rivers.direction=ones(roms.rivers.count,1)*2;
roms.rivers.location=xy;
%为长江增加两个出水口
roms.rivers.location(end+1,:)=[roms.rivers.location(end,1),roms.rivers.location(end,2)-1];
roms.rivers.location(end+1,:)=[roms.rivers.location(end,1),roms.rivers.location(end,2)+2];

mask=ncread(roms.input.grid,'mask_rho');
for i=1:size(roms.rivers.location,1)
    loc=roms.rivers.location(i,:);
    if mask(loc(1)+1,loc(2)+1)==0
        error("点"+num2str(i)+"在陆地上："+num2str(loc))
    end
end
roms.rivers.transport=ones(roms.rivers.count,numel(roms.rivers.time));
cj=[0.49 0.49 0.52 0.65 1.01 1.37 1.60 1.63 1.31 1.05 0.78 0.59];
qt=[0.53  0.76  0.98  1.12  1.55  1.68  1.08  1.18  1.52  0.67  0.47  0.47];
cj=[cj,cj]; qt=[qt,qt];
cj=cj(1:size(roms.rivers.transport,2));
qt=qt(1:size(roms.rivers.transport,2));
for i=1:length(names)
    roms.rivers.transport(i,:)=flux(i);
    if types(i)=="企业"
        roms.rivers.transport(i,:)=roms.rivers.transport(i,:)*1;
    elseif types(i)=="河流"
        if names(i)=="长江"
            %长江径流分配
            %cj=[1.5 1.5 1.6 2 3.1 4.2 4.9 5 4 3.2 2.4 1.8 1.5];
            roms.rivers.transport(i,:)=roms.rivers.transport(i,:).* cj;
        else
            %南方河流径流分配
            roms.rivers.transport(i,:)=roms.rivers.transport(i,:).*qt;
        end
    end
end


roms.rivers.transport(end-2,:)=roms.rivers.transport(end-2,:)/3;
roms.rivers.transport(end-1,:)=roms.rivers.transport(end-2,:);
roms.rivers.transport(end,:)=roms.rivers.transport(end-2,:);

roms.rivers.v_shape=ones(roms.rivers.count,roms.grid.N)/roms.grid.N;
roms.rivers.temp=zeros(roms.rivers.count,roms.grid.N,numel(roms.rivers.time));
roms.rivers.salt=zeros(roms.rivers.count,roms.grid.N,numel(roms.rivers.time));

%% 配置示踪剂
dyes=zeros(pollutionTypes,length(names));
dyes(1,:)=means(:,2);
dyes(2,:)=means(:,3);
dyes(3,:)=means(:,4);

%长江

dyes(:,end+1)=dyes(:,end);
dyes(:,end+1)=dyes(:,end);

for i=1:pollutionTypes
    dye=zeros(roms.rivers.count,roms.grid.N,numel(roms.rivers.time));
    j=0;
    for d=dyes
        j=j+1;
        dye(j,:,:)=dyes(i,j);
    end
    %dye(:,:,10:20)=0;
    roms.rivers.dye{i}=dye;
    roms.rivers.dye{i+pollutionTypes}=dye;
end

%% 创建河流
roms_create_rivers_core(roms)