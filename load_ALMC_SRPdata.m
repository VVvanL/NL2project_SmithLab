% Note: SRPipeline must be in search path
% TODO: rewrite as function in Analysis pre-processing pipeline (include addpath statement)

clearvars

%=========
rootname = 'VGAT488_Geph(3B11)561_Gaba647_002_soma'; % use to use concise file namaing format; optionally - comment out if original file name is to be used
%=========

[file,path] = uigetfile();
% foldparts = strsplit(path,filesep); dirname = foldparts{end-1}; clear foldparts
load([path,file])
if ~exist('rootname','var'); rootname = file(1:end-4); end
acq_dir = [path,rootname,filesep];
if ~exist(acq_dir,'dir'); mkdir(acq_dir); end

%% initiate needed structures
p = struct;     % contains necessary acquisition parameters
data = struct;  % contains necessary localization data

%% define parameters
% short list of acquisition parameters needed for downstream analysis
p.acq.nchannels = obj.acq.nchannels;          % number of channels acquired in experiment
p.Tstorm.camera.pixelsize = obj.Tstorm.camera.pixelsize;  % pixelsize in nm for raw timeseries acquisition
p.image_gen.pixelsize_g = obj.image_gen.pixelsize_g; % pixel size of SR image used to draw ROIs (in nm)

for c = 1:p.acq.nchannels
    c_fld = ['ch' num2str(c)];
    locT = struct2table(obj.SML_data.(c_fld));
    data.(c_fld).colheaders = locT.Properties.VariableNames;
    data.(c_fld).localizations = table2array(locT);
    clear locT
end
save([acq_dir,rootname,'_SMLM.mat'],'p','data')
