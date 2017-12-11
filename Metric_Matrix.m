function Mat_out  = Metric_Matrix(cfg_in, Metrics);
%% Metric_Matric: utility function for forming a matrix of values from a metric structure (can be psd, coherence, xcorr, ...)


global PARAMS
cfg_def.f = [45 65; 70 90];
cfg_def.labels = {'PL', 'IL', 'OFC', 'NAc', 'CG'};
mfun = mfilename;
cfg  = ProcessConfig2(cfg_def, cfg_in);


if ~isfield(cfg, 'type') || isempty(cfg.type)
    error('no type specified.  options: Pxx, Cxx, Xcorr')
end


switch cfg.type
    
    case{'Pxx'}
        
    case {'Cxx'}
        
        %% generate an output matrix
        clear mat_out
        labels = cfg.labels;
        % Lower of the matrix is lg and Upper is hg
        for ii = 1:length(labels)
            for jj = 1:length(labels)
                mat_out.labels{ii,jj} = [labels{ii} '_' labels{jj}];
            end
        end
        
        
        for iPhase = 1:length(PARAMS.Phases)
            for iBand = 1:2
                mat_out.(PARAMS.Phases{iPhase}).sess_coh = NaN(size(mat_out.labels));
                mat_out.(PARAMS.Phases{iPhase}).evt_coh = NaN(size(mat_out.labels));
            end
        end
        
        %%
        %         Subjects = fieldnames(Metrics);
        sess_list = fieldnames(Metrics);
        for iSess = 1:length(sess_list)
            Pairs = Metrics.(sess_list{iSess}).coh.ExpKeys.GoodPairs;
            for iPhase = 1:length(PARAMS.Phases)
                for iP = 1:length(Pairs)
                    Sites = strsplit(Pairs{iP}, '_'); % split the good pair into the two site names
                    
                    % get the index of the current pair of sites
                    idx = strfind(mat_out.labels, Pairs{iP});
                    [x_idx,y_idx] = find(not(cellfun('isempty', idx)));
                    if x_idx >= y_idx
                        error('The matrix location for the low gamma event is in lower part of the matrix when it should be in the upper')
                    end
                    % put the matrix with the of average values here.
                    % Low gamma
                    f_idx = find(Metrics.(sess_list{iSess}).coh.(Pairs{iP}).(PARAMS.Phases{iPhase}).F > cfg.f(1,1) & Metrics.(sess_list{iSess}).coh.(Pairs{iP}).(PARAMS.Phases{iPhase}).F <= cfg.f(1,2));
                    mat_out.(PARAMS.Phases{iPhase}).sess_coh(y_idx, x_idx, iSess) = mean(Metrics.(sess_list{iSess}).coh.(Pairs{iP}).(PARAMS.Phases{iPhase}).cxx(f_idx));
                    
                    
                    f_idx = find(Metrics.(sess_list{iSess}).coh.(Pairs{iP}).(PARAMS.Phases{iPhase}).F > cfg.f(2,1) & Metrics.(sess_list{iSess}).coh.(Pairs{iP}).(PARAMS.Phases{iPhase}).F <= cfg.f(2,2));
                    mat_out.(PARAMS.Phases{iPhase}).sess_coh(x_idx, y_idx, iSess) = mean(Metrics.(sess_list{iSess}).coh.(Pairs{iP}).(PARAMS.Phases{iPhase}).cxx(f_idx));
                end
            end
        end
end