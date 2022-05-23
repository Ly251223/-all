clc,clear
namelist = dir('C:\Users\81702\Desktop\battery_dataset\*.mat');
% 读取后namelist 的格式为
% name -- filename
% date -- modification date
% bytes -- number of bytes allocated to the file
% isdir -- 1 if name is a directory and 0 if not

len = length(namelist);
for i = 1:len
    file_name{i} = namelist(i).name; % name of each file
%   x = load(file_name{i});%每次x都会赋新值把原来的替换掉
end

x = load(file_name{i});