%% NVHL_initialize: initialize the default parameters and 

clear all; close all
restoredefaultpath
global PARAMS

if isunix
    PARAMS.data_dir = '/global/scratch/ecarmichael/NVHL/'; % where to find the raw data
    PARAMS.inter_dir = '/global/scratch/ecarmichael/NVHL/temp/'; % where to put intermediate files
    PARAMS.stats_out = '/ihome/jcarmich/NVHL/Stats/'; % where to put the statistical output .txt
    PARAMS.code_base_dir = '/ihome/jcarmich/Code/vandermeerlab/code-matlab/shared'; % where the codebase repo can be found
    PARAMS.code_NVHL_dir = '/ihome/jcarmich/Code/EC_NVHL'; % where the NVHL repo can be found
    PARAMS.code_basic_functions = '/ihome/jcarmich/Code/EC_Multisite/Basic_functions';
    
else
    PARAMS.data_dir = 'G:\JK_recordings\Naris\'; % where to find the raw data
    PARAMS.inter_dir = 'G:\JK_recordings\Naris\NVHL\temp\'; % where to put intermediate files
    PARAMS.stats_out = 'G:\JK_recordings\Naris\NVHL\temp\Stats\'; % where to put the statistical output .txt
    PARAMS.code_base_dir = 'D:\Users\mvdmlab\My_Documents\GitHub\vandermeerlab\code-matlab\shared'; % where the codebase repo can be found
    PARAMS.code_NVHL_dir = 'D:\Users\mvdmlab\My_Documents\GitHub\EC_NVHL'; % where the NVHL repo can be found
    PARAMS.code_basic_functions = '/Users/jericcarmichael/Documents/GitHub/EC_Multisite/Basic_functions';
end

PARAMS.log = fopen([PARAMS.data_dir '/NVHL_log.txt'], 'w');
PARAMS.Phases = {'pot', 'trk'}; % recording phases within each session
PARAMS.Subjects = {'R40258','R40262', 'R40259', 'R40261', 'R40263', 'R40264', 'R40266', 'R40278', 'R40277' }; %list of subjects
PARAMS.Group =    {'NVHL'  , 'NVHL' , 'NVHL'  , 'NVHL'  , 'SHAM'  , 'SHAM'  , 'SHAM'  , 'SHAM'  , 'SHAM'};  % corres
PARAMS.all_sites = {'PL', 'OFC', 'NAc', 'CG'}; 
% add the required code
addpath(genpath(PARAMS.code_base_dir));
addpath(genpath(PARAMS.code_NVHL_dir));
addpath(genpath(PARAMS.code_basic_functions));
cd(PARAMS.data_dir) % move to the data folder
mkdir(PARAMS.inter_dir)

set(0, 'DefaulttextInterpreter', 'none')

run('Master_NVHL.m')
