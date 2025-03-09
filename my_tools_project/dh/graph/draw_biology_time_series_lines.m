vars=["DIN","PO4","NPratio","chlorophyll","zooplankton"];

project_data
s=length(vars);
varNames=strings(s,1);
for i=1:s
    varNames(i)=bioData.varName.(vars(i))+" ("+bioData.unit.(vars(i))+")";
end
vars=vars+"_sur";
colors=[
    26, 35, 126
    33, 150, 243
    129, 212, 250
    211, 47, 47
    244, 143, 177
    %0, 230, 118
    ]/256;
locationNames=replace(bioData.locationNames,newline," ");

draw_time_series_stack_lines(bioData.qck,vars,varNames,bioData.locations,locationNames,3, ...
    logY=1, smooth=40, rowColumn=[2,3], lineColors=colors)

set_gcf_size(1200,800)
