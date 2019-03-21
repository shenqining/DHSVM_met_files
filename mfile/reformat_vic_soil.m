% Replace the 3rd and 4th column (lat and lon) and copy the rest columns
% in the file named "vic.soil.param.bull.run.large.txt", which is a file
% needed to run the disaggregation subroutine in VIC
% 输出的文件要手动替换一下表头
% SQN 2019.3.8

clc;
clear;
vic_soil = load('E:\DHSVM\grid_data\vic_params\vic_params\vic.soil.param.bull.run.large.txt');
OutputFile = 'E:\DHSVM\grid_data\vic_params\sqn\vic.soil.param.bull.run.large.txt';
Number_of_grid = 96;
Number_to_copy = Number_of_grid/2;
New_lonlat = repmat(vic_soil, Number_to_copy, 1);

fileFolder=fullfile('E:\DHSVM\grid_data\stationdata\stationdata\ptt_binary_1');% 文件夹名plane
dirOutput=dir(fullfile(fileFolder,'*'));% 如果存在不同类型的文件，用‘*’读取所有，如果读取特定类型文件，'.'加上文件类型，例如用‘.jpg’
fileNames={dirOutput.name}';
fileNames([1,2],:) = [];

% for i = 1:length(fileNames)
for i = 1:length(fileNames)
    file_name = char(fileNames(i));
    ind = strfind(file_name,'_');
    index_lat = ind(1)+1;
    lat = file_name(index_lat:index_lat + 7);
    index_lon = ind(2)+1;
    lon = file_name(index_lon:end);
    New_lonlat(i,3) = str2double(lat);
    New_lonlat(i,4) = str2double(lon);
end

output = table(New_lonlat);
writetable(output,OutputFile, 'Delimiter',' ');
