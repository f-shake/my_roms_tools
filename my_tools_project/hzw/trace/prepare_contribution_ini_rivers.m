function prepare_contribution_ini_rivers(traceGridFile)
    project_data
    configs
    configs(traceData.pointPerPart*traceData.partCount,traceData.partCount);

    roms_add_passive_tracer_core(roms);

    create_manual_virtual_emission_points_with_time(traceGridFile)

    for i=1:traceData.partCount
        dye=ncread(roms.input.rivers,['river_dye_',num2str(i,'%02d')]);
        dye(:)=1;
        ncwrite(roms.input.rivers,['river_dye_',num2str(i,'%02d')],dye)
    end