function add_ini_bdy_tracer(file,traceData)
    configs
    configs(traceData.pointPerPart*traceData.partCount,(traceData.partCount+1)*traceData.repeat);
    d=1;
    for i=traceData.partCount+1:traceData.partCount+1:roms.tracer.count
        roms.tracer.east{i}(:)=d;
        roms.tracer.north{i}(:)=d;
        roms.tracer.south{i}(:)=d;
        roms.tracer.west{i}(:)=d;
        disp("已为编号为"+num2str(i)+"的dye添加了边界强迫")
    end

    if ~isempty(file)
        roms.tracer.densities={};
        for i=1:roms.tracer.count
            try
                [dye,name]=roms_get_dye(file,i);
                disp("已读取并写入"+name);
            catch
                error("找不到编号为"+num2str(i)+"的dye");
            end
            dye=dye(:,:,:,end);
            dye(isnan(dye))=0;
            roms.tracer.densities{i}=dye;
        end
    end
    roms_add_passive_tracer_core(roms);