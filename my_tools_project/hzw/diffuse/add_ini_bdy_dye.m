function add_ini_bdy_dye(file,bdy)

    configs
    configs(1,6);
    mask=ncread(fullfile(roms.project_dir,roms.input.grid),'mask_rho');
    n=length(ncread(fullfile(roms.project_dir,roms.input.grid),'s_rho'));
    if ~isempty(file)
        for i=1:roms.tracer.count
            try
                [dye,name]=roms_get_dye(file,i);
                %[dye,name]=roms_get_dye(file,mod(i-1,3)+1);
                disp("已读取并写入"+name);
            catch
                dye=zeros([size(mask),n]);
                disp("找不到编号为"+num2str(i)+"的dye");
            end
            dye=dye(:,:,:,end);
            dye(isnan(dye))=0;
            roms.tracer.densities{i}=dye;
        end
    else
        dye=zeros([size(mask),n]);
        for i=1:roms.tracer.count
            roms.tracer.densities{i}=dye;
        end
    end
    for i=1:roms.tracer.count
        if length(bdy)==1
            temp=bdy;
        else
            temp=bdy(mod(i-1,length(bdy))+1);
        end
        roms.tracer.east{i}(:)=temp;
        roms.tracer.west{i}(:)=temp;
        roms.tracer.north{i}(:)=temp;
        roms.tracer.south{i}(:)=temp;
    end
    roms_add_passive_tracer_core(roms);