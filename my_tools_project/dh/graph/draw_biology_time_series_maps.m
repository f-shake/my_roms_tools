vars=["DIN","PO4","chlorophyll","zooplankton"];
project_data
s=length(vars);
varNames=cell(s,1);
varDescs=strings(s,1);
colorRanges=zeros(s,2);
labels=strings(s,1);
for i=1:s
    varDescs(i)=bioData.varName.(vars(i));
    colorRanges(i,:)=bioData.colorRanges.(vars(i));
    labels(i)=strs.axis_concentrationOf(bioData.varName.(vars(i)), bioData.unit.(vars(i)));
    switch vars(i)
        case "DetritusN"
            varNames{i}=["SdetritusN","LdetritusN"];
        case "DetritusC"
            varNames{i}=["SdetritusC","LdetritusC"];
        case "DIN"
            varNames{i}=["NO3","NH4"];
        otherwise
            varNames{i}=vars(i);
    end
end

draw_time_series_maps(bioData.avg,0, varNames, varDescs, ...
    {3:5,6:8,9:11,[12,1,2]}, strs.title_seasonNames, ...
    colorRange=colorRanges,colorBarLabels=labels,useSameColorRange=0,usePercentageColorRange=0, ...
    labelPosition='rb')
for i=1:length(vars)*4
    nexttile(i)
    draw_provinces
end
graphData.mainNclColor(true);

set_gcf_size(800,s*180)