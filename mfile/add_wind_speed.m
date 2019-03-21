% Add wind speed (m/s) into the 'data_LAT_LON' files
% SQN 2019.3.17

clc;
clear;

fileFolder=fullfile('E:\DHSVM\grid_data\stationdata\stationdata\ptt_asc_1');% �ļ�����
dirOutput=dir(fullfile(fileFolder,'*'));% ������ڲ�ͬ���͵��ļ����á�*����ȡ���У������ȡ�ض������ļ���'.'�����ļ����ͣ������á�.jpg��
fileNames={dirOutput.name}';
fileNames([1,2],:) = [];

fileFolder_wind=fullfile('E:\USclimate\Livneh_wind\unzip');% �ļ�����
dirOutput_wind=dir(fullfile(fileFolder_wind,'*'));% ������ڲ�ͬ���͵��ļ����á�*����ȡ���У������ȡ�ض������ļ���'.'�����ļ����ͣ������á�.jpg��
fileNames_wind={dirOutput_wind.name}';
fileNames_wind([1,2],:) = [];

Output_file = 'E:\DHSVM\grid_data\stationdata\stationdata\ptt_wind_asc\';
%%
%i = 1:length(fileNames)
for i = 1:length(fileNames)
    file_name = char(fileNames(i));
    LAT_LON = file_name(6:end);
    input_data = load(strcat(fileFolder,'\', file_name));
    input_wind = load(strcat(fileFolder_wind, '\Meteorology_Livneh_NAmerExt_15Oct2014_', LAT_LON));
    Num_row = datenum('31-Dec-2013') - datenum('1-Jan-1980') + 1;%ptt���ݴ�1980/1/1 - 2015/12/31��Ҫ��ȡ1980-2013��
    Num_row_1 = datenum('1-Jan-1980') - datenum('1-Jan-1950') + 1;%wind���ݴ�1950/1/1 - 2013/12/31
    output_data = [input_data(1:Num_row,:), input_wind(Num_row_1:end,4)];
    
    out_file = char(strcat(Output_file,fileNames(i)));
    fileID = fopen(out_file,'wt+');
    fprintf(fileID,'%10.6f %10.6f %10.6f %10.6f\n',output_data');
    fclose(fileID);
end

