function [out , mat_out] = NVHL_get_coh(cfg_in, data)



%initialize

global PARAMS

cfg_def.whitefilter = 'on';
cfg_def.wsize = 2048;
mfun = mfilename;
cfg  = ProcessConfig2(cfg_def, cfg_in);

%% compute the coherence using mscohere
% for iSub = 1:length(
Pairs = data.ExpKeys.GoodPairs;
for iPhase = 1:length(PARAMS.Phases)
    for iP = 1:length(Pairs)
        Sites = strsplit(Pairs{iP}, '_'); % split the good pair into the two site names
        cfg.Fs = data.(Sites{1}).(PARAMS.Phases{iPhase}).cfg.hdr{1,1}.SamplingFrequency;

        [out.(Pairs{iP}).(PARAMS.Phases{iPhase}).cxx,out.(Pairs{iP}).(PARAMS.Phases{iPhase}).F] = mscohere(data.(Sites{1}).(PARAMS.Phases{iPhase}).data,data.(Sites{2}).(PARAMS.Phases{iPhase}).data,hanning(cfg.wsize),cfg.wsize/2,2*cfg.wsize,cfg.Fs);

    end
end

out.ExpKeys = data.ExpKeys; 




