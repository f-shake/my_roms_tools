function draw_biology_profile(vars,direction)
    arguments
        vars(:,1) string %变量名
        direction(1,1) string {mustBeMember(direction,["lon","lat"])} %剖面方向，沿什么方向切割
    end
    project_data
    s=length(vars);

    if direction=="lon"
        degrees=120:2.5:130;
        textCorner='rb';
    else
        degrees=22:2.5:32;
        textCorner='lb';
    end

    vColorRanges=zeros(s,2);
    hColorRanges=zeros(s,2);
    varNames=strings(s,1);
    maxDepths=zeros(s,1);
    labels=strings(s,1);
    for i=1:s
        v=vars(i);
        vColorRanges(i,:)=bioData.profileColorRanges.(v);
        hColorRanges(i,:)=bioData.colorRanges.(v);
        varNames(i)=bioData.varName.(v);
        maxDepths(i)=bioData.maxDepth.(v);
        if v=="temp"
            labels(i)=strs.axis_temp;
        else
            labels(i)=strs.axis_concentrationOf(bioData.varName.(vars(i)), bioData.unit.(vars(i)));
        end
    end

    draw_profile(bioData.avg,vars,varNames,direction,degrees,maxDepths,vColorRanges,hColorRanges,textCorner,labels);

    graphData.mainNclColor(true);
    set_gcf_size(1200,s*180)
