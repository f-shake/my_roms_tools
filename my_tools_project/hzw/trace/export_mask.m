configs
mask=ncread(fullfile(roms.project_dir,roms.input.grid),'mask_rho');
mask(mask==0)=255;
mask(mask==1)=0;
writematrix(flipud(mask'),fullfile(roms.project_dir,'mask.grd'),FileType="text") %ROMS Grid Data