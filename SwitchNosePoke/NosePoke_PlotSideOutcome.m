function MouseNosePoke_PlotSideOutcome(AxesHandles, Action, varargin)
global nTrialsToShow %this is for convenience
global BpodSystem

switch Action
    case 'init'
        %initialize pokes plot
        nTrialsToShow = 90; %default number of trials to display
        
        if nargin >= 3 %custom number of trials
            nTrialsToShow =varargin{1};
        end
        axes(AxesHandles.HandleOutcome);
        %plot in specified axes
        BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCircle = line(-1,0.5, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCross = line(-1,0.5, 'LineStyle','none','Marker','+','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.RewardedL = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.RewardedR = line(-1,0, 'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.UnrewardedL = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','r','MarkerFace','r', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.UnrewardedR = line(-1,0, 'LineStyle','none','Marker','o','MarkerEdge','r','MarkerFace','r', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.SkippedL = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','w', 'MarkerSize',4);
        BpodSystem.GUIHandles.OutcomePlot.SkippedR = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','w', 'MarkerSize',4);
        BpodSystem.GUIHandles.OutcomePlot.EarlyWithdrawal = line(-1,0, 'LineStyle','none','Marker','d','MarkerEdge','none','MarkerFace','b', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.Jackpot = line(-1,0, 'LineStyle','none','Marker','x','MarkerEdge','r','MarkerFace','r', 'MarkerSize',7);
        BpodSystem.GUIHandles.OutcomePlot.Switch = line(-1,0, 'LineStyle','none','Marker','d','MarkerEdge','c','MarkerFace','c', 'MarkerSize',7);
        BpodSystem.GUIHandles.OutcomePlot.CumRwd = text(1,1,'0mL','verticalalignment','bottom','horizontalalignment','center');
        set(AxesHandles.HandleOutcome,'TickDir', 'out','YLim', [-1, 2],'XLim',[0,nTrialsToShow], 'YTick', [0 1],'YTickLabel', {'Right','Left'}, 'FontSize', 16);
        xlabel(AxesHandles.HandleOutcome, 'Trial#', 'FontSize', 18);
        hold(AxesHandles.HandleOutcome, 'on');

        %% time 2 switch barplot -called grace period becausetoo lazy to change the names
        hold(AxesHandles.HandleGracePeriod,'on')
        AxesHandles.HandleGracePeriod.XLabel.String = '';
        AxesHandles.HandleGracePeriod.YLabel.String = 'trials';
        AxesHandles.HandleGracePeriod.Title.String = 'time to switch';
        
        %% Trial rate
        hold(AxesHandles.HandleTrialRate,'on')
        BpodSystem.GUIHandles.OutcomePlot.TrialRate = line(AxesHandles.HandleTrialRate,[0],[0], 'LineStyle','-','Color','k','Visible','on'); %#ok<NBRAK>
        AxesHandles.HandleTrialRate.XLabel.String = 'Time (min)'; % FIGURE OUT UNIT
        AxesHandles.HandleTrialRate.YLabel.String = 'nTrials';
        AxesHandles.HandleTrialRate.Title.String = 'Trial rate';

        %% ST histogram
        hold(AxesHandles.HandleST,'on')
        AxesHandles.HandleST.XLabel.String = 'Time (ms)';
        AxesHandles.HandleST.YLabel.String = 'trial counts';
        AxesHandles.HandleST.Title.String = 'Stim sampling time';
        
        %% MT histogram
        hold(AxesHandles.HandleMT,'on')
        AxesHandles.HandleMT.XLabel.String = 'Time (ms)';
        AxesHandles.HandleMT.YLabel.String = 'trial counts';
        AxesHandles.HandleMT.Title.String = 'Movement time';
        
    case 'update'
        
        CurrentTrial = varargin{1};
        ChoiceLeft = BpodSystem.Data.Custom.ChoiceLeft;
        Rewarded =  BpodSystem.Data.Custom.Rewarded;
        Correct =  BpodSystem.Data.Custom.Correct;
        Switch=  BpodSystem.Data.Custom.ChoiceSwitch;
        
        % recompute xlim
        [mn, ~] = rescaleX(AxesHandles.HandleOutcome,CurrentTrial,nTrialsToShow);
        
        %Cumulative Reward Amount
        R = BpodSystem.Data.Custom.RewardMagnitude;
%         CRRtmp = repmat(  BpodSystem.Data.Custom.CenterPortRewAmount(end),1,size(R,2));
        ndxRwd = BpodSystem.Data.Custom.Rewarded;
        ndxCPRwd = BpodSystem.Data.Custom.CenterPortRewarded;
        ndxSPRwd= BpodSystem.Data.Custom.ChoiceSwitch;
        C = zeros(size(R)); C(BpodSystem.Data.Custom.ChoiceLeft==1&ndxRwd,1) = 1; C(BpodSystem.Data.Custom.ChoiceLeft==0&ndxRwd,2) = 1;
%         CCP = zeros(size(CRRtmp));CCP(BpodSystem.Data.Custom.ChoiceLeft==1&ndxCPRwd,1) = 1;
        R = R.*C;
%         CRR = CRRtmp.*CCP;
        CRR = sum(ndxCPRwd).* BpodSystem.Data.Custom.CenterPortRewAmount(end);
        SRR = sum(ndxSPRwd).* BpodSystem.Data.Custom.SwitchPortRewAmount(end);
        R = round(sum(R(:)) + sum(CRR(:)) + sum(SRR(:)));
        set(BpodSystem.GUIHandles.OutcomePlot.CumRwd, 'position', [CurrentTrial+1 1], 'string', ...
            [num2str(R) ' microL']);
        clear R C
        
        set(BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCircle, 'xdata', CurrentTrial, 'ydata', .5);
        set(BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCross, 'xdata', CurrentTrial, 'ydata', .5);
       
        %Plot past trials
        if ~isempty(ChoiceLeft)
            indxToPlot = mn:CurrentTrial;
            %Plot correct Left
            ndxRwdL = ChoiceLeft(indxToPlot) == 1 & Correct(indxToPlot) == 1;
            Xdata = indxToPlot(ndxRwdL); Ydata = ones(1,sum(ndxRwdL));
            set(BpodSystem.GUIHandles.OutcomePlot.RewardedL, 'xdata', Xdata, 'ydata', Ydata);
            %Plot correct Right
            ndxRwdR = ChoiceLeft(indxToPlot) == 0  & Correct(indxToPlot) == 1;
            Xdata = indxToPlot(ndxRwdR); Ydata = zeros(1,sum(ndxRwdR));
            set(BpodSystem.GUIHandles.OutcomePlot.RewardedR, 'xdata', Xdata, 'ydata', Ydata);
            %Plot error left
            ndxRwdL = ChoiceLeft(indxToPlot) == 1  & Correct(indxToPlot) == 0;
            Xdata = indxToPlot(ndxRwdL); Ydata = ones(1,sum(ndxRwdL));
            set(BpodSystem.GUIHandles.OutcomePlot.UnrewardedL, 'xdata', Xdata, 'ydata', Ydata);      
            %Plot error right
            ndxRwdR = ChoiceLeft(indxToPlot) == 0 & Correct(indxToPlot) == 0;
            Xdata = indxToPlot(ndxRwdR); Ydata = zeros(1,sum(ndxRwdR));
            set(BpodSystem.GUIHandles.OutcomePlot.UnrewardedR, 'xdata', Xdata, 'ydata', Ydata);
            %plot if left correct was not rewarded
            ndxRwdL = ChoiceLeft(indxToPlot) == 1 & Correct(indxToPlot) == 1 & Rewarded(indxToPlot) == 0;
            Xdata = indxToPlot(ndxRwdL); Ydata = ones(1,sum(ndxRwdL));
            set(BpodSystem.GUIHandles.OutcomePlot.SkippedL, 'xdata', Xdata, 'ydata', Ydata);
            %plot if right correct was not rewarded
            ndxRwdR = ChoiceLeft(indxToPlot) == 0 & Correct(indxToPlot) == 1 & Rewarded(indxToPlot) == 0;
            Xdata = indxToPlot(ndxRwdR); Ydata = zeros(1,sum(ndxRwdR));
            set(BpodSystem.GUIHandles.OutcomePlot.SkippedR, 'xdata', Xdata, 'ydata', Ydata);
            
            %plot if switch port choice
            ndxSwitch=Switch(indxToPlot) == 1;
            Xdata = indxToPlot(ndxSwitch); Ydata = zeros(1,sum(ndxSwitch));
            set( BpodSystem.GUIHandles.OutcomePlot.Switch, 'xdata', Xdata, 'ydata', Ydata);   
        end
        
        
        if ~isempty(BpodSystem.Data.Custom.EarlyWithdrawal)
            indxToPlot = mn:CurrentTrial;
            ndxEarly = BpodSystem.Data.Custom.EarlyWithdrawal(indxToPlot);
            XData = indxToPlot(ndxEarly);
            YData = 0.5*ones(1,sum(ndxEarly));
            set(BpodSystem.GUIHandles.OutcomePlot.EarlyWithdrawal, 'xdata', XData, 'ydata', YData);
        end
        if ~isempty(BpodSystem.Data.Custom.Jackpot)
            indxToPlot = mn:CurrentTrial;
            ndxJackpot = BpodSystem.Data.Custom.Jackpot(indxToPlot);
            XData = indxToPlot(ndxJackpot);
            YData = 0.5*ones(1,sum(ndxJackpot));
            set(BpodSystem.GUIHandles.OutcomePlot.Jackpot, 'xdata', XData, 'ydata', YData);
        end
        
        % GracePeriod
        BpodSystem.GUIHandles.OutcomePlot.HandleGracePeriod.Visible = 'on';
        set(get(BpodSystem.GUIHandles.OutcomePlot.HandleGracePeriod,'Children'),'Visible','on');
        cla(AxesHandles.HandleGracePeriod)
        BpodSystem.GUIHandles.OutcomePlot.HistGracePeriod = histogram(AxesHandles.HandleGracePeriod,BpodSystem.Data.Custom.GracePeriod(~isnan(BpodSystem.Data.Custom.GracePeriod)&~repmat(BpodSystem.Data.Custom.EarlyWithdrawal,50,1))*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistGracePeriod.BinWidth = 50;
        BpodSystem.GUIHandles.OutcomePlot.HistGracePeriod.FaceColor = 'g';
        BpodSystem.GUIHandles.OutcomePlot.HistGracePeriod.EdgeColor = 'none';
        BpodSystem.GUIHandles.OutcomePlot.HistGracePeriodEWD = histogram(AxesHandles.HandleGracePeriod,BpodSystem.Data.Custom.GracePeriod(~isnan(BpodSystem.Data.Custom.GracePeriod)&repmat(BpodSystem.Data.Custom.EarlyWithdrawal,50,1))*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistGracePeriodEWD.BinWidth = 50;
        BpodSystem.GUIHandles.OutcomePlot.HistGracePeriodEWD.FaceColor = 'r';
        BpodSystem.GUIHandles.OutcomePlot.HistGracePeriodEWD.EdgeColor = 'none';
%         LeftBias = sum(BpodSystem.Data.Custom.ChoiceLeft==1)/sum(~isnan(BpodSystem.Data.Custom.ChoiceLeft),2);
%         cornertext(AxesHandles.HandleMT,sprintf('Bias=%1.2f',LeftBias))

        % Trial rate
        BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate.Visible = 'on';
        set(get(BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate,'Children'),'Visible','on');
        BpodSystem.GUIHandles.OutcomePlot.TrialRate.XData = (BpodSystem.Data.TrialStartTimestamp-min(BpodSystem.Data.TrialStartTimestamp))/60;
        BpodSystem.GUIHandles.OutcomePlot.TrialRate.YData = 1:numel(BpodSystem.Data.Custom.ChoiceLeft(1:end-1));
        
        % SamplingTime
        BpodSystem.GUIHandles.OutcomePlot.HandleST.Visible = 'on';
        set(get(BpodSystem.GUIHandles.OutcomePlot.HandleST,'Children'),'Visible','on');
        cla(AxesHandles.HandleST)
        BpodSystem.GUIHandles.OutcomePlot.HistSTEarly = histogram(AxesHandles.HandleST,BpodSystem.Data.Custom.ST(BpodSystem.Data.Custom.EarlyWithdrawal)*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistSTEarly.BinWidth = 50;
        BpodSystem.GUIHandles.OutcomePlot.HistSTEarly.FaceColor = 'r';
        BpodSystem.GUIHandles.OutcomePlot.HistSTEarly.EdgeColor = 'none';
        BpodSystem.GUIHandles.OutcomePlot.HistST = histogram(AxesHandles.HandleST,BpodSystem.Data.Custom.ST(~BpodSystem.Data.Custom.EarlyWithdrawal)*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistST.BinWidth = 50;
        BpodSystem.GUIHandles.OutcomePlot.HistST.FaceColor = 'b';
        BpodSystem.GUIHandles.OutcomePlot.HistST.EdgeColor = 'none';
        BpodSystem.GUIHandles.OutcomePlot.HistSTJackpot = histogram(AxesHandles.HandleST,BpodSystem.Data.Custom.ST(BpodSystem.Data.Custom.Jackpot)*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistSTJackpot.BinWidth = 50;
        BpodSystem.GUIHandles.OutcomePlot.HistSTJackpot.FaceColor = 'g';
        BpodSystem.GUIHandles.OutcomePlot.HistSTJackpot.EdgeColor = 'none';
        EarlyP = sum(BpodSystem.Data.Custom.EarlyWithdrawal)/size(BpodSystem.Data.Custom.ChoiceLeft,2);
        cornertext(AxesHandles.HandleST,sprintf('P=%1.2f',EarlyP))
        
        % MovementTime
        BpodSystem.GUIHandles.OutcomePlot.HandleMT.Visible = 'on';
        set(get(BpodSystem.GUIHandles.OutcomePlot.HandleMT,'Children'),'Visible','on');
        cla(AxesHandles.HandleMT)
        BpodSystem.GUIHandles.OutcomePlot.HistMT = histogram(AxesHandles.HandleMT,BpodSystem.Data.Custom.MT(~BpodSystem.Data.Custom.EarlyWithdrawal)*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistMT.BinWidth = 50;
        BpodSystem.GUIHandles.OutcomePlot.HistMT.FaceColor = 'b';
        BpodSystem.GUIHandles.OutcomePlot.HistMT.EdgeColor = 'none';
        LeftBias = sum(BpodSystem.Data.Custom.ChoiceLeft==1)/sum(~isnan(BpodSystem.Data.Custom.ChoiceLeft),2);
        cornertext(AxesHandles.HandleMT,sprintf('Bias=%1.2f',LeftBias))

end

end

function [mn,mx] = rescaleX(AxesHandle,CurrentTrial,nTrialsToShow)
FractionWindowStickpoint = .75; % After this fraction of visible trials, the trial position in the window "sticks" and the window begins to slide through trials.
mn = max(round(CurrentTrial - FractionWindowStickpoint*nTrialsToShow),1);
mx = mn + nTrialsToShow - 1;
set(AxesHandle,'XLim',[mn-1 mx+1]);
end

function cornertext(h,str)
unit = get(h,'Units');
set(h,'Units','char');
pos = get(h,'Position');
if ~iscell(str)
    str = {str};
end
for i = 1:length(str)
    x = pos(1)+1;y = pos(2)+pos(4)-i;
    uicontrol(h.Parent,'Units','char','Position',[x,y,length(str{i})+1,1],'string',str{i},'style','text','background',[1,1,1],'FontSize',8);
end
set(h,'Units',unit);
end
