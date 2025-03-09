function [keys,singleItems,meanItems]=read_emission_table(table,sheetIndex,keyColumn,singleColumns ,meanColumns)
    arguments
        table(1,1) string
        sheetIndex(1,1) double {mustBeInteger}
        keyColumn(1,1) string
        singleColumns(1,:) string
        meanColumns(1,:) string
    end
    table=readtable(table,Sheet=sheetIndex);
    for i=1:length(meanColumns)
        item=grpstats(table,keyColumn,'mean','DataVars',meanColumns(i));
        if i==1
            groupCount=size(item,1);
            meanItems=zeros(groupCount,length(meanColumns));
            keys=string(table2array(item(:,1)));
        end
        meanItems(:,i)=table2array( item(:,3));
    end
    tableRowCount=size(table,1);

    singleItems=cell(groupCount,length(singleColumns));
    for i=1:tableRowCount
        n1= string(table(i,:).(keyColumn){1});
        for j=1:groupCount
            n2=keys(j);
            if isequal(n1,n2)
                for k=1:length(singleColumns)
                    singleItems(j,k)= table(i,:).(singleColumns(k));
                end
            end
        end
    end