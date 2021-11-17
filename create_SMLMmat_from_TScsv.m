% working script to create SMLM.mat file format from pre-existing ThunderSTORM output
% temporary hack to set up data for downstream cluster/alignment analysis prototyping
% 200205 - drafting initiated
clearvars

dataDir = uigetdir('Select data directory');
foldparts = strsplit(dataDir,filesep); dirname = foldparts{end}; clear foldparts

%% initiate needed structures
p = struct;     %contains all the parameters
data = struct;  %contains all the data
metadata = struct; % contains information needed for channel registration (via ALMC SMLM pipeline module)

%% define parameters
% short list of acquisition parameters needed for downstream analysis
p.acq.nchannels = 2;          % number of channels acquired in experiment
p.Tstorm.camera.pixelsize = 159;  % camera pixelsize in nm
p.image_gen.pixelsize_g = 15.9; % pixel size of SR image used to draw ROIs (in nm)

for c = 1:2
    [csvFile,path] = uigetfile([path,'.csv'],['select filtered TS csv file for ch',num2str(c)]); 
    filepath = [path,csvFile];
    data.(['ch' num2str(c)]) = load_TScsv(filepath);    
    data.(['ch' num2str(c)]).colheaders{1,11} = 'detections';
end
save([dataDir,filesep,dirname,'_SMLM.mat'],'p','data')
