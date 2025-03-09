g1=1;
g2=1;
g3=1;

global strLang;
strLang='en';
project_data
vars=["DIN","PO4","chlorophyll","zooplankton"];
labels=["DIN (μmol/L)","PO4 (μmol/L)","chlorophyll (mg/L)","zooplankton (μmol/L)"];
colorRanges=[bioData.colorRanges.DIN;bioData.colorRanges.PO4;bioData.colorRanges.chlorophyll;bioData.colorRanges.zooplankton];
units=[bioData.unit.DIN,bioData.unit.PO4,bioData.unit.chlorophyll,bioData.unit.zooplankton];
project_data
s=length(vars);
filePath=bioData.avg;

if g1
    clf
    tl=tiledlayout(2,2);
    set_tiledlayout_compact(tl)
    times=roms_get_times(read_data(filePath,'ocean_time'));

    for i=1:length(vars)
        var=vars{i};
        disp(var)
        nexttile;
        %读取数据
        varData=read_data(filePath,var,[1,1,0,1],[0,0,1,0]);
        varData=squeeze(varData);
        varData=mean(varData,3);

        draw_map(varData,'gf')
        hold on
        apply_font
        caxis(colorRanges(i,:));
        colorbar;
        %c.Label.String=units(i);
        draw_provinces
    end

    graphData.mainNclColor(1);
    set_gcf_size(400,330)
    exportgraphics(gcf,'GA-1.png','Resolution', 1200, 'BackgroundColor','#c5e0b4')
end

if g2
    clf
    tests=bioData.tests(1:2);
    tl=tiledlayout(2,2);
    set_tiledlayout_compact(tl)


    for iVar=1:length(vars)
        var=vars(iVar);
        disp(var)
        t=nexttile;
        for iTest=1:length(tests)
            disp("——"+bioData.testNames(iTest))
            data=read_data(tests(iTest),var,[1,1,0,1],[0,0,1,0]);
            data=mean(data,4);
            if iTest==1
                baseData=data;
                caxis(bioData.colorRanges.(var));
                %draw_map(data);
                %bioData.mainNclColor(0)
            else
                data=(data./baseData-1);
                caxis([0,3])
                draw_map(data,'gf');
                draw_provinces
                cm2=color_ncl(14,60,[0.55,1]);

                for i=1:60
                    for j=1:3
                        cm2(i,j)=cm2(i,j)+(60-i)*(1-cm2(i,j))/70;
                    end
                end
                cm2(1,:)=[1,1,1];
                colormap(t,cm2);
            end
            apply_font
        end
    end

    c=colorbar;
    c.Ticks=0:4;
    c.TickLabels=["0","+100%","+200%","+300%"];
    c.Layout.Tile='east';


    set_gcf_size(400,360)
    exportgraphics(gcf,'GA-2.png','Resolution', 1200, 'BackgroundColor','#fbe5d6')
end



if g3
    clf
    tests=bioData.tests([1,3,4]);
    tl=tiledlayout('flow');
    set_tiledlayout_compact(tl)
    titles=["","Consider DIN increase","Consider PO_4 increase"];
    var="chlorophyll";
    disp(var)
    for iTest=1:length(tests)
        data=read_data(tests(iTest),var,[1,1,0,1],[0,0,1,0]);
        data=mean(data,4);
        if iTest==1
            baseData=data;
            caxis(bioData.colorRanges.(var));
            %draw_map(data);
            %bioData.mainNclColor(0)
        else
            t=nexttile;
            data=(data./baseData-1);
            caxis([0,0.5])
            draw_map(data,'lgf');
            draw_provinces
            cm2=color_ncl(14,60,[0.55,1]);
            for i=1:60
                for j=1:3
                    cm2(i,j)=cm2(i,j)+(60-i)*(1-cm2(i,j))/70;
                end
            end
            cm2(1,:)=[1,1,1];
            colormap(t,cm2);
        end
        apply_font
    end


    c=colorbar;
    c.Ticks=0:0.1:0.5;
    c.TickLabels=["0","+10%","+20%","+30%","+40%","+50%"];
    c.Layout.Tile='east';
    set_gcf_size(480,170)
    exportgraphics(gcf,'GA-3.png','Resolution', 1200, 'BackgroundColor','#feffcf')
end


