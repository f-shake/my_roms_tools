ini=1;
rivers=0;
bdy=0;
clm=0;
clearCache=0;


configs

if clearCache
    global dataCache;
    dataCache=[];
end
time='ocean_time'; coord='lon_rho lat_rho s_rho ocean_time';
type='rho';
times=roms.time.start_julian+(0:366/12:366);
vars=get_all_biology_var_info;
if ini
    if exist(roms.input.initialization,'file')
        delete(roms.input.initialization);
    end
    copyfile(roms.input.initialization_raw,roms.input.initialization);
end


if bdy
    if exist(roms.input.boundary_biology,'file')
        delete(roms.input.boundary_biology)
    end
    info=ncinfo(roms.input.boundary);

    info.Dimensions(arrayfun(@(x) endsWith(x.Name, 'time'), info.Dimensions)) = [];
    info.Variables(arrayfun(@(x) endsWith(x.Name, 'time'), info.Variables)) = [];
    info.Variables(arrayfun(@(x) endsWith(x.Name, 'st'), info.Variables)) = [];
    info.Variables(arrayfun(@(x) endsWith(x.Name, 'th'), info.Variables)) = [];

    ncwriteschema(roms.input.boundary_biology,info);
end


if clm
    if exist(roms.input.climatology_biology,'file')
        delete(roms.input.climatology_biology)
    end
    info=ncinfo(roms.input.climatology);

    info.Dimensions(arrayfun(@(x) endsWith(x.Name, 'time'), info.Dimensions)) = [];
    info.Variables(arrayfun(@(x) ~endsWith(x.Name, 'rho'), info.Variables)) = [];


    ncwriteschema(roms.input.climatology_biology,info);
end

if rivers
    if exist(roms.input.rivers,'file')
        delete(roms.input.rivers)
    end
    create_bio_rivers
    add_bio_to_rivers
end


gridInfo=get_roms_grid_info(roms.input.grid);
for var = vars'
    disp(var{1})

    needWrite=var{6};

    if ini||clm||bdy
        bdyFile="";
        clmFile="";
        iniFile="";
        if clm && needWrite{3}
            clmFile=roms.input.climatology_biology;
        end
        if bdy && needWrite{2}
            bdyFile=roms.input.boundary_biology;
        end
        if ini && needWrite{1}
            iniFile=roms.input.initialization;
        end

        if iscell(var{7})
            inputInfo=var{7};
            if inputInfo{2}==2
                depthValueFunc=inputInfo{8};
            else
                depthValueFunc=[];
            end
            roms_add_tracer_from_xyz( ...
                inputFile=inputInfo{1}, xvar=inputInfo{4},yvar=inputInfo{5},zvar=inputInfo{6},vvar=inputInfo{3}, ...
                times=times,mag=inputInfo{7},depthValueFunc=depthValueFunc,dim=inputInfo{2}, ...
                type='rho', units=var{5}, ...
                clmFile=clmFile, clmVarName=var{1}, clmVarLongName=var{4}, ...
                iniFile=iniFile, iniVarName=var{1}, iniVarLongName=var{4}, ...
                bdyFile=bdyFile, bdyVarName=var{3}, ...
                roms_grid_info= gridInfo);
        elseif length(var{7})==1
            if ini && needWrite{1}
                roms_add_variable_to_xyzt_nc(roms.input.initialization,var{1},var{7},long_name=var{4},time=time,units=var{5},coordinates=coord);
            end
            if bdy && needWrite{2}
                roms_add_tracer_to_bdy_nc(roms.input.boundary_biology,var{3},var{7},times,var{5})
            end
        end
    end
end
