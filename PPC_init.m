% PPC_init

%% used for cluster runs of the PPC_comparison script.  Paths and parameters are put into a cfg struct here.  

addpath('/dartfs-hpc/rc/home/r/f00287r/Code/EC_NVHL')

addpath('/dartfs-hpc/rc/home/r/f00287r/Code/fieldtrip')
ft_defaults

cfg_in = [];
cfg_in.dataset = {'CSC8.ncs','CSC24.ncs','CSC30.ncs'};
cfg_in.data_dir = '/dartfs-hpc/rc/lab/M/MeerM/EC/R111-2017-06-20-Rec_auto for Eroc'; 
cfg_in.inter_dir = '/dartfs-hpc/rc/lab/M/MeerM/EC/R111-2017-06-20-Rec_auto for Eroc'; 
cfg_in.phase = 1; % corresponds to the first recording phase ('pre').  2 = 'task', 3 = 'post'.
cfg_in.shuffle = 100; 
cfg_in.plot = 1;
cfg_in.min_nSpikes = 500; 


PPC_comparison(cfg_in); 