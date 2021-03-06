% NVHL_Master:
%   Master control script for NVHL loading, analysis, and statistics.
%   Requirements:
%        - van der Meer lab codebase
%        - EC_NVHL functions (vandermeerlab/EC_NCHL on github)
%


% terminology:
%    - subject: each rat used.  Initially this analysis was blind to group
%    type
%
%    - session: recording day which included four phases
%        - phase : 'pot' which was a 10min session on the pot.  THis was
%        followed by a 30min "trk" session on the track where the animal
%        would freely move along a V maze with an alcohol port at the
%        "south" arm and a sucrose port at the "north" end
%

%% make a log
NVHL_log = fopen([PARAMS.data_dir '/NVHL_log.txt'], 'w');
fprintf(NVHL_log, date);
% Extract the data from each recroding phase within each session and separate pot vs track sections

for iSub = 1:length(PARAMS.Subjects)
    if isunix
        cd([PARAMS.data_dir '/' PARAMS.Subjects{iSub}])
    else
        cd([PARAMS.data_dir '\' PARAMS.Subjects{iSub}])
    end
    
    dir_files = dir(); % get all the sessions for the current subject
    dir_files(1:2) = [];
    sess_list = [];
    for iDir = 1:length(dir_files)
        if dir_files(iDir).isdir == 1 && strcmp(dir_files(iDir).name(1:6), PARAMS.Subjects{iSub}) % ensure that the session folders have the correct names
            sess_list = [sess_list;dir_files(iDir).name];  % extract only the folders for the seesions
        end
    end
    sess_list = cellstr(sess_list);
    % load the data for each session within the current subject.
    for iSess = 1:length(sess_list)
        cfg_loading = [];
        cfg_loading.fname = sess_list{iSess};
        fprintf(['\n' PARAMS.Subjects{iSub} '  ' sess_list{iSess}]);
        fprintf(NVHL_log,['\nLoading ' PARAMS.Subjects{iSub} '  ' sess_list{iSess}]);
        
        [all_data.(PARAMS.Subjects{iSub}).(strrep(sess_list{iSess}, '-', '_')), cfg_loading] = NVHL_load_data(cfg_loading);
        fprintf(NVHL_log, '...complete');
    end
    t_data = all_data.(PARAMS.Subjects{iSub});
    if isunix
        save([PARAMS.data_dir '/' PARAMS.Subjects{iSub} '_inter.mat'], 't_data', '-v7.3');
    else
        save([PARAMS.data_dir '\' PARAMS.Subjects{iSub} '_inter.mat'], 't_data', '-v7.3');
    end
    clear data
    % ensure the correct number of sessions exist per rat
    %     if length(fieldnames(data.(PARAMS.Subjects{iSub}))) ~=4
    %         error('too many or too few sessions for multisite experiment.  Should only contain 4 per rat')
    %     end
end

%% generate PSDs
fprintf(NVHL_log,'\n\nExtracting Power Metrics');
for iSub = 1:length(PARAMS.Subjects)
    load([PARAMS.data_dir PARAMS.Subjects{iSub} '_inter.mat']); 
    data.(PARAMS.Subjects{iSub}) = t_data;
    clear t_data
    sess_list = fieldnames(data.(PARAMS.Subjects{iSub}));
    for iSess  = 1:length(sess_list)
        fprintf(['Session ' sess_list{iSess} '\n'])
        fprintf(NVHL_log,['\nGetting Power ' PARAMS.Subjects{iSub} '  ' sess_list{iSess}]);
        Sites = data.(PARAMS.Subjects{iSub}).(strrep(sess_list{iSess}, '-', '_'));
        Sites = rmfield(Sites, 'ExpKeys'); Sites = rmfield(Sites, 'pos');
        Sites = fieldnames(Sites);
        for iSite = 1:length(Sites);
            for iPhase= 1:length(PARAMS.Phases)
                % compute the power spectral density
                Metrics.(PARAMS.Subjects{iSub}).(strrep(sess_list{iSess}, '-', '_')).(Sites{iSite}).(PARAMS.Phases{iPhase}).psd = ...
                    NVHL_get_psd([],data.(PARAMS.Subjects{iSub}).(strrep(sess_list{iSess}, '-', '_')).(Sites{iSite}).(PARAMS.Phases{iPhase}));
                
                fprintf(NVHL_log, '...complete');
            end
        end
    end
    clear data
end

%% plot the PSD with all the channels
cfg_psd_plot.type = 'both';
NVHL_plot_psd(cfg_psd_plot, Metrics)

% %% get the gamma event counts per for pot and
% fprintf(NVHL_log,'\n\nCollecting Events');
%
% for iSub = 1:length(PARAMS.Subjects)
%     sess_list = fieldnames(data.(PARAMS.Subjects{iSub}));
%     for iSess  = 1:length(sess_list)
%         fprintf(NVHL_log,['\nEvents ' PARAMS.Subjects{iSub} '  ' sess_list{iSess}]);
%         [Events.(PARAMS.Subjects{iSub}).(strrep(sess_list{iSess}, '-', '_'))] = MS_extract_gamma([],data.(PARAMS.Subjects{iSub}).(strrep(sess_list{iSess}, '-', '_')));
%         fprintf(NVHL_log, '...complete');
%     end
% end
% % summary of Metrics events
%
% %     stats = MS_gamma_stats([], Events);
%%
fprintf(NVHL_log,'\n\nExtracting Coherence Metrics');
for iSub = 1%:length(PARAMS.Subjects)
        load([PARAMS.data_dir PARAMS.Subjects{iSub} '_inter.mat']); 
    data.(PARAMS.Subjects{iSub}) = t_data;
    clear t_data
    sess_list = fieldnames(data.(PARAMS.Subjects{iSub}));
    for iSess  = 1:length(sess_list)
        % compute the coherence
        Metrics.(PARAMS.Subjects{iSub}).(strrep(sess_list{iSess}, '-', '_')).coh = NVHL_get_coh([],data.(PARAMS.Subjects{iSub}).(strrep(sess_list{iSess}, '-', '_')));
    end
    cfg_mat.type = 'Cxx';
    NVHL_mat.(PARAMS.Subjects{iSub}) = Metric_Matrix(cfg_mat, Metrics.(PARAMS.Subjects{iSub}));
end

%% create a matrix of all the output values
NVHL_plot_coh([], Metrics)

%% plot coherence between groups
cfg_coh.group = []
cfg_coh.groupnames = unique(PARAMS.Group); 
NVHL_plot_coh(cfg_coh, Metrics)
%% save the intermediate files
fprintf(NVHL_log,'\n\nSaving intermediates');
mkdir(PARAMS.data_dir, 'temp');
save([PARAMS.data_dir 'NVHL_data.mat'], 'data', '-v7.3')
save([PARAMS.data_dir 'NVHL_Metrics.mat'], 'Metrics', '-v7.3')
save([PARAMS.data_dir 'NVHL_events.mat'], 'Events', '-v7.3')
% save([PARAMS.data_dir 'NVHL_mat.mat'], 'NVHL_mat', '-v7.3')

fclose(NVHL_log);

% % load the intermediate files
% NVHL_log = fopen([PARAMS.data_dir '/NVHL_log_2.txt'], 'w');
% fprintf(NVHL_log, date);
% fprintf(NVHL_log,'\n\nLoading intermediates');
% load([PARAMS.data_dir '/MS_data.mat'])
% load([PARAMS.data_dir '/MS_Metrics.mat'])
% load([PARAMS.data_dir '/MS_events.mat'])
% 
% % split pot vs trk
% 
% [Metrics_pot, ~]  = MS_pot_trk_split(Metrics);
% [data_pot, ~]  = MS_pot_trk_split(data);
% [Events_pot, ~]  = MS_pot_trk_split(Events);
% 
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% Analyses %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % get the ratio of the power in multiple bands relative to the exponential f curve
% fprintf(NVHL_log,'\n\nExtracting Power Ratio');
% for iSub = 1:length(PARAMS.Subjects)
%     sess_list = fieldnames(Metrics.(PARAMS.Subjects{iSub}));
%     for iSess  = 1:length(sess_list)
%                 fprintf(NVHL_log,['\nGetting ratio ' PARAMS.Subjects{iSub} '  ' sess_list{iSess}]);
%         cfg_pow_ratio.id = sess_list{iSess};
%         Metrics.(PARAMS.Subjects{iSub}).(strrep(sess_list{iSess}, '-', '_')) = MS_get_power_ratio(cfg_pow_ratio,Metrics.(PARAMS.Subjects{iSub}).(strrep(sess_list{iSess}, '-', '_')));
%                 fprintf(NVHL_log, '...complete');
%     end
% end
% % plot the PSDs
% cfg_psd.type = 'white';
% MS_plot_psd(cfg_psd, Metrics);
% 
% % count the events
% cfg_evt_plot =[];
% cfg_evt_plot.sites = {'PL_pot', 'IL_pot', 'OFC_pot', 'NAc_pot', 'CG_pot'};
% 
% MS_plot_event_stats(cfg_evt_plot, Events)
% 
% % get an example event from each session and plot all sites together for the same event.
% for iSub = 1:length(PARAMS.Subjects)
%     sess_list = fieldnames(Events.(PARAMS.Subjects{iSub}));
%     for iSess = 1:length(sess_list)
%         fprintf(NVHL_log,['\nPlotting Events ' PARAMS.Subjects{iSub} '  ' sess_list{iSess}]);
%         MS_event_fig([], Events.(PARAMS.Subjects{iSub}).(strrep(sess_list{iSess}, '-', '_')), data.(PARAMS.Subjects{iSub}).(strrep(sess_list{iSess}, '-', '_')));
%         fprintf(NVHL_log, '...complete');
%     end
% end
% 
% 
% % generate a spectrogram across each session for each site.
% for iSub = 1:length(PARAMS.Subjects)
%     sess_list = fieldnames(data_pot.(PARAMS.Subjects{iSub}));
%     for iSess = 1:length(sess_list)
%         fprintf(NVHL_log,['\nPlotting Spec ' PARAMS.Subjects{iSub} '  ' sess_list{iSess}]);
%         MS_spec_fig([], data_pot.(PARAMS.Subjects{iSub}).(strrep(sess_list{iSess}, '-', '_')));
%         fprintf(NVHL_log, '...complete');
%     end
% end
% % plot the gamma band power ratios
% cfg_pow_ratio_plot.ylims = [-75 75];
% cfg_pow_ratio_plot.plot_type = 'raw';
% cfg_pow_ratio_plot.ylims_norm = [0 2];
% 
% MS_plot_power_ratio(cfg_pow_ratio_plot, Metrics)
% MS_plot_power_ratio(cfg_pow_ratio_plot, Metrics_trk)
% 
% MS_plot_power([], Metrics);

% %% Get the phase coherence metrics
% % create pairs of channels for detected events.
% 
% for iSub = 2:length(PARAMS.Subjects)
%     sess_list = fieldnames(Events.(PARAMS.Subjects{iSub}));
%     for iSess = 1:length(sess_list)
%         [Events.(PARAMS.Subjects{iSub}).(strrep(sess_list{iSess}, '-', '_')), Coh_mat.(PARAMS.Subjects{iSub}).(strrep(sess_list{iSess}, '-', '_'))]  = MS_event_pairs([], Events.(PARAMS.Subjects{iSub}).(strrep(sess_list{iSess}, '-', '_')), data.(PARAMS.Subjects{iSub}).(strrep(sess_list{iSess}, '-', '_')));
%     end
% end
% 
% %% plot the COH metrics
% 
% stats_coh =  MS_Coh_plot_stats(Coh_mat);
% %
% %
%
% %% get the coordinates from the Expkeys
%
% % stats_subjects = MS_get_subject_info(data);
% fclose(NVHL_log);
