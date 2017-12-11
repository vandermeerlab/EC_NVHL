function NVHL_plot_psd(cfg_in, Metrics)
%% MS_plot_psd: plots multiple power spectral densities for the data files
% in the "Naris" structure (output from MS_collect_psd)
%
% inputs:
%    -cfg_in: [struct] contains configuration paramters
%    -Naris: [struct] contains power and frequency values for each channel
%    for each subject/session/phase
%
%    this script currently uses a global parameter set to determine where
%    to save the output figures

%% set up defaults

cfg_def = [];
cfg_def.type = 'both'; % whether to output the 'standard' or "white" filtered PSD
cfg_def.linewidth = 2;
cfg = ProcessConfig2(cfg_def, cfg_in);
global PARAMS
%% cycle through data from each subject, session, and channel to give an
%  overview figure (raster) and individual PSDs (vector)
switch cfg.type
    case {'standard'} % make use the standard PSD
        sub_list = fieldnames(Metrics);
        for iSub = 1:length(fieldnames(Metrics))
            sess_list = fieldnames(Metrics.(sub_list{iSub}));
            for iSess = 1:length(sess_list);
                site_list = fieldnames(Metrics.(sub_list{iSub}).(sess_list{iSess}));
                c_ord = linspecer(length(site_list));
                for iPhase = 1:length(PARAMS.Phases)
                    h_site.(['n' num2str(iPhase)]) = figure((iSub)*100 + (iSess)*10 +(iPhase));
                    
                    for iSite = 1:length(site_list)
                        hold on
                        plot(Metrics.(sub_list{iSub}).(sess_list{iSess}).(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.F,...
                            10*log10(Metrics.(sub_list{iSub}).(sess_list{iSess}).(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.Pxx),...
                            'color', c_ord(iSite,:), 'linewidth', cfg.linewidth)
                        
                        if iSess ==1
                            All_sess_psd.(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.Pxx =[];
                        end
                        % get an average over all sessions
                        All_sess_psd.(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.Pxx =...
                            cat(1,All_sess_psd.(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.Pxx, Metrics.(sub_list{iSub}).(sess_list{iSess}).(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.Pxx');
                        
                    end
                    xlim([0 120])
                    xlabel('Frequency (Hz)')
                    ylabel('Power')
                    legend(site_list)
                    SetFigure([], h_site.(['n' num2str(iPhase)]))
                    saveas(h_site.(['n' num2str(iPhase)]), [PARAMS.inter_dir sess_list{iSess}(1:end-4) '_' PARAMS.Phases{iPhase}], 'png')
                    saveas(h_site.(['n' num2str(iPhase)]), [PARAMS.inter_dir sess_list{iSess}(1:end-4) '_' PARAMS.Phases{iPhase}], 'epsc')
                    close all
                end
            end
            
            % SetFigure([], h_all)
            for iPhase = 1:length(PARAMS.Phases)
                h_site.(['n' num2str(iPhase)]) = figure((iSub)*100 + (iSess)*10 +(iPhase));
                              
                
                for iSite = 1:length(site_list)
                    hold on
                    h = shadedErrorBar(Metrics.(sub_list{iSub}).(sess_list{iSess}).(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.F,...
                        10*log10(All_sess_psd.(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.Pxx),{@mean,@std},...
                        {'color', c_ord(iSite,:),'markerfacecolor',c_ord(iSite,:), 'linewidth', 2},1);
                    h.mainLine.DisplayName = site_list{iSite};

                end
                xlim([0 120])
                xlabel('Frequency (Hz)')
                ylabel('Power')
                % walkaround for legend
                [~,icons,~,~] = legend(findobj(gca, '-regexp', 'DisplayName', '[^'']'));%, 'orientation', 'horizontal'); legend boxoff;
                set(icons(:),'LineWidth',3); %// Or whatever

                SetFigure([], gcf)
                if isunix
                    sum_dir = '/Summary';
                    mkdir(PARAMS.inter_dir, sum_dir)
                    sum_dir = [sum_dir '/'];
                else
                    sum_dir = '\Summary\';
                    mkdir(PARAMS.inter_dir, sum_dir)
                    sum_dir = [sum_dir '/'];
                end
                saveas(h_site.(['n' num2str(iPhase)]), [PARAMS.inter_dir sum_dir  sess_list{iSess}(1:6) '_' PARAMS.Phases{iPhase}, '_all'], 'png')
                saveas(h_site.(['n' num2str(iPhase)]), [PARAMS.inter_dir sum_dir  sess_list{iSess}(1:6) '_' PARAMS.Phases{iPhase}, '_all'], 'epsc')
                
                close all
            end
        end
        
    case{'white'};
        sub_list = fieldnames(Metrics);
        for iSub = 1:length(fieldnames(Metrics))
            sess_list = fieldnames(Metrics.(sub_list{iSub}));
            for iSess = 1:length(sess_list);
                site_list = fieldnames(Metrics.(sub_list{iSub}).(sess_list{iSess}));
                c_ord = linspecer(length(site_list));
                for iPhase = 1:length(PARAMS.Phases)
                    h_site.(['n' num2str(iPhase)]) = figure((iSub)*100 + (iSess)*10 +(iPhase));
                    
                    for iSite = 1:length(site_list)
                        hold on
                        plot(Metrics.(sub_list{iSub}).(sess_list{iSess}).(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.White_F,...
                            10*log10(Metrics.(sub_list{iSub}).(sess_list{iSess}).(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.White_Pxx),...
                            'color', c_ord(iSite,:), 'linewidth', cfg.linewidth)
                        
                        if iSess ==1
                            All_sess_psd.(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.White_Pxx =[];
                        end
                        % get an average over all sessions
                        All_sess_psd.(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.White_Pxx =...
                            cat(1,All_sess_psd.(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.White_Pxx, Metrics.(sub_list{iSub}).(sess_list{iSess}).(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.White_Pxx');
                        
                    end
                    xlim([0 120])
                    xlabel('Frequency (Hz)')
                    ylabel('Power')
                    legend(site_list)
                    SetFigure([], h_site.(['n' num2str(iPhase)]))
                    saveas(h_site.(['n' num2str(iPhase)]), [PARAMS.inter_dir sess_list{iSess}(1:end-4) '_' PARAMS.Phases{iPhase} '_white'], 'png')
                    saveas(h_site.(['n' num2str(iPhase)]), [PARAMS.inter_dir sess_list{iSess}(1:end-4) '_' PARAMS.Phases{iPhase} '_white'], 'epsc')
                    close all
                end
            end
            close all
            % SetFigure([], h_all)
            for iPhase = 1:length(PARAMS.Phases)
                h_site.(['n' num2str(iPhase)]) = figure((iSub)*100 + (iSess)*10 +(iPhase));

                for iSite = 1:length(site_list)
                    hold on
                    h = shadedErrorBar(Metrics.(sub_list{iSub}).(sess_list{iSess}).(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.White_F,...
                        10*log10(All_sess_psd.(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.White_Pxx),{@mean,@std},...
                        {'color', c_ord(iSite,:),'markerfacecolor',c_ord(iSite,:), 'linewidth', 2},1);
                    h.mainLine.DisplayName = site_list{iSite};

                end
                xlim([0 120])
                xlabel('Frequency (Hz)')
                ylabel('Power')
                % walkaround for legend
                [~,icons,~,~] = legend(findobj(gca, '-regexp', 'DisplayName', '[^'']'));%, 'orientation', 'horizontal'); legend boxoff;
                set(icons(:),'LineWidth',3); %// Or whatever

                SetFigure([], gcf)
                if isunix
                    sum_dir = '/Summary';
                    mkdir(PARAMS.inter_dir, sum_dir)
                    sum_dir = [sum_dir '/'];
                else
                    sum_dir = '\Summary\';
                    mkdir(PARAMS.inter_dir, sum_dir)
                    sum_dir = [sum_dir '/'];                   
                end
                saveas(h_site.(['n' num2str(iPhase)]), [PARAMS.inter_dir sum_dir  sess_list{iSess}(1:6) '_' PARAMS.Phases{iPhase}, '_all_white'], 'png')
                saveas(h_site.(['n' num2str(iPhase)]), [PARAMS.inter_dir sum_dir  sess_list{iSess}(1:6) '_' PARAMS.Phases{iPhase}, '_all_white'], 'epsc')
                
                close all
            end
        end
        
    case{'both'};
               sub_list = fieldnames(Metrics);
        for iSub = 1:length(fieldnames(Metrics))
            sess_list = fieldnames(Metrics.(sub_list{iSub}));
            for iSess = 1:length(sess_list);
                site_list = fieldnames(Metrics.(sub_list{iSub}).(sess_list{iSess}));
                c_ord = linspecer(length(site_list));
                for iPhase = 1:length(PARAMS.Phases)
                    h_site.(['n' num2str(iPhase)]) = figure((iSub)*100 + (iSess)*10 +(iPhase));
                    
                    for iSite = 1:length(site_list)
                        hold on
                        plot(Metrics.(sub_list{iSub}).(sess_list{iSess}).(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.F,...
                            10*log10(Metrics.(sub_list{iSub}).(sess_list{iSess}).(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.Pxx),...
                            'color', c_ord(iSite,:), 'linewidth', cfg.linewidth)
                        
                        if iSess ==1
                            All_sess_psd.(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.Pxx =[];
                        end
                        % get an average over all sessions
                        All_sess_psd.(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.Pxx =...
                            cat(1,All_sess_psd.(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.Pxx, Metrics.(sub_list{iSub}).(sess_list{iSess}).(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.Pxx');
                        
                    end
                    xlim([0 120])
                    xlabel('Frequency (Hz)')
                    ylabel('Power')
                    legend(site_list)
                    SetFigure([], h_site.(['n' num2str(iPhase)]))
                    saveas(h_site.(['n' num2str(iPhase)]), [PARAMS.inter_dir sess_list{iSess}(1:end-4) '_' PARAMS.Phases{iPhase}], 'png')
                    saveas(h_site.(['n' num2str(iPhase)]), [PARAMS.inter_dir sess_list{iSess}(1:end-4) '_' PARAMS.Phases{iPhase}], 'epsc')
                    close all;
                end
            end
            
            for iPhase = 1:length(PARAMS.Phases)
                h_site.(['n' num2str(iPhase)]) = figure((iSub)*100 + (iSess)*10 +(iPhase));
                              
                
                for iSite = 1:length(site_list)
                    hold on
                    h = shadedErrorBar(Metrics.(sub_list{iSub}).(sess_list{iSess}).(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.F,...
                        10*log10(All_sess_psd.(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.Pxx),{@mean,@std},...
                        {'color', c_ord(iSite,:),'markerfacecolor',c_ord(iSite,:), 'linewidth', 2},1);
                    h.mainLine.DisplayName = site_list{iSite};

                end
                xlim([0 120])
                xlabel('Frequency (Hz)')
                ylabel('Power')
                % walkaround for legend
                [~,icons,~,~] = legend(findobj(gca, '-regexp', 'DisplayName', '[^'']'));%, 'orientation', 'horizontal'); legend boxoff;
                set(icons(:),'LineWidth',3); %// Or whatever

                SetFigure([], gcf)
                if isunix
                    sum_dir = '/Summary';
                    mkdir(PARAMS.inter_dir, sum_dir)
                    sum_dir = [sum_dir '/'];
                else
                    sum_dir = '\Summary\';
                    mkdir(PARAMS.inter_dir, sum_dir)
                    sum_dir = [sum_dir '/'];                   
                end
                saveas(h_site.(['n' num2str(iPhase)]), [PARAMS.inter_dir sum_dir  sess_list{iSess}(1:6) '_' PARAMS.Phases{iPhase}, '_all'], 'png')
                saveas(h_site.(['n' num2str(iPhase)]), [PARAMS.inter_dir sum_dir  sess_list{iSess}(1:6) '_' PARAMS.Phases{iPhase}, '_all'], 'epsc')
                
                close all
            end
        end
        % do it again for the white filter
                sub_list = fieldnames(Metrics);
        for iSub = 1:length(fieldnames(Metrics))
            sess_list = fieldnames(Metrics.(sub_list{iSub}));
            for iSess = 1:length(sess_list);
                site_list = fieldnames(Metrics.(sub_list{iSub}).(sess_list{iSess}));
                c_ord = linspecer(length(site_list));
                for iPhase = 1:length(PARAMS.Phases)
                    h_site.(['n' num2str(iPhase)]) = figure((iSub)*100 + (iSess)*10 +(iPhase));
                    
                    for iSite = 1:length(site_list)
                        hold on
                        plot(Metrics.(sub_list{iSub}).(sess_list{iSess}).(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.White_F,...
                            10*log10(Metrics.(sub_list{iSub}).(sess_list{iSess}).(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.White_Pxx),...
                            'color', c_ord(iSite,:), 'linewidth', cfg.linewidth)
                        
                        if iSess ==1
                            All_sess_psd.(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.White_Pxx =[];
                        end
                        % get an average over all sessions
                        All_sess_psd.(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.White_Pxx =...
                            cat(1,All_sess_psd.(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.White_Pxx, Metrics.(sub_list{iSub}).(sess_list{iSess}).(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.White_Pxx');
                        
                    end
                    xlim([0 120])
                    xlabel('Frequency (Hz)')
                    ylabel('Power')

                    legend(site_list)
                    SetFigure([], h_site.(['n' num2str(iPhase)]))
                    saveas(h_site.(['n' num2str(iPhase)]), [PARAMS.inter_dir sum_dir  sess_list{iSess}(1:end-4) '_' PARAMS.Phases{iPhase} '_white'], 'png')
                    saveas(h_site.(['n' num2str(iPhase)]), [PARAMS.inter_dir sum_dir  sess_list{iSess}(1:end-4) '_' PARAMS.Phases{iPhase} '_white'], 'epsc')
                    close all
                end
            end
            
            % SetFigure([], h_all)
            for iPhase = 1:length(PARAMS.Phases)
                h_site.(['n' num2str(iPhase)]) = figure((iSub)*100 + (iSess)*10 +(iPhase));
                              
                
                for iSite = 1:length(site_list)
                    hold on
                    h = shadedErrorBar(Metrics.(sub_list{iSub}).(sess_list{iSess}).(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.White_F,...
                        10*log10(All_sess_psd.(site_list{iSite}).(PARAMS.Phases{iPhase}).psd.White_Pxx),{@mean,@std},...
                        {'color', c_ord(iSite,:),'markerfacecolor',c_ord(iSite,:), 'linewidth', 2},1);
                    h.mainLine.DisplayName = site_list{iSite};

                end
                xlim([0 120])
                xlabel('Frequency (Hz)')
                ylabel('Power')
                % walkaround for legend
                [~,icons,~,~] = legend(findobj(gca, '-regexp', 'DisplayName', '[^'']'));%, 'orientation', 'horizontal'); legend boxoff;
                set(icons(:),'LineWidth',3); %// Or whatever

                SetFigure([], gcf)
                if isunix
                    sum_dir = '/Summary';
                    mkdir(PARAMS.inter_dir, sum_dir)
                    sum_dir = [sum_dir '/'];
                else
                    sum_dir = '\Summary\';
                    mkdir(PARAMS.inter_dir, sum_dir)
                    sum_dir = [sum_dir '/'];                   
                end
                saveas(h_site.(['n' num2str(iPhase)]), [PARAMS.inter_dir sum_dir  sess_list{iSess}(1:6) '_' PARAMS.Phases{iPhase}, '_all_white'], 'png')
                saveas(h_site.(['n' num2str(iPhase)]), [PARAMS.inter_dir sum_dir  sess_list{iSess}(1:6) '_' PARAMS.Phases{iPhase}, '_all_white'], 'epsc')
                
                close all
            end
        end
        
end

