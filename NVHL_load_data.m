function [data, cfg] = NVHL_load_data(cfg_in)
%% NVHL_load_data:
%  used to load the raw LFP recodings across multiple subject and segragate
%  the data into the different phases 'pot' vs 'trk'
%
%  inputs:
%      global PARAMS from MASTER_Multisite
%    - cfg_in: input configuration
%
%
%  outputs:
%    - data [struct]: contains data for each subjects separated into
%    session(day), phases(pre, ipsi, contra, post), segments(pot, trk)
%    -cfg_out [struct]: contains the configurations use to process the data

%% Initial paramters
global PARAMS


cfg_def = [];

mfun = mfilename;
cfg= ProcessConfig2(cfg_def, cfg_in);


%% load the data fpr each phase within the session.
if isunix
    cd([PARAMS.data_dir '/' cfg.fname(1:6) '/' cfg.fname ])
else
    cd([PARAMS.data_dir '\' cfg.fname(1:6) '\' cfg.fname ])
end

LoadExpKeys()
%%
evt= LoadEvents([]);
% check to see if I was dumb and didnt stop recording between the pot
% and track.  If so, then split the session in half shave off 1/10 of
% off the end for the first half and the start of the second.
idx = strfind(evt.label, 'Starting Recording');
start_idx = find(not(cellfun('isempty', idx)));
idx = strfind(evt.label, 'Stopping Recording');
stop_idx = find(not(cellfun('isempty', idx)));

% check to make sure NLX didn't mess up the start stop events (this
% happened for R104-2016-09-26_ipsi. It has 19 start times for some
% reason)
if length(evt.t{start_idx}) >= 3 % should only have 2
    [~, trk_idx]  = max(evt.t{stop_idx}(2:end)-evt.t{start_idx}(2:end)); % find the largest gap
    trk_idx = trk_idx+1; % offset by one to compensate for the 'trk' being the second phase
else
    trk_idx = [];
end

if evt.t{stop_idx}(1)-evt.t{start_idx}(1) < 60*9; % check to ensure the recording is roughly 10mins long.
    error('pot session is too short');
elseif evt.t{stop_idx}(trk_idx)-evt.t{start_idx}(trk_idx) < 60*29;
    error('trk session is too short');
end

for iChan = 1:length(ExpKeys.Chan_to_use)
    cfg_load.fc = ExpKeys.Chan_to_use(iChan);
    cfg_load.resample = 2000;
    csc_out.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)) = LoadCSC(cfg_load);
    fprintf(['\n' ExpKeys.Chan_to_use_labels{iChan}(1:end-1) '_FS:' num2str(csc_out.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).cfg.hdr{1}.SamplingFrequency) '\n'])
    % check to see if the data has been sampled appropriotely as per
    % cfg_load.resample
    if csc_out.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).cfg.hdr{1}.SamplingFrequency ~= cfg_load.resample
        cfg.decimateByFactor = csc_out.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).cfg.hdr{1}.SamplingFrequency/cfg_load.resample;
        
        fprintf('%s: Decimating by factor %d...\n',mfun,cfg.decimateByFactor)
        csc_out.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).data = decimate(csc_out.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).data,cfg.decimateByFactor);
        csc_out.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).tvec = csc_out.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).tvec(1:cfg.decimateByFactor:end);
        csc_out.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).cfg.hdr{1}.SamplingFrequency = csc_out.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).cfg.hdr{1}.SamplingFrequency./cfg.decimateByFactor;
        
        if round(mode(diff(csc_out.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).tvec))*10000) ~= floor((1/(csc_out.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).cfg.hdr{1}.SamplingFrequency)*10000));
            error('Something went wrong.  The diff in tvec samples does not match the sampling frequency following resampling')
        end
    end
    
    % split into pot and track.
    data.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).('pot') = restrict(csc_out.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)),evt.t{start_idx}(1),evt.t{stop_idx}(1));
    if isempty(trk_idx)
        data.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).('trk') = restrict(csc_out.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)),evt.t{start_idx}(2),evt.t{stop_idx}(2));
    else
        data.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).('trk') = restrict(csc_out.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)),evt.t{start_idx}(trk_idx),evt.t{stop_idx}(trk_idx));
    end
    
    % check to ensure the length of each recording is appropriote
    % (10mins for pot and 30mins for trk)
    % pot correction
    t_pot = 10*60;
    t_norm = data.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).('pot').tvec - data.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).('pot').tvec(1);
    t_pot_max = nearest_idx3(t_pot, t_norm, -1); 
    data.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).('pot') = restrict(data.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).('pot'), data.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).('pot').tvec(1), data.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).('pot').tvec(t_pot_max));
    % trk correction
    t_trk = 30*60;
    t_norm = data.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).('trk').tvec - data.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).('trk').tvec(1);
    t_trk_max = nearest_idx3(t_trk, t_norm, -1); 
    data.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).('trk') = restrict(data.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).('trk'), data.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).('trk').tvec(1), data.(ExpKeys.Chan_to_use_labels{iChan}(1:end-1)).('trk').tvec(t_trk_max));
 
end
%% get the position for each phase
cfg_load = [];
if ~exist('VT1.nvt', 'file')
    unzip('VT1.zip');
end
pos = LoadPos(cfg_load);
% remove point outside the pot and track range (for RR3 this is >230x, >0y)
X = pos.data(1,:);
X(X<230) = NaN; 
pos.data(1,:) = X;

data.pos.pot = restrict(pos,evt.t{start_idx}(1),evt.t{stop_idx}(1));
pos_t_norm = data.pos.pot.tvec - data.pos.pot.tvec(1);
pos_t_pot_max = nearest_idx3(t_pot, pos_t_norm, -1);
data.pos.pot = restrict(data.pos.pot, data.pos.('pot').tvec(1), data.pos.('pot').tvec(pos_t_pot_max));

if isempty(trk_idx)
    data.pos.trk = restrict(pos,evt.t{start_idx}(2),evt.t{stop_idx}(2));
else
    data.pos.trk = restrict(pos,evt.t{start_idx}(trk_idx),evt.t{stop_idx}(trk_idx));
end
pos_t_norm = data.pos.trk.tvec - data.pos.trk.tvec(1);
pos_t_trk_max = nearest_idx3(t_trk, pos_t_norm, -1);
data.pos.trk = restrict(data.pos.trk, data.pos.('trk').tvec(1), data.pos.('trk').tvec(pos_t_trk_max));

data.ExpKeys = ExpKeys;

end
