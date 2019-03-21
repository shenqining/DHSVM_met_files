% Reformat data downloaded from GHCN(Global Historical Climatology
% Network)-Daily to requirement of "grid_data/stationdata/"
% Data link: https://gis.ncdc.noaa.gov/maps/ncei/cdo/daily
% Qining Shen, Feb.20, 2019
% 输出的文件要手动替换一下表头
% PRCP

clc;
clear;

PATH = 'E:\USclimate\NOAA\';% Location of downloaded GHCN data
FILENAME = strcat(PATH, 'all_sqnname', '.xlsx');
InputStation = 'E:\USclimate\NOAA\stations.xlsx';
OutputFormat = 'E:\DHSVM\grid_data\stationdata\stationdata\wa\output_head.xlsx';
OutputFile = 'E:\DHSVM\grid_data\stationdata\stationdata\pa\prcp\pa_prcp_dat.txt';
OutputFile_stn = 'E:\DHSVM\grid_data\stationdata\stationdata\pa\prcp\pa_prcp_stn.txt';
[In_Data,In_DataText,In_DataCell] = xlsread(FILENAME);
[In_Stn,In_StnText,In_StnCell] = xlsread(InputStation);
In_DataCell(:,2) = strrep(In_DataCell(:,2),',','');
[Out_Data,Out_DataText,Out_DataCell] = xlsread(OutputFormat);
InputHead = In_DataCell(1,:);
OutputHead_1 = Out_DataCell(1,:);
OutputHead_2 = Out_DataCell(2,:);
In_DataCell(1,:) = [];
PRCP_col = 17;
TIME_col = 6;
[tmp, I] = unique(In_DataCell(:,1), 'first');
STATION = In_DataCell(I,:);
ELEM = 'PRCP';
UN = 'HI';
Blank = 'blank';
MissingFlag = 'M';

%% Store data according to station

for i = 1:length(STATION(:,1))
    Cell_station{i} = In_DataCell((strcmp(In_DataCell(:,1),STATION(i,1))),:);
end

%% Fill up the missing data

% for ii = 1:length(STATION)
for ii = 1:length(STATION)
    disp(ii);
    if isnan(cell2mat(Cell_station{ii}(1,PRCP_col)))~= 1
        data_output_1 = cell2mat(Cell_station{ii}(1,PRCP_col));
    else
        data_output_1 = -9999; % 因为之后要用到的int16的范围是[-32768,32767]
    end
    time_output_1 = Cell_station{ii}(1,TIME_col);
    
    for jj = 2:length(Cell_station{ii}(:,1))
        
        current_date = datenum(Cell_station{ii}(jj,TIME_col));
        pre_date = datenum(Cell_station{ii}(jj - 1,TIME_col));
        if pre_date ~= current_date - 1
            missing_number = current_date - pre_date - 1;
            for kk = 1:missing_number
                data_output_1 = [data_output_1; -9999];
                time_output_1 = [time_output_1; datestr(pre_date + kk, 'yyyy/mm/dd')];
            end
            if jj > 1
                data_output_1 = [data_output_1; cell2mat(Cell_station{ii}(jj, PRCP_col))];
                time_output_1 = [time_output_1; datestr(current_date, 'yyyy/mm/dd')];
            end
        elseif pre_date == current_date - 1
            data_output_1 = [data_output_1; cell2mat(Cell_station{ii}(jj, PRCP_col))];
            time_output_1 = [time_output_1; datestr(current_date, 'yyyy/mm/dd')];
        end
    end
    Station_filled{ii,1} = time_output_1;
    Station_filled{ii,2} = data_output_1;
end

%% Reformat data according to station
output = [];
% for aa = 1:length(STATION)
for aa = 1:length(STATION)
    disp(aa);
    row = 1;
    number_row = (year(Station_filled{aa,1}(end,1)) - year(Station_filled{aa,1}(1,1)) - 1) * 12 + ...
        month(Station_filled{aa,1}(end,1)) + (12 - month(Station_filled{aa,1}(1,1)) + 1);
    format_DSET = ones(number_row,1) * 9999;
    format_WBNID = ones(number_row,1) * 99999;
    format_CD = ones(number_row,1) * 99;        
    data_reformat = ones(number_row,31) * nan;
    format_yymm = ones(number_row,1) * nan;
    format_DAHR = ones(number_row,31) * 23; % DAHR is DAY OF MONTH and HOUR OF OBSERVATION,Hour of
                                            % observation is reported using the 24-hour clock with 
                                            % values ranging from 00-23
                                            % LST. The '23' here is a arbitrary value.
    
    %%% The fisrt element in each column %%%
    format_station = STATION(aa,1);
    format_name = STATION(aa,2);
    data_reformat(1,1) = Station_filled{aa,2}(1,1);    
    format_ELEM = ELEM;
    format_UN = UN;
    format_Blank = Blank;
    first_yy = year(Station_filled{aa,1}(1,1));
    first_mm = month(Station_filled{aa,1}(1,1));    
    if first_mm < 10
        Rname = num2str('0');
    else
        Rname = num2str('');
    end
    format_yymm(1,1) = str2double(strcat(num2str(first_yy), Rname, num2str(first_mm)));
    
    %%% reformat data into 31 columns %%%
    for bb = 2:length(Station_filled{aa,1}(:,1))
        current_month = month(Station_filled{aa,1}(bb,1));
        pre_month = month(Station_filled{aa,1}(bb - 1,1));
        col = day(Station_filled{aa,1}(bb,1));
        
        if current_month == pre_month
            data_reformat(row,col) = Station_filled{aa,2}(bb,1);            
        else
            row = row + 1;
            data_reformat(row,col) = Station_filled{aa,2}(bb,1);
            Stn_yy = year(Station_filled{aa,1}(bb,1));
            Stn_mm = month(Station_filled{aa,1}(bb,1));
            if current_month < 10
                Rname = num2str('0');
            else
                Rname = num2str('');
            end
            format_yymm(row,1) = str2double(strcat(num2str(Stn_yy), Rname, num2str(Stn_mm))); 
            format_station = [format_station; STATION(aa,1)];
            format_name = [format_name; STATION(aa,2)];
            format_ELEM = [format_ELEM; ELEM];
            format_UN = [format_UN; UN];
            format_Blank = [format_Blank; Blank];
        end
    end
    %%% Convert data format from num to str
    data_reformat(isnan(data_reformat)) = -9999;
    data_reformat = 100 * int32(data_reformat);
    data_reformat(data_reformat < -1000) = -99999;
    
    for cc = 1:31
        format_DAHR(:,cc) = cc * 100 + format_DAHR(:,cc);
    end
      
    format_data = [];
    for dd = 1:31
        format_data = [format_data, cellstr(num2str(format_DAHR(:,dd), '%04d')), cellstr(num2str(data_reformat(:,dd), '%05d')), ...
            strrep(cellstr(format_Blank),'blank',' '), strrep(cellstr(format_Blank),'blank',' ')];
    end
    
    %%% Output data according to requirement of "grid_data/stationdata/"
    output_tmp = table(format_DSET, format_station, format_WBNID, format_name, format_CD, format_ELEM, ...
        format_UN, format_yymm, format_data);
    output = [output; output_tmp];
end
    
writetable(output,OutputFile);

%% Output station file

output_stn = table(In_StnCell(:,11), In_StnCell(:,14), In_StnCell(:,16), In_StnCell(:,7), In_StnCell(:,13), ...
    In_StnCell(:,15), In_StnCell(:,12), In_StnCell(:,8), In_StnCell(:,9), In_StnCell(:,10));
writetable(output_stn,OutputFile_stn, 'Delimiter',' ');

                
                
