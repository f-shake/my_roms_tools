function write_sensitivity_testing_table(vars)
    project_data
    xy=roms_get_xy_by_lonlat_core(bioData.locations,enable=false);
    absolutes=cell((length(bioData.tests))*length(vars),length(bioData.locationNames)+2);
    percentages=cell((length(bioData.tests)-1)*length(vars),length(bioData.locationNames)+2);
    baseData=zeros(length(vars),length(bioData.locationNames));
    pRow=0;
    aRow=0;
    for iTest=1:length(bioData.tests)
        disp(bioData.testNames(iTest))
        for iVar=1:length(vars)
            disp("——"+vars(iVar))
            aRow=aRow+1;
            absolutes{aRow,1}=bioData.testNames(iTest);
            absolutes{aRow,2}=bioData.varName.(vars(iVar));

            if iTest>1
                pRow=pRow+1;
                percentages{pRow,1}=bioData.testNames(iTest);
                percentages{pRow,2}=bioData.varName.(vars(iVar));
            end
            
            for iLoc=1:length(bioData.locationNames)
                data=read_data(bioData.tests(iTest),vars(iVar),[xy(iLoc,1)-1,xy(iLoc,2)-1,0,1],[3,3,1,0]);
                data=mean(data,'all','omitnan');
                absolutes{aRow,iLoc+2}=data;
                if iTest==1
                    baseData(iVar,iLoc)=data;
                else
                    data=data/baseData(iVar,iLoc)-1;
                    if data>0
                        a="+";
                    else
                        a="-";
                    end
                    percentages{pRow,2+iLoc}=sprintf('%s%f%%', a,abs(data)*100);
                end
            end
        end
    end
    writecell(percentages,"T2.xlsx")
    writecell(absolutes,"S2.xlsx")
end