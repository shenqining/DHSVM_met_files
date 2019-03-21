% 从China Meteorological Forcing Dataset(CMFD)数据库中的.nc文件中提取唐山区域的.nc文件，并转换成.txt作为DHSVM的输入
% Qining Shen, Aug.24, 2018
% 气象数据的顺序在ReadMetRecord.c的Array[ ]里可以查看（Tair, Wind, Rh, Sin, Lin, Precip）

%% 设置地理范围及步长（由相应遥感数据维度大小计算而来），输入输出文件夹
clc;
clear;
LON_LEFT = 117.95;LON_RIGHT = 118.65;                                      % 用HDF Explorer可以查看区域起始的经纬度
LAT_SOUTH = 39.45;LAT_NORTH = 40.15;                                       % 用HDF Explorer可以查看区域起始的经纬度
TIME_RESO = 8;                                                             % 时间精度，24/3h = 8
STARTDATE = '01-Jan-1900 00:00:30';                                        % CMFD的数据时间比1900-01-01 00:00:0.0多了3秒，所以加了个3秒
ONE_HOUR = datenum('01-Jan-1900 01:00:00')-datenum('01-Jan-1900 00:00:00');% CMFD数据的时间是hours since 1900-01-01 00:00:0.0
MONTHDAY1 = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];              % common year
MONTHDAY2 = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];              % leap year
YEAR_BEG = 1980;
YEAR_END = 2015;
MONTH_BEG = 1;
MONTH_END = 12;
REGION_START = [480 245 1];                                                % 表示lon,lat,time分别从第480，第245，第1个数开始读逐个读；用HDF Explorer查看位置
REGION_COUNT = [8 8 inf];                                                  % 表示lon,lat各读8个，time读到最后一个(inf)
REGION_SRIDE = [1 1 1];                                                    % 步长，缺省值为1
ncPATH = 'H:\westdc\';                                                     % 存放CMFD的文件夹
outpath = 'E:\DHSVM\SQN\Tangshan\metinput';                                % 这个是计算过程的中间文件夹，计算完后删除（不经过回收站），最后不要加"\"
outpath1 = strcat(outpath, '\');
outpath_final = 'E:\DHSVM\SQN\Tangshan\metfile\';                          % 存放结果的最终文件夹

%% 判断文件夹是否存在，如果不存在则创建
if ~exist(outpath,'dir')
    mkdir(outpath)
end

%% (1) 从CMFD数据库中的Temp的.nc文件中提取所需区域的.nc文件
for i = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(i,100)~= 0 && rem(i,4) == 0 )|| (rem(i,100) == 0 && rem(i,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for j = MONTH_BEG:MONTH_END        
        
        % 读取文件部分
        PATH = strcat(ncPATH,'Data_forcing_03hr_010deg\Temp\');% 存放CMFD的文件夹
        Basename = 'temp_ITPCAS-CMFD_V0106_B-01_03hr_010deg_';
        if j < 10
            Rname = num2str('0');
        else
            Rname = num2str(' ' );
        end
        Monthname = strcat(num2str(i), Rname, num2str(j));
        Filename = strcat(PATH,Basename, Monthname);
        Fullname = strcat(Filename,'.nc');
       
        switch j
            case 1
                nd = MONTHDAY(1)*TIME_RESO;
            case 2 
                nd = MONTHDAY(2)*TIME_RESO;
            case 3
                nd = MONTHDAY(3)*TIME_RESO;
            case 4
                nd = MONTHDAY(4)*TIME_RESO;
            case 5
                nd = MONTHDAY(5)*TIME_RESO;
            case 6
                nd = MONTHDAY(6)*TIME_RESO;
            case 7
                nd = MONTHDAY(7)*TIME_RESO;
            case 8
                nd = MONTHDAY(8)*TIME_RESO;
            case 9
                nd = MONTHDAY(9)*TIME_RESO;
            case 10
                nd = MONTHDAY(10)*TIME_RESO;
            case 11
                nd = MONTHDAY(11)*TIME_RESO;
            case 12
                nd = MONTHDAY(12)*TIME_RESO;                
        end
        
        % 读气象nc文件，并获取所需区域数据，ncread(source,varname,start,count,stride)，用HDF Explorer可以查看区域起始的经纬度
        data = ncread(Fullname,'temp',REGION_START,REGION_COUNT,REGION_SRIDE); 
        % 读气象nc文件，并获取数据的时间
        time = ncread(Fullname,'time');
        
        % 读取每天3,6,9,12,15,18,21,24时刻的数据
        for d = 1:nd
            data1 = data(:,:,d);
            time1 = time(d);
         
            % 输出文件的命名
            timeoutput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            Basename1 = 'temp_';
            outputname = strcat(outpath1, Basename1, timeoutput, '.txt');
            
            % 将数据输出到.txt文件中
            fid = fopen(outputname,'wt');
            fprintf(fid,'%f\n',data1);
            fclose(fid);
        end
    end
end

% 读取裁剪出来的区域的Temp 3h数据，重新按照站点输出
data_all1 = [];
time_all = [];
for yy = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(yy,100)~= 0 && rem(yy,4) == 0 )|| (rem(yy,100) == 0 && rem(yy,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end    
    
    for m = MONTH_BEG:MONTH_END
        
        % 读取文件部分
        PATH = strcat(ncPATH,'Data_forcing_03hr_010deg\Temp\');% 存放CMFD的文件夹
        Basename = 'temp_ITPCAS-CMFD_V0106_B-01_03hr_010deg_';
        if m < 10
            Rname = num2str('0');
        else
            Rname = num2str(' ' );
        end
        Monthname = strcat(num2str(yy), Rname, num2str(m));
        Filename = strcat(PATH,Basename, Monthname);
        Fullname = strcat(Filename,'.nc');
        
        switch m
            case 1
                nd1 = MONTHDAY(1)*TIME_RESO;
            case 2 % 闰年需要改一下
                nd1 = MONTHDAY(2)*TIME_RESO;
            case 3
                nd1 = MONTHDAY(3)*TIME_RESO;
            case 4
                nd1 = MONTHDAY(4)*TIME_RESO;
            case 5
                nd1 = MONTHDAY(5)*TIME_RESO;
            case 6
                nd1 = MONTHDAY(6)*TIME_RESO;
            case 7
                nd1 = MONTHDAY(7)*TIME_RESO;
            case 8
                nd1 = MONTHDAY(8)*TIME_RESO;
            case 9
                nd1 = MONTHDAY(9)*TIME_RESO;
            case 10
                nd1 = MONTHDAY(10)*TIME_RESO;
            case 11
                nd1 = MONTHDAY(11)*TIME_RESO;
            case 12
                nd1 = MONTHDAY(12)*TIME_RESO;
        end
        
        % 读气象nc文件，并获取所需区域数据，ncread(source,varname,start,count,stride)，用HDF Explorer可以查看区域起始的经纬度
        data = ncread(Fullname,'temp',REGION_START,REGION_COUNT,REGION_SRIDE); 
        % 读气象nc文件，并获取数据的时间
        time = ncread(Fullname,'time');
        
        % 读取每天3,6,9,12,15,18,21,24时刻的.txt数据
        for d = 1:nd1
            time1 = time(d);
            
            % 输入文件
            timeinput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            timeinput1 = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mm/dd/yyyy-HH');
            outputname1 = strcat(outpath1, Basename1, timeinput, '.txt');
            data_load = load(outputname1);
            data_all1 = [data_all1, data_load];% 注意这里用","
            time_all = [time_all; timeinput1];% 注意这里用";"
        end
    end
end

%% (2) 从CMFD数据库中的Wind的.nc文件中提取所需区域的.nc文件
for i = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(i,100)~= 0 && rem(i,4) == 0 )|| (rem(i,100) == 0 && rem(i,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for j = MONTH_BEG:MONTH_END        
        
        % 读取文件部分
        PATH = strcat(ncPATH,'Data_forcing_03hr_010deg\Wind\');
        Basename = 'wind_ITPCAS-CMFD_V0106_B-01_03hr_010deg_';
        if j < 10
            Rname = num2str('0');
        else
            Rname = num2str(' ' );
        end
        Monthname = strcat(num2str(i), Rname, num2str(j));
        Filename = strcat(PATH,Basename, Monthname);
        Fullname = strcat(Filename,'.nc');
       
        switch j
            case 1
                nd = MONTHDAY(1)*TIME_RESO;
            case 2 
                nd = MONTHDAY(2)*TIME_RESO;
            case 3
                nd = MONTHDAY(3)*TIME_RESO;
            case 4
                nd = MONTHDAY(4)*TIME_RESO;
            case 5
                nd = MONTHDAY(5)*TIME_RESO;
            case 6
                nd = MONTHDAY(6)*TIME_RESO;
            case 7
                nd = MONTHDAY(7)*TIME_RESO;
            case 8
                nd = MONTHDAY(8)*TIME_RESO;
            case 9
                nd = MONTHDAY(9)*TIME_RESO;
            case 10
                nd = MONTHDAY(10)*TIME_RESO;
            case 11
                nd = MONTHDAY(11)*TIME_RESO;
            case 12
                nd = MONTHDAY(12)*TIME_RESO;                
        end
        
        % 读气象nc文件，并获取所需区域数据
        data = ncread(Fullname,'wind',REGION_START,REGION_COUNT,REGION_SRIDE);
        % 读气象nc文件，并获取数据的时间
        time = ncread(Fullname,'time');
        
        % 读取每天3,6,9,12,15,18,21,24时刻的数据
        for d = 1:nd
            data1 = data(:,:,d);
            time1 = time(d);
            
            % 输出文件的命名
            timeoutput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            Basename1 = 'wind_';            
            outputname = strcat(outpath1, Basename1, timeoutput, '.txt');            
           
            % 将数据输出到.txt文件中
            fid = fopen(outputname,'wt');            
            fprintf(fid,'%f\n',data1);            
            fclose(fid);
        end
    end
end

% 读取裁剪出来的区域的3h数据，重新按照站点输出
data_all2 = [];
for yy = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(yy,100)~= 0 && rem(yy,4) == 0 )|| (rem(yy,100) == 0 && rem(yy,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for m = MONTH_BEG:MONTH_END
        
        % 读取文件部分
        PATH = strcat(ncPATH,'Data_forcing_03hr_010deg\Temp\');% 存放CMFD的文件夹
        Basename = 'temp_ITPCAS-CMFD_V0106_B-01_03hr_010deg_';
        if m < 10
            Rname = num2str('0');
        else
            Rname = num2str(' ' );
        end
        Monthname = strcat(num2str(yy), Rname, num2str(m));
        Filename = strcat(PATH,Basename, Monthname);
        Fullname = strcat(Filename,'.nc');
        
        switch m
            case 1
                nd1 = MONTHDAY(1)*TIME_RESO;
            case 2 % 闰年需要改一下
                nd1 = MONTHDAY(2)*TIME_RESO;
            case 3
                nd1 = MONTHDAY(3)*TIME_RESO;
            case 4
                nd1 = MONTHDAY(4)*TIME_RESO;
            case 5
                nd1 = MONTHDAY(5)*TIME_RESO;
            case 6
                nd1 = MONTHDAY(6)*TIME_RESO;
            case 7
                nd1 = MONTHDAY(7)*TIME_RESO;
            case 8
                nd1 = MONTHDAY(8)*TIME_RESO;
            case 9
                nd1 = MONTHDAY(9)*TIME_RESO;
            case 10
                nd1 = MONTHDAY(10)*TIME_RESO;
            case 11
                nd1 = MONTHDAY(11)*TIME_RESO;
            case 12
                nd1 = MONTHDAY(12)*TIME_RESO;
        end
        
        % 读气象nc文件，并获取所需区域数据，ncread(source,varname,start,count,stride)，用HDF Explorer可以查看区域起始的经纬度
        data = ncread(Fullname,'temp',REGION_START,REGION_COUNT,REGION_SRIDE);
        % 读气象nc文件，并获取数据的时间
        time = ncread(Fullname,'time');
        
        % 读取每天3,6,9,12,15,18,21,24时刻的.txt数据
        for d = 1:nd1
            time1 = time(d);
            
            % 输入文件
            timeinput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            timeinput1 = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mm/dd/yyyy-HH');
            outputname1 = strcat(outpath1, Basename1, timeinput, '.txt');
            data_load = load(outputname1);
            data_all2 = [data_all2, data_load];% 注意这里用","
        end
    end
end

%% (3) 从CMFD数据库中的Shum的.nc文件中提取所需区域的.nc文件
% 湿度的单位是Specific humidity（比湿），输出的时候需要转化成相对湿度，见L1051
for i = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(i,100)~= 0 && rem(i,4) == 0 )|| (rem(i,100) == 0 && rem(i,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for j = MONTH_BEG:MONTH_END        
        
        % 读取文件部分
        PATH = strcat(ncPATH,'Data_forcing_03hr_010deg\Shum\');
        Basename = 'shum_ITPCAS-CMFD_V0106_B-01_03hr_010deg_';
        if j < 10
            Rname = num2str('0');
        else
            Rname = num2str(' ' );
        end
        Monthname = strcat(num2str(i), Rname, num2str(j));
        Filename = strcat(PATH,Basename, Monthname);
        Fullname = strcat(Filename,'.nc');
       
        switch j
            case 1
                nd = MONTHDAY(1)*TIME_RESO;
            case 2 
                nd = MONTHDAY(2)*TIME_RESO;
            case 3
                nd = MONTHDAY(3)*TIME_RESO;
            case 4
                nd = MONTHDAY(4)*TIME_RESO;
            case 5
                nd = MONTHDAY(5)*TIME_RESO;
            case 6
                nd = MONTHDAY(6)*TIME_RESO;
            case 7
                nd = MONTHDAY(7)*TIME_RESO;
            case 8
                nd = MONTHDAY(8)*TIME_RESO;
            case 9
                nd = MONTHDAY(9)*TIME_RESO;
            case 10
                nd = MONTHDAY(10)*TIME_RESO;
            case 11
                nd = MONTHDAY(11)*TIME_RESO;
            case 12
                nd = MONTHDAY(12)*TIME_RESO;                
        end
        
        % 读气象nc文件，并获取所需区域数据
        data = ncread(Fullname,'shum',REGION_START,REGION_COUNT,REGION_SRIDE);
        % 读气象nc文件，并获取数据的时间
        time = ncread(Fullname,'time');
        
        % 读取每天3,6,9,12,15,18,21,24时刻的数据
        for d = 1:nd
            data1 = data(:,:,d);
            time1 = time(d);
            
            % 输出文件的命名
            timeoutput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            Basename1 = 'shum_';            
            outputname = strcat(outpath1, Basename1, timeoutput, '.txt');            
           
            % 将数据输出到.txt文件中
            fid = fopen(outputname,'wt');            
            fprintf(fid,'%f\n',data1);            
            fclose(fid);
        end
    end
end

% 读取裁剪出来的区域的3h数据，重新按照站点输出
data_all3 = [];
for yy = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(yy,100)~= 0 && rem(yy,4) == 0 )|| (rem(yy,100) == 0 && rem(yy,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for m = MONTH_BEG:MONTH_END
        
        % 读取文件部分
        PATH = strcat(ncPATH,'Data_forcing_03hr_010deg\Temp\');% 存放CMFD的文件夹
        Basename = 'temp_ITPCAS-CMFD_V0106_B-01_03hr_010deg_';
        if m < 10
            Rname = num2str('0');
        else
            Rname = num2str(' ' );
        end
        Monthname = strcat(num2str(yy), Rname, num2str(m));
        Filename = strcat(PATH,Basename, Monthname);
        Fullname = strcat(Filename,'.nc');
        
        switch m
            case 1
                nd1 = MONTHDAY(1)*TIME_RESO;
            case 2 % 闰年需要改一下
                nd1 = MONTHDAY(2)*TIME_RESO;
            case 3
                nd1 = MONTHDAY(3)*TIME_RESO;
            case 4
                nd1 = MONTHDAY(4)*TIME_RESO;
            case 5
                nd1 = MONTHDAY(5)*TIME_RESO;
            case 6
                nd1 = MONTHDAY(6)*TIME_RESO;
            case 7
                nd1 = MONTHDAY(7)*TIME_RESO;
            case 8
                nd1 = MONTHDAY(8)*TIME_RESO;
            case 9
                nd1 = MONTHDAY(9)*TIME_RESO;
            case 10
                nd1 = MONTHDAY(10)*TIME_RESO;
            case 11
                nd1 = MONTHDAY(11)*TIME_RESO;
            case 12
                nd1 = MONTHDAY(12)*TIME_RESO;
        end
        
        % 读气象nc文件，并获取所需区域数据，ncread(source,varname,start,count,stride)，用HDF Explorer可以查看区域起始的经纬度
        data = ncread(Fullname,'temp',REGION_START,REGION_COUNT,REGION_SRIDE);
        % 读气象nc文件，并获取数据的时间
        time = ncread(Fullname,'time');
        
        % 读取每天3,6,9,12,15,18,21,24时刻的.txt数据
        for d = 1:nd1
            time1 = time(d);
            
            % 输入文件
            timeinput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            timeinput1 = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mm/dd/yyyy-HH');
            outputname1 = strcat(outpath1, Basename1, timeinput, '.txt');
            data_load = load(outputname1);
            data_all3 = [data_all3, data_load];% 注意这里用","
        end
    end
end

%% (4) 从CMFD数据库中的SRad的.nc文件中提取所需区域的.nc文件
for i = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(i,100)~= 0 && rem(i,4) == 0 )|| (rem(i,100) == 0 && rem(i,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for j = MONTH_BEG:MONTH_END        
        
        % 读取文件部分
        PATH = strcat(ncPATH,'Data_forcing_03hr_010deg\SRad\');
        Basename = 'srad_ITPCAS-CMFD_V0106_B-01_03hr_010deg_';
        if j < 10
            Rname = num2str('0');
        else
            Rname = num2str(' ' );
        end
        Monthname = strcat(num2str(i), Rname, num2str(j));
        Filename = strcat(PATH,Basename, Monthname);
        Fullname = strcat(Filename,'.nc');
       
        switch j
            case 1
                nd = MONTHDAY(1)*TIME_RESO;
            case 2 
                nd = MONTHDAY(2)*TIME_RESO;
            case 3
                nd = MONTHDAY(3)*TIME_RESO;
            case 4
                nd = MONTHDAY(4)*TIME_RESO;
            case 5
                nd = MONTHDAY(5)*TIME_RESO;
            case 6
                nd = MONTHDAY(6)*TIME_RESO;
            case 7
                nd = MONTHDAY(7)*TIME_RESO;
            case 8
                nd = MONTHDAY(8)*TIME_RESO;
            case 9
                nd = MONTHDAY(9)*TIME_RESO;
            case 10
                nd = MONTHDAY(10)*TIME_RESO;
            case 11
                nd = MONTHDAY(11)*TIME_RESO;
            case 12
                nd = MONTHDAY(12)*TIME_RESO;                
        end
        
        % 读气象nc文件，并获取所需区域数据
        data = ncread(Fullname,'srad',REGION_START,REGION_COUNT,REGION_SRIDE);
        % 读气象nc文件，并获取数据的时间
        time = ncread(Fullname,'time');
        
        % 读取每天3,6,9,12,15,18,21,24时刻的数据
        for d = 1:nd
            data1 = data(:,:,d);
            time1 = time(d);
            
            % 输出文件的命名
            timeoutput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            Basename1 = 'srad_';            
            outputname = strcat(outpath1, Basename1, timeoutput, '.txt');            
           
            % 将数据输出到.txt文件中
            fid = fopen(outputname,'wt');            
            fprintf(fid,'%f\n',data1);            
            fclose(fid);
        end
    end
end

% 读取裁剪出来的区域的3h数据，重新按照站点输出
data_all4 = [];
for yy = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(yy,100)~= 0 && rem(yy,4) == 0 )|| (rem(yy,100) == 0 && rem(yy,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for m = MONTH_BEG:MONTH_END
        
        % 读取文件部分
        PATH = strcat(ncPATH,'Data_forcing_03hr_010deg\Temp\');% 存放CMFD的文件夹
        Basename = 'temp_ITPCAS-CMFD_V0106_B-01_03hr_010deg_';
        if m < 10
            Rname = num2str('0');
        else
            Rname = num2str(' ' );
        end
        Monthname = strcat(num2str(yy), Rname, num2str(m));
        Filename = strcat(PATH,Basename, Monthname);
        Fullname = strcat(Filename,'.nc');
        
        switch m
            case 1
                nd1 = MONTHDAY(1)*TIME_RESO;
            case 2 % 闰年需要改一下
                nd1 = MONTHDAY(2)*TIME_RESO;
            case 3
                nd1 = MONTHDAY(3)*TIME_RESO;
            case 4
                nd1 = MONTHDAY(4)*TIME_RESO;
            case 5
                nd1 = MONTHDAY(5)*TIME_RESO;
            case 6
                nd1 = MONTHDAY(6)*TIME_RESO;
            case 7
                nd1 = MONTHDAY(7)*TIME_RESO;
            case 8
                nd1 = MONTHDAY(8)*TIME_RESO;
            case 9
                nd1 = MONTHDAY(9)*TIME_RESO;
            case 10
                nd1 = MONTHDAY(10)*TIME_RESO;
            case 11
                nd1 = MONTHDAY(11)*TIME_RESO;
            case 12
                nd1 = MONTHDAY(12)*TIME_RESO;
        end
        
        % 读气象nc文件，并获取所需区域数据，ncread(source,varname,start,count,stride)，用HDF Explorer可以查看区域起始的经纬度
        data = ncread(Fullname,'temp',REGION_START,REGION_COUNT,REGION_SRIDE);
        % 读气象nc文件，并获取数据的时间
        time = ncread(Fullname,'time');
        
        % 读取每天3,6,9,12,15,18,21,24时刻的.txt数据
        for d = 1:nd1
            time1 = time(d);
            
            % 输入文件
            timeinput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            timeinput1 = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mm/dd/yyyy-HH');
            outputname1 = strcat(outpath1, Basename1, timeinput, '.txt');
            data_load = load(outputname1);
            data_all4 = [data_all4, data_load];% 注意这里用","
        end
    end
end

%% (5) 从CMFD数据库中的LRad的.nc文件中提取所需区域的.nc文件
for i = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(i,100)~= 0 && rem(i,4) == 0 )|| (rem(i,100) == 0 && rem(i,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for j = MONTH_BEG:MONTH_END        
        
        % 读取文件部分
        PATH = strcat(ncPATH,'Data_forcing_03hr_010deg\LRad\');
        Basename = 'lrad_ITPCAS-CMFD_V0106_B-01_03hr_010deg_';
        if j < 10
            Rname = num2str('0');
        else
            Rname = num2str(' ' );
        end
        Monthname = strcat(num2str(i), Rname, num2str(j));
        Filename = strcat(PATH,Basename, Monthname);
        Fullname = strcat(Filename,'.nc');
       
        switch j
            case 1
                nd = MONTHDAY(1)*TIME_RESO;
            case 2 
                nd = MONTHDAY(2)*TIME_RESO;
            case 3
                nd = MONTHDAY(3)*TIME_RESO;
            case 4
                nd = MONTHDAY(4)*TIME_RESO;
            case 5
                nd = MONTHDAY(5)*TIME_RESO;
            case 6
                nd = MONTHDAY(6)*TIME_RESO;
            case 7
                nd = MONTHDAY(7)*TIME_RESO;
            case 8
                nd = MONTHDAY(8)*TIME_RESO;
            case 9
                nd = MONTHDAY(9)*TIME_RESO;
            case 10
                nd = MONTHDAY(10)*TIME_RESO;
            case 11
                nd = MONTHDAY(11)*TIME_RESO;
            case 12
                nd = MONTHDAY(12)*TIME_RESO;                
        end
        
        % 读气象nc文件，并获取所需区域数据
        data = ncread(Fullname,'lrad',REGION_START,REGION_COUNT,REGION_SRIDE);
        % 读气象nc文件，并获取数据的时间
        time = ncread(Fullname,'time');
        
        % 读取每天3,6,9,12,15,18,21,24时刻的数据
        for d = 1:nd
            data1 = data(:,:,d);
            time1 = time(d);
            
            % 输出文件的命名
            timeoutput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            Basename1 = 'lrad_';            
            outputname = strcat(outpath1, Basename1, timeoutput, '.txt');            
           
            % 将数据输出到.txt文件中
            fid = fopen(outputname,'wt');            
            fprintf(fid,'%f\n',data1);            
            fclose(fid);
        end
    end
end

% 读取裁剪出来的区域的3h数据，重新按照站点输出
data_all5 = [];
for yy = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(yy,100)~= 0 && rem(yy,4) == 0 )|| (rem(yy,100) == 0 && rem(yy,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for m = MONTH_BEG:MONTH_END
        
        % 读取文件部分
        PATH = strcat(ncPATH,'Data_forcing_03hr_010deg\Temp\');% 存放CMFD的文件夹
        Basename = 'temp_ITPCAS-CMFD_V0106_B-01_03hr_010deg_';
        if m < 10
            Rname = num2str('0');
        else
            Rname = num2str(' ' );
        end
        Monthname = strcat(num2str(yy), Rname, num2str(m));
        Filename = strcat(PATH,Basename, Monthname);
        Fullname = strcat(Filename,'.nc');
        
        switch m
            case 1
                nd1 = MONTHDAY(1)*TIME_RESO;
            case 2 % 闰年需要改一下
                nd1 = MONTHDAY(2)*TIME_RESO;
            case 3
                nd1 = MONTHDAY(3)*TIME_RESO;
            case 4
                nd1 = MONTHDAY(4)*TIME_RESO;
            case 5
                nd1 = MONTHDAY(5)*TIME_RESO;
            case 6
                nd1 = MONTHDAY(6)*TIME_RESO;
            case 7
                nd1 = MONTHDAY(7)*TIME_RESO;
            case 8
                nd1 = MONTHDAY(8)*TIME_RESO;
            case 9
                nd1 = MONTHDAY(9)*TIME_RESO;
            case 10
                nd1 = MONTHDAY(10)*TIME_RESO;
            case 11
                nd1 = MONTHDAY(11)*TIME_RESO;
            case 12
                nd1 = MONTHDAY(12)*TIME_RESO;
        end
        
        % 读气象nc文件，并获取所需区域数据，ncread(source,varname,start,count,stride)，用HDF Explorer可以查看区域起始的经纬度
        data = ncread(Fullname,'temp',REGION_START,REGION_COUNT,REGION_SRIDE);
        % 读气象nc文件，并获取数据的时间
        time = ncread(Fullname,'time');
        
        % 读取每天3,6,9,12,15,18,21,24时刻的.txt数据
        for d = 1:nd1
            time1 = time(d);
            
            % 输入文件
            timeinput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            timeinput1 = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mm/dd/yyyy-HH');
            outputname1 = strcat(outpath1, Basename1, timeinput, '.txt');
            data_load = load(outputname1);
            data_all5 = [data_all5, data_load];% 注意这里用","
        end
    end
end

%% (6) 从CMFD数据库中的BCPr（修正后的降雨）的.nc文件中提取所需区域的.nc文件
for i = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(i,100)~= 0 && rem(i,4) == 0 )|| (rem(i,100) == 0 && rem(i,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for j = MONTH_BEG:MONTH_END        
        
        % 读取文件部分
        PATH = strcat(ncPATH,'Data_derived_03hr_010deg\BCPr\');
        Basename = 'bcpr_ITPCAS-CMFD_V0106_B-01_03hr_010deg_';
        if j < 10
            Rname = num2str('0');
        else
            Rname = num2str(' ' );
        end
        Monthname = strcat(num2str(i), Rname, num2str(j));
        Filename = strcat(PATH,Basename, Monthname);
        Fullname = strcat(Filename,'.nc');
       
        switch j
            case 1
                nd = MONTHDAY(1)*TIME_RESO;
            case 2 
                nd = MONTHDAY(2)*TIME_RESO;
            case 3
                nd = MONTHDAY(3)*TIME_RESO;
            case 4
                nd = MONTHDAY(4)*TIME_RESO;
            case 5
                nd = MONTHDAY(5)*TIME_RESO;
            case 6
                nd = MONTHDAY(6)*TIME_RESO;
            case 7
                nd = MONTHDAY(7)*TIME_RESO;
            case 8
                nd = MONTHDAY(8)*TIME_RESO;
            case 9
                nd = MONTHDAY(9)*TIME_RESO;
            case 10
                nd = MONTHDAY(10)*TIME_RESO;
            case 11
                nd = MONTHDAY(11)*TIME_RESO;
            case 12
                nd = MONTHDAY(12)*TIME_RESO;                
        end
        
        % 读气象nc文件，并获取所需区域数据
        data = ncread(Fullname,'bcpr',REGION_START,REGION_COUNT,REGION_SRIDE);
        % 读气象nc文件，并获取数据的时间
        time = ncread(Fullname,'time');
        
        % 读取每天3,6,9,12,15,18,21,24时刻的数据
        for d = 1:nd
            data1 = data(:,:,d);
            time1 = time(d);
            
            % 输出文件的命名
            timeoutput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            Basename1 = 'bcpr_';            
            outputname = strcat(outpath1, Basename1, timeoutput, '.txt');            
           
            % 将数据输出到.txt文件中
            fid = fopen(outputname,'wt');            
            fprintf(fid,'%f\n',data1);            
            fclose(fid);
        end
    end
end

% 读取裁剪出来的区域的3h数据，重新按照站点输出
data_all6 = [];
for yy = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(yy,100)~= 0 && rem(yy,4) == 0 )|| (rem(yy,100) == 0 && rem(yy,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for m = MONTH_BEG:MONTH_END
        
        % 读取文件部分
        PATH = strcat(ncPATH,'Data_forcing_03hr_010deg\Temp\');% 存放CMFD的文件夹
        Basename = 'temp_ITPCAS-CMFD_V0106_B-01_03hr_010deg_';
        if m < 10
            Rname = num2str('0');
        else
            Rname = num2str(' ' );
        end
        Monthname = strcat(num2str(yy), Rname, num2str(m));
        Filename = strcat(PATH,Basename, Monthname);
        Fullname = strcat(Filename,'.nc');
        
        switch m
            case 1
                nd1 = MONTHDAY(1)*TIME_RESO;
            case 2 % 闰年需要改一下
                nd1 = MONTHDAY(2)*TIME_RESO;
            case 3
                nd1 = MONTHDAY(3)*TIME_RESO;
            case 4
                nd1 = MONTHDAY(4)*TIME_RESO;
            case 5
                nd1 = MONTHDAY(5)*TIME_RESO;
            case 6
                nd1 = MONTHDAY(6)*TIME_RESO;
            case 7
                nd1 = MONTHDAY(7)*TIME_RESO;
            case 8
                nd1 = MONTHDAY(8)*TIME_RESO;
            case 9
                nd1 = MONTHDAY(9)*TIME_RESO;
            case 10
                nd1 = MONTHDAY(10)*TIME_RESO;
            case 11
                nd1 = MONTHDAY(11)*TIME_RESO;
            case 12
                nd1 = MONTHDAY(12)*TIME_RESO;
        end
        
        % 读气象nc文件，并获取所需区域数据，ncread(source,varname,start,count,stride)，用HDF Explorer可以查看区域起始的经纬度
        data = ncread(Fullname,'temp',REGION_START,REGION_COUNT,REGION_SRIDE);
        % 读气象nc文件，并获取数据的时间
        time = ncread(Fullname,'time');
        
        % 读取每天3,6,9,12,15,18,21,24时刻的.txt数据
        for d = 1:nd1
            time1 = time(d);
            
            % 输入文件
            timeinput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            timeinput1 = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mm/dd/yyyy-HH');
            outputname1 = strcat(outpath1, Basename1, timeinput, '.txt');
            data_load = load(outputname1);
            data_all6 = [data_all6, data_load];% 注意这里用","
        end
    end
end

%% (7) 从CMFD数据库中的Pres的.nc文件中提取所需区域的.nc文件
% 气压单位，Pa
for i = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(i,100)~= 0 && rem(i,4) == 0 )|| (rem(i,100) == 0 && rem(i,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for j = MONTH_BEG:MONTH_END        
        
        % 读取文件部分
        PATH = strcat(ncPATH,'Data_forcing_03hr_010deg\Pres\');
        Basename = 'pres_ITPCAS-CMFD_V0106_B-01_03hr_010deg_';
        if j < 10
            Rname = num2str('0');
        else
            Rname = num2str(' ' );
        end
        Monthname = strcat(num2str(i), Rname, num2str(j));
        Filename = strcat(PATH,Basename, Monthname);
        Fullname = strcat(Filename,'.nc');
       
        switch j
            case 1
                nd = MONTHDAY(1)*TIME_RESO;
            case 2 
                nd = MONTHDAY(2)*TIME_RESO;
            case 3
                nd = MONTHDAY(3)*TIME_RESO;
            case 4
                nd = MONTHDAY(4)*TIME_RESO;
            case 5
                nd = MONTHDAY(5)*TIME_RESO;
            case 6
                nd = MONTHDAY(6)*TIME_RESO;
            case 7
                nd = MONTHDAY(7)*TIME_RESO;
            case 8
                nd = MONTHDAY(8)*TIME_RESO;
            case 9
                nd = MONTHDAY(9)*TIME_RESO;
            case 10
                nd = MONTHDAY(10)*TIME_RESO;
            case 11
                nd = MONTHDAY(11)*TIME_RESO;
            case 12
                nd = MONTHDAY(12)*TIME_RESO;                
        end
        
        % 读气象nc文件，并获取所需区域数据
        data = ncread(Fullname,'pres',REGION_START,REGION_COUNT,REGION_SRIDE);
        % 读气象nc文件，并获取数据的时间
        time = ncread(Fullname,'time');
        
        % 读取每天3,6,9,12,15,18,21,24时刻的数据
        for d = 1:nd
            data1 = data(:,:,d);
            time1 = time(d);
            
            % 输出文件的命名
            timeoutput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            Basename1 = 'pres_';            
            outputname = strcat(outpath1, Basename1, timeoutput, '.txt');            
           
            % 将数据输出到.txt文件中
            fid = fopen(outputname,'wt');            
            fprintf(fid,'%f\n',data1);            
            fclose(fid);
        end
    end
end

% 读取裁剪出来的区域的3h数据，重新按照站点输出
data_all7 = [];
for yy = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(yy,100)~= 0 && rem(yy,4) == 0 )|| (rem(yy,100) == 0 && rem(yy,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for m = MONTH_BEG:MONTH_END
        
        % 读取文件部分
        PATH = strcat(ncPATH,'Data_forcing_03hr_010deg\Temp\');% 存放CMFD的文件夹
        Basename = 'temp_ITPCAS-CMFD_V0106_B-01_03hr_010deg_';
        if m < 10
            Rname = num2str('0');
        else
            Rname = num2str(' ' );
        end
        Monthname = strcat(num2str(yy), Rname, num2str(m));
        Filename = strcat(PATH,Basename, Monthname);
        Fullname = strcat(Filename,'.nc');
        
        switch m
            case 1
                nd1 = MONTHDAY(1)*TIME_RESO;
            case 2 % 闰年需要改一下
                nd1 = MONTHDAY(2)*TIME_RESO;
            case 3
                nd1 = MONTHDAY(3)*TIME_RESO;
            case 4
                nd1 = MONTHDAY(4)*TIME_RESO;
            case 5
                nd1 = MONTHDAY(5)*TIME_RESO;
            case 6
                nd1 = MONTHDAY(6)*TIME_RESO;
            case 7
                nd1 = MONTHDAY(7)*TIME_RESO;
            case 8
                nd1 = MONTHDAY(8)*TIME_RESO;
            case 9
                nd1 = MONTHDAY(9)*TIME_RESO;
            case 10
                nd1 = MONTHDAY(10)*TIME_RESO;
            case 11
                nd1 = MONTHDAY(11)*TIME_RESO;
            case 12
                nd1 = MONTHDAY(12)*TIME_RESO;
        end
        
        % 读气象nc文件，并获取所需区域数据，ncread(source,varname,start,count,stride)，用HDF Explorer可以查看区域起始的经纬度
        data = ncread(Fullname,'temp',REGION_START,REGION_COUNT,REGION_SRIDE);
        % 读气象nc文件，并获取数据的时间
        time = ncread(Fullname,'time');
        
        % 读取每天3,6,9,12,15,18,21,24时刻的.txt数据
        for d = 1:nd1
            time1 = time(d);
            
            % 输入文件
            timeinput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            timeinput1 = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mm/dd/yyyy-HH');
            outputname1 = strcat(outpath1, Basename1, timeinput, '.txt');
            data_load = load(outputname1);
            data_all7 = [data_all7, data_load];% 注意这里用","
        end
    end
end

%% convert q to Rh
% Humidity in the .nc file is Specific humidity (比湿q), while DHSVM input requires relative humidity (Rh,%)
% q = 0.622*Rh*e_s/P ,where e_s is saturation vapor pressure(hPa),水汽的密度约相当于同温同压下干空气的0.622倍
% e_s = 6.1078*10^(7.5T/(237+T)), T unit:℃

[nrows,ncols]= size(data_all3);
Rh = zeros(nrows,ncols);
for row = 1:nrows
    for col = 1:ncols
        Rh(row,col) = 100*(data_all3(row,col)*data_all7(row,col)/100)/(0.622*6.1078*10^(7.5*(data_all1(row,col)-273.15)/(237+(data_all1(row,col)-273.15))));
        if Rh(row,col)>100
            Rh(row,col) = 100;
        end
    end
end

%% 将数据输出到.txt文件中

% 读气象nc文件，并获取区域的经度
longitude = ncread(Fullname,'lon', REGION_START(1), REGION_COUNT(1));
% 读气象nc文件，并获取区域的纬度
latitude = ncread(Fullname,'lat', REGION_START(2), REGION_COUNT(2));
[nrows,ncols]= size(data_all3);
lonlat_file = [];

% 判断文件夹是否存在，如果不存在则创建
if ~exist(outpath_final,'dir')
    mkdir(outpath_final)
end

% 创建staion的坐标（经纬度）列表
for ii = 1:length(latitude)
    for jj = 1:length(longitude)
        lonlat_output = strcat(num2str(longitude(jj)),'_',num2str(latitude(ii)));
        lonlat_file = [lonlat_file;lonlat_output];% 注意，用分号
    end
end

% 写入station文件
for row = 1:nrows % number of station
    inputname = strcat(outpath_final, 'tangsh', lonlat_file(row,:), '.txt');
    
    % 判断文件是否存在，如果存在则删掉
    if (exist(inputname,'file')>0)
        delete(inputname)
    end
    
    for col = 1:ncols % 8*days
        % 追加写入
        % 气象数据的顺序：Tair(℃), Wind(m/s), Rh(%), Sin(W m^-2), Lin(W m^-2), Precip(m)
        fid1 = fopen(inputname,'at');
        fprintf(fid1,'%s %.3f %.3f %.3f %.3f %.3f %f\n', time_all(col,:), data_all1(row,col)-273.15, data_all2(row,col),...
            Rh(row,col), data_all4(row,col), data_all5(row,col), data_all6(row,col)/1000);
        fclose(fid1);
    end
    
end

% rmdir(outpath,'s') %删除计算过程产生的中间文件
