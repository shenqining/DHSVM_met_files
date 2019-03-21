% ��China Meteorological Forcing Dataset(CMFD)���ݿ��е�.nc�ļ�����ȡ��ɽ�����.nc�ļ�����ת����.txt��ΪDHSVM������
% Qining Shen, Aug.24, 2018
% �������ݵ�˳����ReadMetRecord.c��Array[ ]����Բ鿴��Tair, Wind, Rh, Sin, Lin, Precip��

%% ���õ���Χ������������Ӧң������ά�ȴ�С�������������������ļ���
clc;
clear;
LON_LEFT = 117.95;LON_RIGHT = 118.65;                                      % ��HDF Explorer���Բ鿴������ʼ�ľ�γ��
LAT_SOUTH = 39.45;LAT_NORTH = 40.15;                                       % ��HDF Explorer���Բ鿴������ʼ�ľ�γ��
TIME_RESO = 8;                                                             % ʱ�侫�ȣ�24/3h = 8
STARTDATE = '01-Jan-1900 00:00:30';                                        % CMFD������ʱ���1900-01-01 00:00:0.0����3�룬���Լ��˸�3��
ONE_HOUR = datenum('01-Jan-1900 01:00:00')-datenum('01-Jan-1900 00:00:00');% CMFD���ݵ�ʱ����hours since 1900-01-01 00:00:0.0
MONTHDAY1 = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];              % common year
MONTHDAY2 = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];              % leap year
YEAR_BEG = 1980;
YEAR_END = 2015;
MONTH_BEG = 1;
MONTH_END = 12;
REGION_START = [480 245 1];                                                % ��ʾlon,lat,time�ֱ�ӵ�480����245����1������ʼ�����������HDF Explorer�鿴λ��
REGION_COUNT = [8 8 inf];                                                  % ��ʾlon,lat����8����time�������һ��(inf)
REGION_SRIDE = [1 1 1];                                                    % ������ȱʡֵΪ1
ncPATH = 'H:\westdc\';                                                     % ���CMFD���ļ���
outpath = 'E:\DHSVM\SQN\Tangshan\metinput';                                % ����Ǽ�����̵��м��ļ��У��������ɾ��������������վ�������Ҫ��"\"
outpath1 = strcat(outpath, '\');
outpath_final = 'E:\DHSVM\SQN\Tangshan\metfile\';                          % ��Ž���������ļ���

%% �ж��ļ����Ƿ���ڣ�����������򴴽�
if ~exist(outpath,'dir')
    mkdir(outpath)
end

%% (1) ��CMFD���ݿ��е�Temp��.nc�ļ�����ȡ���������.nc�ļ�
for i = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(i,100)~= 0 && rem(i,4) == 0 )|| (rem(i,100) == 0 && rem(i,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for j = MONTH_BEG:MONTH_END        
        
        % ��ȡ�ļ�����
        PATH = strcat(ncPATH,'Data_forcing_03hr_010deg\Temp\');% ���CMFD���ļ���
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
        
        % ������nc�ļ�������ȡ�����������ݣ�ncread(source,varname,start,count,stride)����HDF Explorer���Բ鿴������ʼ�ľ�γ��
        data = ncread(Fullname,'temp',REGION_START,REGION_COUNT,REGION_SRIDE); 
        % ������nc�ļ�������ȡ���ݵ�ʱ��
        time = ncread(Fullname,'time');
        
        % ��ȡÿ��3,6,9,12,15,18,21,24ʱ�̵�����
        for d = 1:nd
            data1 = data(:,:,d);
            time1 = time(d);
         
            % ����ļ�������
            timeoutput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            Basename1 = 'temp_';
            outputname = strcat(outpath1, Basename1, timeoutput, '.txt');
            
            % �����������.txt�ļ���
            fid = fopen(outputname,'wt');
            fprintf(fid,'%f\n',data1);
            fclose(fid);
        end
    end
end

% ��ȡ�ü������������Temp 3h���ݣ����°���վ�����
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
        
        % ��ȡ�ļ�����
        PATH = strcat(ncPATH,'Data_forcing_03hr_010deg\Temp\');% ���CMFD���ļ���
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
            case 2 % ������Ҫ��һ��
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
        
        % ������nc�ļ�������ȡ�����������ݣ�ncread(source,varname,start,count,stride)����HDF Explorer���Բ鿴������ʼ�ľ�γ��
        data = ncread(Fullname,'temp',REGION_START,REGION_COUNT,REGION_SRIDE); 
        % ������nc�ļ�������ȡ���ݵ�ʱ��
        time = ncread(Fullname,'time');
        
        % ��ȡÿ��3,6,9,12,15,18,21,24ʱ�̵�.txt����
        for d = 1:nd1
            time1 = time(d);
            
            % �����ļ�
            timeinput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            timeinput1 = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mm/dd/yyyy-HH');
            outputname1 = strcat(outpath1, Basename1, timeinput, '.txt');
            data_load = load(outputname1);
            data_all1 = [data_all1, data_load];% ע��������","
            time_all = [time_all; timeinput1];% ע��������";"
        end
    end
end

%% (2) ��CMFD���ݿ��е�Wind��.nc�ļ�����ȡ���������.nc�ļ�
for i = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(i,100)~= 0 && rem(i,4) == 0 )|| (rem(i,100) == 0 && rem(i,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for j = MONTH_BEG:MONTH_END        
        
        % ��ȡ�ļ�����
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
        
        % ������nc�ļ�������ȡ������������
        data = ncread(Fullname,'wind',REGION_START,REGION_COUNT,REGION_SRIDE);
        % ������nc�ļ�������ȡ���ݵ�ʱ��
        time = ncread(Fullname,'time');
        
        % ��ȡÿ��3,6,9,12,15,18,21,24ʱ�̵�����
        for d = 1:nd
            data1 = data(:,:,d);
            time1 = time(d);
            
            % ����ļ�������
            timeoutput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            Basename1 = 'wind_';            
            outputname = strcat(outpath1, Basename1, timeoutput, '.txt');            
           
            % �����������.txt�ļ���
            fid = fopen(outputname,'wt');            
            fprintf(fid,'%f\n',data1);            
            fclose(fid);
        end
    end
end

% ��ȡ�ü������������3h���ݣ����°���վ�����
data_all2 = [];
for yy = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(yy,100)~= 0 && rem(yy,4) == 0 )|| (rem(yy,100) == 0 && rem(yy,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for m = MONTH_BEG:MONTH_END
        
        % ��ȡ�ļ�����
        PATH = strcat(ncPATH,'Data_forcing_03hr_010deg\Temp\');% ���CMFD���ļ���
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
            case 2 % ������Ҫ��һ��
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
        
        % ������nc�ļ�������ȡ�����������ݣ�ncread(source,varname,start,count,stride)����HDF Explorer���Բ鿴������ʼ�ľ�γ��
        data = ncread(Fullname,'temp',REGION_START,REGION_COUNT,REGION_SRIDE);
        % ������nc�ļ�������ȡ���ݵ�ʱ��
        time = ncread(Fullname,'time');
        
        % ��ȡÿ��3,6,9,12,15,18,21,24ʱ�̵�.txt����
        for d = 1:nd1
            time1 = time(d);
            
            % �����ļ�
            timeinput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            timeinput1 = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mm/dd/yyyy-HH');
            outputname1 = strcat(outpath1, Basename1, timeinput, '.txt');
            data_load = load(outputname1);
            data_all2 = [data_all2, data_load];% ע��������","
        end
    end
end

%% (3) ��CMFD���ݿ��е�Shum��.nc�ļ�����ȡ���������.nc�ļ�
% ʪ�ȵĵ�λ��Specific humidity����ʪ���������ʱ����Ҫת�������ʪ�ȣ���L1051
for i = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(i,100)~= 0 && rem(i,4) == 0 )|| (rem(i,100) == 0 && rem(i,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for j = MONTH_BEG:MONTH_END        
        
        % ��ȡ�ļ�����
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
        
        % ������nc�ļ�������ȡ������������
        data = ncread(Fullname,'shum',REGION_START,REGION_COUNT,REGION_SRIDE);
        % ������nc�ļ�������ȡ���ݵ�ʱ��
        time = ncread(Fullname,'time');
        
        % ��ȡÿ��3,6,9,12,15,18,21,24ʱ�̵�����
        for d = 1:nd
            data1 = data(:,:,d);
            time1 = time(d);
            
            % ����ļ�������
            timeoutput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            Basename1 = 'shum_';            
            outputname = strcat(outpath1, Basename1, timeoutput, '.txt');            
           
            % �����������.txt�ļ���
            fid = fopen(outputname,'wt');            
            fprintf(fid,'%f\n',data1);            
            fclose(fid);
        end
    end
end

% ��ȡ�ü������������3h���ݣ����°���վ�����
data_all3 = [];
for yy = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(yy,100)~= 0 && rem(yy,4) == 0 )|| (rem(yy,100) == 0 && rem(yy,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for m = MONTH_BEG:MONTH_END
        
        % ��ȡ�ļ�����
        PATH = strcat(ncPATH,'Data_forcing_03hr_010deg\Temp\');% ���CMFD���ļ���
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
            case 2 % ������Ҫ��һ��
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
        
        % ������nc�ļ�������ȡ�����������ݣ�ncread(source,varname,start,count,stride)����HDF Explorer���Բ鿴������ʼ�ľ�γ��
        data = ncread(Fullname,'temp',REGION_START,REGION_COUNT,REGION_SRIDE);
        % ������nc�ļ�������ȡ���ݵ�ʱ��
        time = ncread(Fullname,'time');
        
        % ��ȡÿ��3,6,9,12,15,18,21,24ʱ�̵�.txt����
        for d = 1:nd1
            time1 = time(d);
            
            % �����ļ�
            timeinput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            timeinput1 = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mm/dd/yyyy-HH');
            outputname1 = strcat(outpath1, Basename1, timeinput, '.txt');
            data_load = load(outputname1);
            data_all3 = [data_all3, data_load];% ע��������","
        end
    end
end

%% (4) ��CMFD���ݿ��е�SRad��.nc�ļ�����ȡ���������.nc�ļ�
for i = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(i,100)~= 0 && rem(i,4) == 0 )|| (rem(i,100) == 0 && rem(i,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for j = MONTH_BEG:MONTH_END        
        
        % ��ȡ�ļ�����
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
        
        % ������nc�ļ�������ȡ������������
        data = ncread(Fullname,'srad',REGION_START,REGION_COUNT,REGION_SRIDE);
        % ������nc�ļ�������ȡ���ݵ�ʱ��
        time = ncread(Fullname,'time');
        
        % ��ȡÿ��3,6,9,12,15,18,21,24ʱ�̵�����
        for d = 1:nd
            data1 = data(:,:,d);
            time1 = time(d);
            
            % ����ļ�������
            timeoutput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            Basename1 = 'srad_';            
            outputname = strcat(outpath1, Basename1, timeoutput, '.txt');            
           
            % �����������.txt�ļ���
            fid = fopen(outputname,'wt');            
            fprintf(fid,'%f\n',data1);            
            fclose(fid);
        end
    end
end

% ��ȡ�ü������������3h���ݣ����°���վ�����
data_all4 = [];
for yy = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(yy,100)~= 0 && rem(yy,4) == 0 )|| (rem(yy,100) == 0 && rem(yy,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for m = MONTH_BEG:MONTH_END
        
        % ��ȡ�ļ�����
        PATH = strcat(ncPATH,'Data_forcing_03hr_010deg\Temp\');% ���CMFD���ļ���
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
            case 2 % ������Ҫ��һ��
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
        
        % ������nc�ļ�������ȡ�����������ݣ�ncread(source,varname,start,count,stride)����HDF Explorer���Բ鿴������ʼ�ľ�γ��
        data = ncread(Fullname,'temp',REGION_START,REGION_COUNT,REGION_SRIDE);
        % ������nc�ļ�������ȡ���ݵ�ʱ��
        time = ncread(Fullname,'time');
        
        % ��ȡÿ��3,6,9,12,15,18,21,24ʱ�̵�.txt����
        for d = 1:nd1
            time1 = time(d);
            
            % �����ļ�
            timeinput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            timeinput1 = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mm/dd/yyyy-HH');
            outputname1 = strcat(outpath1, Basename1, timeinput, '.txt');
            data_load = load(outputname1);
            data_all4 = [data_all4, data_load];% ע��������","
        end
    end
end

%% (5) ��CMFD���ݿ��е�LRad��.nc�ļ�����ȡ���������.nc�ļ�
for i = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(i,100)~= 0 && rem(i,4) == 0 )|| (rem(i,100) == 0 && rem(i,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for j = MONTH_BEG:MONTH_END        
        
        % ��ȡ�ļ�����
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
        
        % ������nc�ļ�������ȡ������������
        data = ncread(Fullname,'lrad',REGION_START,REGION_COUNT,REGION_SRIDE);
        % ������nc�ļ�������ȡ���ݵ�ʱ��
        time = ncread(Fullname,'time');
        
        % ��ȡÿ��3,6,9,12,15,18,21,24ʱ�̵�����
        for d = 1:nd
            data1 = data(:,:,d);
            time1 = time(d);
            
            % ����ļ�������
            timeoutput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            Basename1 = 'lrad_';            
            outputname = strcat(outpath1, Basename1, timeoutput, '.txt');            
           
            % �����������.txt�ļ���
            fid = fopen(outputname,'wt');            
            fprintf(fid,'%f\n',data1);            
            fclose(fid);
        end
    end
end

% ��ȡ�ü������������3h���ݣ����°���վ�����
data_all5 = [];
for yy = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(yy,100)~= 0 && rem(yy,4) == 0 )|| (rem(yy,100) == 0 && rem(yy,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for m = MONTH_BEG:MONTH_END
        
        % ��ȡ�ļ�����
        PATH = strcat(ncPATH,'Data_forcing_03hr_010deg\Temp\');% ���CMFD���ļ���
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
            case 2 % ������Ҫ��һ��
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
        
        % ������nc�ļ�������ȡ�����������ݣ�ncread(source,varname,start,count,stride)����HDF Explorer���Բ鿴������ʼ�ľ�γ��
        data = ncread(Fullname,'temp',REGION_START,REGION_COUNT,REGION_SRIDE);
        % ������nc�ļ�������ȡ���ݵ�ʱ��
        time = ncread(Fullname,'time');
        
        % ��ȡÿ��3,6,9,12,15,18,21,24ʱ�̵�.txt����
        for d = 1:nd1
            time1 = time(d);
            
            % �����ļ�
            timeinput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            timeinput1 = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mm/dd/yyyy-HH');
            outputname1 = strcat(outpath1, Basename1, timeinput, '.txt');
            data_load = load(outputname1);
            data_all5 = [data_all5, data_load];% ע��������","
        end
    end
end

%% (6) ��CMFD���ݿ��е�BCPr��������Ľ��꣩��.nc�ļ�����ȡ���������.nc�ļ�
for i = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(i,100)~= 0 && rem(i,4) == 0 )|| (rem(i,100) == 0 && rem(i,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for j = MONTH_BEG:MONTH_END        
        
        % ��ȡ�ļ�����
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
        
        % ������nc�ļ�������ȡ������������
        data = ncread(Fullname,'bcpr',REGION_START,REGION_COUNT,REGION_SRIDE);
        % ������nc�ļ�������ȡ���ݵ�ʱ��
        time = ncread(Fullname,'time');
        
        % ��ȡÿ��3,6,9,12,15,18,21,24ʱ�̵�����
        for d = 1:nd
            data1 = data(:,:,d);
            time1 = time(d);
            
            % ����ļ�������
            timeoutput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            Basename1 = 'bcpr_';            
            outputname = strcat(outpath1, Basename1, timeoutput, '.txt');            
           
            % �����������.txt�ļ���
            fid = fopen(outputname,'wt');            
            fprintf(fid,'%f\n',data1);            
            fclose(fid);
        end
    end
end

% ��ȡ�ü������������3h���ݣ����°���վ�����
data_all6 = [];
for yy = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(yy,100)~= 0 && rem(yy,4) == 0 )|| (rem(yy,100) == 0 && rem(yy,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for m = MONTH_BEG:MONTH_END
        
        % ��ȡ�ļ�����
        PATH = strcat(ncPATH,'Data_forcing_03hr_010deg\Temp\');% ���CMFD���ļ���
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
            case 2 % ������Ҫ��һ��
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
        
        % ������nc�ļ�������ȡ�����������ݣ�ncread(source,varname,start,count,stride)����HDF Explorer���Բ鿴������ʼ�ľ�γ��
        data = ncread(Fullname,'temp',REGION_START,REGION_COUNT,REGION_SRIDE);
        % ������nc�ļ�������ȡ���ݵ�ʱ��
        time = ncread(Fullname,'time');
        
        % ��ȡÿ��3,6,9,12,15,18,21,24ʱ�̵�.txt����
        for d = 1:nd1
            time1 = time(d);
            
            % �����ļ�
            timeinput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            timeinput1 = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mm/dd/yyyy-HH');
            outputname1 = strcat(outpath1, Basename1, timeinput, '.txt');
            data_load = load(outputname1);
            data_all6 = [data_all6, data_load];% ע��������","
        end
    end
end

%% (7) ��CMFD���ݿ��е�Pres��.nc�ļ�����ȡ���������.nc�ļ�
% ��ѹ��λ��Pa
for i = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(i,100)~= 0 && rem(i,4) == 0 )|| (rem(i,100) == 0 && rem(i,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for j = MONTH_BEG:MONTH_END        
        
        % ��ȡ�ļ�����
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
        
        % ������nc�ļ�������ȡ������������
        data = ncread(Fullname,'pres',REGION_START,REGION_COUNT,REGION_SRIDE);
        % ������nc�ļ�������ȡ���ݵ�ʱ��
        time = ncread(Fullname,'time');
        
        % ��ȡÿ��3,6,9,12,15,18,21,24ʱ�̵�����
        for d = 1:nd
            data1 = data(:,:,d);
            time1 = time(d);
            
            % ����ļ�������
            timeoutput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            Basename1 = 'pres_';            
            outputname = strcat(outpath1, Basename1, timeoutput, '.txt');            
           
            % �����������.txt�ļ���
            fid = fopen(outputname,'wt');            
            fprintf(fid,'%f\n',data1);            
            fclose(fid);
        end
    end
end

% ��ȡ�ü������������3h���ݣ����°���վ�����
data_all7 = [];
for yy = YEAR_BEG:YEAR_END
    
    % leap year or not
    if (( rem(yy,100)~= 0 && rem(yy,4) == 0 )|| (rem(yy,100) == 0 && rem(yy,400) == 0))
        MONTHDAY = MONTHDAY2;
    else
        MONTHDAY = MONTHDAY1;
    end
    
    for m = MONTH_BEG:MONTH_END
        
        % ��ȡ�ļ�����
        PATH = strcat(ncPATH,'Data_forcing_03hr_010deg\Temp\');% ���CMFD���ļ���
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
            case 2 % ������Ҫ��һ��
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
        
        % ������nc�ļ�������ȡ�����������ݣ�ncread(source,varname,start,count,stride)����HDF Explorer���Բ鿴������ʼ�ľ�γ��
        data = ncread(Fullname,'temp',REGION_START,REGION_COUNT,REGION_SRIDE);
        % ������nc�ļ�������ȡ���ݵ�ʱ��
        time = ncread(Fullname,'time');
        
        % ��ȡÿ��3,6,9,12,15,18,21,24ʱ�̵�.txt����
        for d = 1:nd1
            time1 = time(d);
            
            % �����ļ�
            timeinput = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mmddyyyy-HH');
            timeinput1 = datestr(ONE_HOUR*double(time1) + datenum(STARTDATE),'mm/dd/yyyy-HH');
            outputname1 = strcat(outpath1, Basename1, timeinput, '.txt');
            data_load = load(outputname1);
            data_all7 = [data_all7, data_load];% ע��������","
        end
    end
end

%% convert q to Rh
% Humidity in the .nc file is Specific humidity (��ʪq), while DHSVM input requires relative humidity (Rh,%)
% q = 0.622*Rh*e_s/P ,where e_s is saturation vapor pressure(hPa),ˮ�����ܶ�Լ�൱��ͬ��ͬѹ�¸ɿ�����0.622��
% e_s = 6.1078*10^(7.5T/(237+T)), T unit:��

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

%% �����������.txt�ļ���

% ������nc�ļ�������ȡ����ľ���
longitude = ncread(Fullname,'lon', REGION_START(1), REGION_COUNT(1));
% ������nc�ļ�������ȡ�����γ��
latitude = ncread(Fullname,'lat', REGION_START(2), REGION_COUNT(2));
[nrows,ncols]= size(data_all3);
lonlat_file = [];

% �ж��ļ����Ƿ���ڣ�����������򴴽�
if ~exist(outpath_final,'dir')
    mkdir(outpath_final)
end

% ����staion�����꣨��γ�ȣ��б�
for ii = 1:length(latitude)
    for jj = 1:length(longitude)
        lonlat_output = strcat(num2str(longitude(jj)),'_',num2str(latitude(ii)));
        lonlat_file = [lonlat_file;lonlat_output];% ע�⣬�÷ֺ�
    end
end

% д��station�ļ�
for row = 1:nrows % number of station
    inputname = strcat(outpath_final, 'tangsh', lonlat_file(row,:), '.txt');
    
    % �ж��ļ��Ƿ���ڣ����������ɾ��
    if (exist(inputname,'file')>0)
        delete(inputname)
    end
    
    for col = 1:ncols % 8*days
        % ׷��д��
        % �������ݵ�˳��Tair(��), Wind(m/s), Rh(%), Sin(W m^-2), Lin(W m^-2), Precip(m)
        fid1 = fopen(inputname,'at');
        fprintf(fid1,'%s %.3f %.3f %.3f %.3f %.3f %f\n', time_all(col,:), data_all1(row,col)-273.15, data_all2(row,col),...
            Rh(row,col), data_all4(row,col), data_all5(row,col), data_all6(row,col)/1000);
        fclose(fid1);
    end
    
end

% rmdir(outpath,'s') %ɾ��������̲������м��ļ�
