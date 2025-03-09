function vars=get_all_biology_var_info
    configs
    woaFilesN="data\woa\"+string(arrayfun(@(year, month) sprintf('woa18_all_n%02d_01.nc', month), repmat(2021, 1, 12), 1:12, 'UniformOutput', false));
    woaFilesO="data\woa\"+string(arrayfun(@(year, month) sprintf('woa18_all_o%02d_01.nc', month), repmat(2021, 1, 12), 1:12, 'UniformOutput', false));
    woaFilesP="data\woa\"+string(arrayfun(@(year, month) sprintf('woa18_all_p%02d_01.nc', month), repmat(2021, 1, 12), 1:12, 'UniformOutput', false));
    cmemsFiles = "data\CMEMS\"+string(arrayfun(@(year, month) sprintf('b%d%02d.nc', year, month), repmat(2021, 1, 12), 1:12, 'UniformOutput', false));
    cmemsFiles(end+1)=cmemsFiles(1);
    chlFiles="data\OceanColour\ESACCI-OC-L3S-CHLOR_A-MERGED-1M_MONTHLY_4km_GEO_PML_OCx-2018"+string(num2str((1:12)', '%02d'))+"-fv6.0.nc";
    chlFiles(end+1)=chlFiles(1);
    woaFilesN(end+1)=woaFilesN(1);
    woaFilesP(end+1)=woaFilesP(1);
    woaFilesO(end+1)=woaFilesO(1);

    wx='lon'; wy='lat'; wz='depth';
    cx='longitude'; cy='latitude'; cz='depth';
    ox='lon';oy='lat';
    depths=[1:10:100,200:100:1000,2000:1000:6000];
    chl=[1.000	0.972	0.812	0.768	0.612	0.495	0.399	0.322	0.220	0.130	0.038	0.009	0.003	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001];
    chlDV=[depths;chl];

    switch roms.biology.model
        case "cosine"
            vars= ...
                {
                %                                                                                                                               {nc文件, 维度, 变量名, 经度变量名, 纬度变量名, 深度变量名, 缩放倍率}
                %初始场变量名        河流变量名 边界场变量名      变量全称             单位                写入{ini,bdy,clm}    初始场/边界场/气候态逼近浓度或数据源           河流浓度
                "NO3"     "NO3"     "NO3"         "nitrate concentration"       "millimole_NO3 meter-3"      {1,1,1}       {cmemsFiles,3,"no3",cx,cy,cz,1}            80
                "NH4"     "NH4"     "NH4"         "ammonium concentration"      "millimole_NH4 meter-3"      {1,0,0}       {cmemsFiles,3,"no3",cx,cy,cz,0.1}            1
                "SiOH"    "SiOH"    "SiOH"        "silicate concentration"     "millimole_silica meter-3"    {1,1,1}       {cmemsFiles,3,"si",cx,cy,cz,1}            100
                "PO4"     "PO4"     "PO4"         "phosphate concentration"     "millimole_PO4 meter-3"      {1,1,1}       {cmemsFiles,3,"po4",cx,cy,cz,1}            1
                "S1_N"    "S1_N"    "S1_N"         "S1_N"                       "millimole meter-3"          {1,0,0}       0.0001 1e-8
                "S1_C"    "S1_C"    "S1_C"         "S1_C"                       "millimole meter-3"          {1,0,0}       0.0001 1e-8
                "S1CH"    "S1CH"    "S1CH"         "S1CH"                       "milligram meter-3"          {1,0,0}       1e-8 1e-8
                "S2_N"    "S2_N"    "S2_N"         "S2_N"                       "millimole meter-3"          {1,0,0}       {chlFiles,2,"chlor_a",ox,oy,'',.36,chlDV}         0.1
                "S2_C"    "S2_C"    "S2_C"         "S2_C"                       "millimole meter-3"          {1,0,0}       {chlFiles,2,"chlor_a",ox,oy,'',.36,chlDV}         0.1
                "S2CH"    "S2CH"    "S2CH"         "S2CH"                       "milligram meter-3"          {1,0,0}       {chlFiles,2,"chlor_a",ox,oy,'',1,chlDV}              1
                "S3_N"    "S3_N"    "S3_N"         "S3_N"                       "millimole meter-3"          {1,0,0}       0.0001 1e-8
                "S3_C"    "S3_C"    "S3_C"         "S3_C"                       "millimole meter-3"          {1,0,0}       0.0001 1e-8
                "S3CH"    "S3CH"    "S3CH"         "S3CH"                       "milligram meter-3"          {1,0,0}       0.0001 1e-8
                "Z1_N"    "Z1_N"    "Z1_N"         "Z1_N"                       "millimole meter-3"          {1,0,0}       {chlFiles,2,"chlor_a",ox,oy,'',.024,chlDV}        0.01
                "Z1_C"    "Z1_C"    "Z1_C"         "Z1_C"                       "millimole meter-3"          {1,0,0}       {chlFiles,2,"chlor_a",ox,oy,'',.024,chlDV}        0.01
                "Z2_N"    "Z2_N"    "Z2_N"         "Z2_N"                       "millimole meter-3"          {1,0,0}       {chlFiles,2,"chlor_a",ox,oy,'',.024,chlDV}        0.01
                "Z2_C"    "Z2_C"    "Z2_C"         "Z2_C"                       "millimole meter-3"          {1,0,0}       {chlFiles,2,"chlor_a",ox,oy,'',.024,chlDV}        0.01
                "BAC_"    "BAC_"    "BAC_"         "BAC"                        "millimole meter-3"          {1,0,0}       0.02 1e-8
                "DD_N"    "DD_N"    "DD_N"         "DD_N"                       "millimole meter-3"          {1,0,0}       0.0001 1e-8
                "DD_C"    "DD_C"    "DD_C"         "DD_C"                       "millimole meter-3"          {1,0,0}       0.0001 1e-8
                "DDSi"    "DDSi"    "DDSi"         "DDSi"                       "millimole meter-3"          {1,0,0}       0.0001 1e-8
                "LDON"    "LDON"    "LDON"         "LDON"                       "millimole meter-3"          {1,0,0}       {chlFiles,2,"chlor_a",ox,oy,'',.8,chlDV}          1
                "LDOC"    "LDOC"    "LDOC"         "LDOC"                       "millimole meter-3"          {1,0,0}       {chlFiles,2,"chlor_a",ox,oy,'',5,chlDV}            5
                "SDON"    "SDON"    "SDON"         "SDON"                       "millimole meter-3"          {1,0,0}       {chlFiles,2,"chlor_a",ox,oy,'',1,chlDV}            1
                "SDOC"    "SDOC"    "SDOC"         "SDOC"                       "millimole meter-3"          {1,0,0}       {chlFiles,2,"chlor_a",ox,oy,'',7,chlDV}            10
                "CLDC"    "CLDC"    "CLDC"         "CLDC"                       "millimole meter-3"          {1,0,0}       0.0001 1e-8
                "CSDC"    "CSDC"    "CSDC"         "CSDC"                       "millimole meter-3"          {1,0,0}       0.4 0.4
                "DDCA"    "DDCA"    "DDCA"          "DDCA"                       "millimole meter-3"         {1,0,0}       0.0001 1e-8
                "oxyg"    "oxyg"    "oxyg"          "dissolved oxygen concentration" "millimole meter-3"     {1,0,0}       {cmemsFiles,3,"o2",cx,cy,cz,1}             230
                "TIC"     "TIC"     "TIC"           "total inorganic carbon"    "millimole_C meter-3"        {1,0,0}       2100 2100 %ana
                "Talk"    "Talk"    "Talk"           "Talk"                     "millimole meter-3"           {1,0,0}      {cmemsFiles,3,"talk",cx,cy,cz,1000}        2350
                };
        case "fennel"
            vars= ...
                {
                %                                                                                                                                              {nc文件, 维度, 变量名, 经度变量名, 纬度变量名, 深度变量名, 缩放倍率}
                %初始场变量名        河流变量名 边界场变量名      变量全称                                      单位                           写入{ini,bdy,clm}    初始场/边界场/气候态逼近浓度或数据源           河流浓度
                  "NO3"              "NO3"     "NO3"             "nitrate concentration"                      "millimole_nitrogen meter-3"        {1,1,1}        {cmemsFiles,3,"no3",cx,cy,cz,1}                  42
                  "NH4"              "NH4"     "NH4"             "ammonium concentration"                     "millimole_nitrogen meter-3"        {1,1,1}        {cmemsFiles,3,"no3",cx,cy,cz,0.1}                1
                  "chlorophyll"      "Chlo"    "chlo"            "chlorophyll concentration"                  "milligrams_chlorophyll meter-3"    {1,1,1}        {cmemsFiles,3,"chl",cx,cy,cz,1,chlDV}          1
                  "phytoplankton"    "Phyt"    "phyt"            "phytoplankton concentration"                "millimole_nitrogen meter-3"        {1,1,1}        {cmemsFiles,3,"chl",cx,cy,cz,.5,chlDV}         0.1
                  "zooplankton"      "Zoop"    "zoop"            "zooplankton concentration"                  "millimole_nitrogen meter-3"        {1,1,1}        {cmemsFiles,3,"chl",cx,cy,cz,.025,chlDV}       0.01
                  "LdetritusN"       "LDeN"    "LDeN"            "large nitrogen-detritus concentration"      "millimole_nitrogen meter-3"        {1,0,0}        {cmemsFiles,3,"chl",cx,cy,cz,.8,chlDV}         1
                  "SdetritusN"       "SDeN"    "SDeN"            "small nitrogen-detritus concentration"      "millimole_nitrogen meter-3"        {1,0,0}        {cmemsFiles,3,"chl",cx,cy,cz,1,chlDV}          1.5
                  "LdetritusC"       "LDeC"    "LdeC"            "large carbon-detritus concentration"        "millimole_carbon meter-3"          {1,0,0}        {cmemsFiles,3,"chl",cx,cy,cz,5,chlDV}          5
                  "SdetritusC"       "SDeC"    "SdeC"            "small carbon-detritus concentration"        "millimole_carbon meter-3"          {1,0,0}        {cmemsFiles,3,"chl",cx,cy,cz,7,chlDV}          10
                  "TIC"              "TIC"     "TIC"             "total inorganic carbon"                     "millimole_C meter-3"               {1,0,0}        2100                                             2100
                  "alkalinity"       "TAlk"    "alkalinity"      "total alkalinity"                           "milliequivalents meter-3"          {1,1,0}        {cmemsFiles,3,"talk",cx,cy,cz,1000}              2350
                  "oxygen"           "Oxyg"    "oxygen"          "dissolved oxygen concentration"             "millimole_oxygen meter-3"          {1,1,1}        {cmemsFiles,3,"o2",cx,cy,cz,1}                   230
                  "PO4"              "PO4"     "PO4"             "phosphate concentration"                    "millimole_PO4 meter-3"             {1,1,1}        {cmemsFiles,3,"po4",cx,cy,cz,1}                  0.21

%                 "NO3"              "NO3"     "NO3"             "nitrate concentration"                      "millimole_nitrogen meter-3"        {1,1,1}        {woaFilesN,3,"n_an",wx,wy,wz,1}                  42
%                 "NH4"              "NH4"     "NH4"             "ammonium concentration"                     "millimole_nitrogen meter-3"        {1,1,1}        {woaFilesN,3,"n_an",wx,wy,wz,0.1}                1
%                 "chlorophyll"      "Chlo"    "chlo"            "chlorophyll concentration"                  "milligrams_chlorophyll meter-3"    {1,1,1}        0.001                                            1
%                 "phytoplankton"    "Phyt"    "phyt"            "phytoplankton concentration"                "millimole_nitrogen meter-3"        {1,1,1}        0.001                                            0.1
%                 "zooplankton"      "Zoop"    "zoop"            "zooplankton concentration"                  "millimole_nitrogen meter-3"        {1,1,1}        0.001                                            0.01
%                 "LdetritusN"       "LDeN"    "LDeN"            "large nitrogen-detritus concentration"      "millimole_nitrogen meter-3"        {1,0,0}        0.001                                            1
%                 "SdetritusN"       "SDeN"    "SDeN"            "small nitrogen-detritus concentration"      "millimole_nitrogen meter-3"        {1,0,0}        0.001                                            1.5
%                 "LdetritusC"       "LDeC"    "LdeC"            "large carbon-detritus concentration"        "millimole_carbon meter-3"          {1,0,0}        0.001                                            5
%                 "SdetritusC"       "SDeC"    "SdeC"            "small carbon-detritus concentration"        "millimole_carbon meter-3"          {1,0,0}        0.001                                            10
%                 "TIC"              "TIC"     "TIC"             "total inorganic carbon"                     "millimole_C meter-3"               {1,1,1}        2100                                             2100
%                 "alkalinity"       "TAlk"    "alkalinity"      "total alkalinity"                           "milliequivalents meter-3"          {1,1,1}        2350                                             2350
%                 "oxygen"           "Oxyg"    "oxygen"          "dissolved oxygen concentration"             "millimole_oxygen meter-3"          {1,1,1}        {woaFilesO,3,"o_an",wx,wy,wz,1}                   230
%                 "PO4"              "PO4"     "PO4"             "phosphate concentration"                    "millimole_PO4 meter-3"             {1,1,1}        {woaFilesP,3,"p_an",wx,wy,wz,1}                  0.21
                };
        otherwise
            error("")
    end