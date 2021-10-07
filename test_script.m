script_path = [fileparts(mfilename('fullpath')),filesep];
% foldparts = strsplit(script_path,filesep); script_path = foldparts{end-1}; % clear foldparts;
addpath([script_path,'functions'])