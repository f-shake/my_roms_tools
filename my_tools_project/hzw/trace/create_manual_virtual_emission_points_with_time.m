function create_manual_virtual_emission_points_with_time(gridFile)
    arguments
        gridFile(1,1) string %使用C#生成的网格文件的位置
    end
    clf
    configs
    project_data
    configs(traceData.pointPerPart*traceData.partCount,(traceData.partCount+1)*traceData.repeat);

    input=readmatrix(gridFile,FileType='text');
    input=fliplr(input');

    points=struct([]);
    index=0;
    simFluxs=traceData.simFluxs;
    for i=1:size(input,1)
        for j=1:size(input,2)
            value=input(i,j);
            if value>0 && value<=traceData.partCount
                index=index+1;
                points(index).x=i;
                points(index).y=j;
                points(index).partIndex=value;
                points(index).pointIndex=length(points([points.partIndex]==value));
                points(index).transport=simFluxs(:,value)/traceData.pointPerPart;
            end
        end
    end

    for i=1:traceData.partCount
        if(length(points([points.partIndex]==i))~=traceData.pointPerPart)
            error(['第',num2str(i),'部分内的点数量不符合配置'])
        end
    end
    xy=[[points.x]',[points.y]'];

    roms.rivers.time=0:31:12*31;
    roms.rivers.direction=ones(roms.rivers.count,1)*2;
    roms.rivers.location=xy;

    roms.rivers.transport=[points.transport]';

    roms.rivers.v_shape=ones(roms.rivers.count,roms.grid.N)/roms.grid.N;
    roms.rivers.temp=zeros(roms.rivers.count,roms.grid.N,numel(roms.rivers.time));
    roms.rivers.salt=zeros(roms.rivers.count,roms.grid.N,numel(roms.rivers.time));
    for i=1:(traceData.partCount+1)*traceData.repeat
        roms.rivers.dye{i}=zeros(roms.rivers.count,roms.grid.N,numel(roms.rivers.time));
    end

    for i=1:length(points)
        point=points(i);
        for j=1:traceData.repeat
        roms.rivers.dye{point.partIndex+(traceData.partCount+1)*(j-1)}(i,:,:)=1;
        end
    end

    roms_create_rivers_core(roms,1)

    [lon,lat]=roms_load_grid_rho;
    pcolorjw(lon,lat,input);
    hold on
    for i=xy'
        plot(lon(i(1),i(2)),lat(i(1),i(2)),'.w');
    end
