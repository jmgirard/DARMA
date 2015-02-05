function fig_review
%FIG_REVIEW Window for the review of existing ratings
% License: https://darma.codeplex.com/license

    % Create and maximize annotation window
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    handles.figure_review = figure( ...
        'Units','normalized', ...
        'Position',[0.1 0.1 0.8 0.8], ...
        'Name','DARMA: Review', ...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'ToolBar','none', ...
        'Visible','off', ...
        'Color',defaultBackground, ...
        'SizeChangedFcn',@figure_review_SizeChanged, ...
        'CloseRequestFcn',@figure_review_CloseRequest);
    %Create menu bar elements
    handles.menu_multimedia = uimenu(handles.figure_review, ...
        'Parent',handles.figure_review, ...
        'Label','Open Multimedia File', ...
        'Callback',@menu_multimedia_Callback);
    handles.menu_addseries = uimenu(handles.figure_review, ...
        'Parent',handles.figure_review, ...
        'Label','Add Annotation File', ...
        'Callback',@button_addseries_Callback);
    handles.menu_delseries = uimenu(handles.figure_review, ...
        'Parent',handles.figure_review, ...
        'Label','Remove Annotation File', ...
        'Callback',@button_delseries_Callback);
    handles.menu_export = uimenu(handles.figure_review, ...
        'Parent',handles.figure_review, ...
        'Label','Export Mean Ratings', ...
        'Enable','off', ...
        'Callback',@menu_export_Callback);
    pause(0.1);
    %Create uicontrol elements
    lc = .01; rc = .89;
    handles.axis_X = axes('Units','Normalized', ...
        'Parent',handles.figure_review, ...
        'TickLength',[0.05 0], ...
        'OuterPosition',[0 0 1 1], ...
        'Position',[lc+.01 .24 .86 .16], ...
        'YTick',0,'YTickLabel',[],'YGrid','on', ...
        'XTick',0,'XTickLabel',[],'Box','on', ...
        'PickableParts','none', ...
        'ButtonDownFcn',{@axis_click_Callback,'X'});
    handles.axis_Y = axes('Units','Normalized', ...
        'Parent',handles.figure_review, ...
        'TickLength',[0.05 0], ...
        'OuterPosition',[0 0 1 1], ...
        'Position',[lc+.01 .04 .86 .16], ...
        'YTick',0,'YTickLabel',[],'YGrid','on', ...
        'XTick',0,'XTickLabel',[],'Box','on', ...
        'PickableParts','none', ...
        'ButtonDownFcn',{@axis_click_Callback,'Y'});
    handles.listbox = uicontrol('Style','listbox', ...
        'Parent',handles.figure_review, ...
        'Units','normalized', ...
        'FontSize',8, ...
        'Position',[rc .485 .10 .50], ...
        'Callback',@listbox_Callback);
    handles.button_addseries = uicontrol('Style','pushbutton', ...
        'Parent',handles.figure_review, ...
        'Units','normalized', ...
        'Position',[rc .445 3/100 3/100], ...
        'String','+', ...
        'FontSize',16, ...
        'TooltipString','Add Annotation File', ...
        'Callback',@button_addseries_Callback);
    handles.button_delseries = uicontrol('Style','pushbutton', ...
        'Parent',handles.figure_review, ...
        'Units','normalized', ...
        'Position',[rc+.005+3/100 .445 3/100 3/100], ...
        'String','–', ...
        'FontSize',16, ...
        'TooltipString','Remove Annotation File', ...
        'Callback',@button_delseries_Callback);
    handles.toggle_meanplot = uicontrol('Style','togglebutton', ...
        'Parent',handles.figure_review, ...
        'Units','normalized', ...
        'Position',[rc+.01+6/100 .445 3/100 3/100], ...
        'String','m', ...
        'FontSize',14, ...
        'TooltipString','Toggle Mean Plot', ...
        'Enable','off', ...
        'Callback',@toggle_meanplot_Callback);
    pos = getpixelposition(handles.figure_review);
    handles.reliability = uitable(...
        'Parent',handles.figure_review, ...
        'Units','normalized', ...
        'Position',[rc .14 .10 .29], ...
        'ColumnWidth',{pos(3)*.099*.65,pos(3)*.099*.25}, ...
        'ColumnName',[], ...
        'RowName',[], ...
        'Data',[], ...
        'FontSize',8);
    handles.axis_guide = axes('Units','normalized', ...
        'Parent',handles.figure_review, ...
        'Position',[lc*2 .42 .50 .565], ...
        'Box','on','XTick',[],'YTick',[],'Color','black');
    handles.axis_C = axes('Units','normalized', ...
        'Parent',handles.figure_review, ...
        'OuterPosition',[.53 .42 .35 .565], ...
        'XTick',[],'YTick',[],'Box','on', ...
        'YTick',0,'YTickLabel',[],'YGrid','on', ...
        'XTick',0,'XTickLabel',[],'XGrid','on', ...
        'NextPlot','add', ...
        'LooseInset',[0 0 0 0]);
    handles.toggle_playpause = uicontrol('Style','togglebutton', ...
        'Parent',handles.figure_review, ...
        'Units','Normalized', ...
        'Position',[rc .02 .10 .10], ...
        'String','Play', ...
        'FontSize',16.0, ...
        'Callback',@toggle_playpause_Callback);
    % Invoke and configure WMP ActiveX Controller
    handles.vlc = actxcontrol('VideoLAN.VLCPlugin.2',getpixelposition(handles.axis_guide),handles.figure_review);
    handles.vlc.AutoPlay = 0;
    handles.vlc.Toolbar = 0;
    handles.vlc.FullscreenEnabled = 0;
    % Prepopulate variables
    set(handles.listbox,'String',{'<html><u>Annotation Files'},'Value',1);
    handles.AllFilenames = cell(0,1);
    handles.AllRatingsX = zeros(0,1);
    handles.AllRatingsY = zeros(0,1);
    handles.MeanRatingsX = zeros(0,1);
    handles.MeanRatingsY = zeros(0,1);
    handles.mag = zeros(0,1);
    handles.labelX = cell(0,1);
    handles.labelY = cell(0,1);
    handles.MRL = cell(0,1);
    % Create timer
	handles.timer2 = timer(...
        'ExecutionMode','fixedRate', ...
        'Period',0.20, ...
        'TimerFcn',{@timer2_Callback,handles});
    % Save handles to guidata
    guidata(handles.figure_review,handles);
    handles.figure_review.Visible = 'on';
end

% ===============================================================================

function menu_multimedia_Callback(hObject,~)
    handles = guidata(hObject);
    global settings;
    % Reset the GUI elements
    handles.vlc.playlist.items.clear();
    % Browse for, load, and get text_duration for a multimedia file
    [video_name,video_path] = uigetfile({'*.*','All Files (*.*)'},'Select an audio or video file:',fullfile(settings.folder));
    if video_name==0, return; end
    try
        MRL = fullfile(video_path,video_name);
        MRL(MRL=='\') = '/';
        handles.MRL = sprintf('file://localhost/%s',MRL);
        handles.vlc.playlist.add(handles.MRL);
        handles.vlc.playlist.play();
        while handles.vlc.input.state ~= 3
            pause(0.001);
        end
        handles.vlc.playlist.togglePause();
        handles.vlc.input.time = 0;
        handles.dur = handles.vlc.input.length / 1000;
        set(handles.axis_X,'PickableParts','visible');
        set(handles.axis_Y,'PickableParts','visible');
    catch err
        msgbox(err.message,'Error loading multimedia file.'); return;
    end
    guidata(handles.figure_review,handles);
end

% ===============================================================================

function menu_export_Callback(hObject,~)
    handles = guidata(hObject);
    global settings;
    if isempty(handles.MRL)
        %TODO: Pull this information from the annotation file
        name = ''; ext = '';
        defaultname = 'Mean';
    else
        [~,name,ext] = fileparts(handles.MRL);
        defaultname = sprintf('%s_Mean',name);
    end
    output = [ ...
        {'Time of Rating'},{datestr(now)},{''},{''}; ...
        {'Multimedia File'},{sprintf('%s%s',name,ext)},{''},{''}; ...
        {'Magnitude'},{handles.mag},{''},{''}; ...
        {'Second'},{handles.labelX},{handles.labelY},{'B'}; ...
        {'%%%%%%'},{'%%%%%%'},{'%%%%%%'},{'%%%%%%'}; ...
        num2cell([handles.Seconds,handles.MeanRatingsX,handles.MeanRatingsY,zeros(length(handles.Seconds),1)])];
    %Prompt user for output filepath
    [filename,pathname] = uiputfile({'*.xlsx','Excel 2007 Spreadsheet (*.xlsx)';...
        '*.xls','Excel 2003 Spreadsheet (*.xls)';...
        '*.csv','Comma-Separated Values (*.csv)'},'Save as',fullfile(settings.folder,defaultname));
    if isequal(filename,0), return; end
    % Create export file depending on selected file type
    [~,~,ext] = fileparts(filename);
    if strcmpi(ext,'.XLS') || strcmpi(ext,'.XLSX')
        % Create XLS/XLSX file if that is the selected file type
        [success,message] = xlswrite(fullfile(pathname,filename),output);
        if strcmp(message.identifier,'MATLAB:xlswrite:dlmwrite')
            % If Excel is not installed, create CSV file instead
            serror = errordlg('Exporting to .XLS/.XLSX requires Microsoft Excel to be installed. DARMA will now export to .CSV instead.');
            uiwait(serror);
            success = fx_cell2csv(fullfile(pathname,filename),output);
        end
    elseif strcmpi(ext,'.CSV')
        % Create CSV file if that is the selected file type
        success = fx_cell2csv(fullfile(pathname,filename),output);
    end
    % Report saving success or failure
    if success
        h = msgbox('Export successful.');
        waitfor(h);
    else
        h = msgbox('Export error.');
        waitfor(h);
    end
end

% ===============================================================================

function button_addseries_Callback(hObject,~)
    handles = guidata(hObject);
    global settings;
    % Prompt user for import file.
    [filenames,pathname] = uigetfile({'*.xls; *.xlsx; *.csv','DARMA Export Formats (*.xls, *.xlsx, *.csv)'},'Open Annotations',fullfile(settings.folder),'MultiSelect','on');
    if ~iscell(filenames)
        if filenames==0, return; end
        filenames = {filenames};
    end
    for f = 1:length(filenames)
        filename = filenames{f};
        [~,~,data] = xlsread(fullfile(pathname,filename));
        % Get settings from import file    
        if isempty(handles.mag)
            handles.mag = data{3,2};
            handles.labelX = data{4,2};
            handles.labelY = data{4,3};
        elseif handles.mag ~= data{3,2}
            msgbox('Annotation files must have the same magnitude to be loaded together.','Error','Error');
            return;
        end
        % Check that the import file matches the multimedia file
        if ~isempty(handles.AllRatingsX) && size(handles.AllRatingsX,1)~=size(data(6:end,:),1)
            msgbox('Annotation file must have the same sampling rate as the other annotation files.','Error','Error');
            return;
        else
            % Append the new file to the stored data
            handles.Seconds = cell2mat(data(6:end,1));
            handles.AllRatingsX = [handles.AllRatingsX,cell2mat(data(6:end,2))];
            handles.AllRatingsY = [handles.AllRatingsY,cell2mat(data(6:end,3))];
            [~,fn,~] = fileparts(filename);
            handles.AllFilenames = [handles.AllFilenames;fn];
            % Update mean series
            handles.MeanRatingsX = nanmean(handles.AllRatingsX,2);
            handles.MeanRatingsY = nanmean(handles.AllRatingsY,2);
            guidata(hObject,handles);
            update_plots(handles);
            % Update list box
            CS = get(gca,'ColorOrder');
            rows = {'<html><u>Annotation Files'};
            for i = 1:size(handles.AllRatingsX,2)
                colorindex = mod(i,7); if colorindex==0, colorindex = 7; end
                rows = [cellstr(rows);sprintf('<html><font color="%s">[%02d]</font> %s',fx_rgbconv(CS(colorindex,:)),i,handles.AllFilenames{i})];
            end
            set(handles.listbox,'String',rows,'Value',size(handles.AllRatingsX,2)+1,'ButtonDownFcn',@listbox_Callback);
            % Update reliability box
            box = reliability(handles.AllRatingsX,handles.AllRatingsY);
            set(handles.reliability,'Data',box);
            listbox_Callback(handles.figure_review,[]);
            guidata(handles.figure_review,handles);
        end
    end
    set(handles.toggle_meanplot,'Enable','on');
    set(handles.menu_export,'Enable','on');
    guidata(handles.figure_review,handles);
end

% ===============================================================================

function button_delseries_Callback(hObject,~)
    handles = guidata(hObject);
    % Get currently selected item
    index = get(handles.listbox,'Value')-1;
    % Cancel if the first row is selected
    if index == 0, return; end
    % Cancel if only one row remains
    if size(handles.AllRatingsX,2)<2,
        handles.AllRatingsX = zeros(0,1);
        handles.AllRatingsY = zeros(0,1);
        handles.MeanRatingsX = zeros(0,1);
        handles.MeanRatingsY = zeros(0,1);
        handles.AllFilenames = cell(0,1);
        handles.mag = zeros(0,1);
        cla(handles.axis_X);
        cla(handles.axis_Y);
        cla(handles.axis_C);
        set(handles.axis_X,'PickableParts','none');
        set(handles.axis_Y,'PickableParts','none');
    else
        % Remove the selected item from program
        handles.AllRatingsX(:,index) = [];
        handles.AllRatingsY(:,index) = [];
        handles.AllFilenames(index) = [];
        % Update mean series
        handles.MeanRatingsX = nanmean(handles.AllRatingsX,2);
        handles.MeanRatingsY = nanmean(handles.AllRatingsY,2);
        guidata(handles.figure_review,handles);
        update_plots(handles);
    end
    % Update list box
    set(handles.listbox,'Value',1);
    CS = get(gca,'ColorOrder');
    rows = {'<html><u>Annotation Files'};
    if isempty(handles.AllRatingsX)
        box = '';
        set(handles.toggle_meanplot,'Enable','off','Value',0);
        set(handles.menu_export,'Enable','off');
    elseif size(handles.AllRatingsX,2)==1
        rows = [cellstr(rows);sprintf('<html><font color="%s">[%02d]</font> %s',fx_rgbconv(CS(1,:)),1,handles.AllFilenames{1})];
        box = reliability(handles.AllRatingsX,handles.AllRatingsY);
        set(handles.toggle_meanplot,'Enable','off','Value',0);
        set(handles.menu_export,'Enable','off');
    else
        for i = 1:size(handles.AllRatingsX,2)
            colorindex = mod(i,7); if colorindex==0, colorindex = 7; end
            rows = [cellstr(rows);sprintf('<html><font color="%s">[%02d]</font> %s',fx_rgbconv(CS(colorindex,:)),i,handles.AllFilenames{i})];
        end
        box = reliability(handles.AllRatingsX,handles.AllRatingsY);
        toggle_meanplot_Callback(handles.toggle_meanplot,[]);
    end
    set(handles.listbox,'String',rows);
    set(handles.reliability,'Data',box);
    listbox_Callback(handles.listbox,[]);
    % Update guidata with handles
    guidata(handles.figure_review,handles);
end

% ===============================================================================

function toggle_meanplot_Callback(hObject,~)
    handles = guidata(hObject);
    update_plots(handles);
    if get(hObject,'Value')==get(hObject,'Max')
        %If toggle is set to on, update list box with mean series
        set(handles.listbox,'Value',size(handles.AllRatingsX,2)+2);
        rows = {'<html><u>Annotation Files'};
        for i = 1:size(handles.AllRatingsX,2)
            rows = [cellstr(rows);sprintf('<html><font color="%s">[%02d]</font> %s',fx_rgbconv([.8 .8 .8]),i,handles.AllFilenames{i})];
        end
        rows = [cellstr(rows);'<html><font color="red">[M]</font> Mean Plot'];
        set(handles.listbox,'String',rows);
    elseif get(hObject,'Value')==get(hObject,'Min')
        %If toggle is set to off, update list box without mean series
        set(handles.listbox,'Value',1);
        CS = get(gca,'ColorOrder');
        rows = {'<html><u>Annotation Files'};
        for i = 1:size(handles.AllRatingsX,2)
           colorindex = mod(i,7); if colorindex==0, colorindex = 7; end
           rows = [cellstr(rows);sprintf('<html><font color="%s">[%02d]</font> %s',fx_rgbconv(CS(colorindex,:)),i,handles.AllFilenames{i})];
        end
        set(handles.listbox,'String',rows);
    end
    guidata(hObject,handles);
    listbox_Callback(handles.figure_review,[]);
end

% ===============================================================================

function toggle_playpause_Callback(hObject,~)
    handles = guidata(hObject);
    if get(hObject,'Value')==get(hObject,'Max')
        % Send play() command to VLC and start timer
        handles.vlc.playlist.play();
        start(handles.timer2);
        set(hObject,'String','Pause');
        set(handles.menu_multimedia,'Enable','off');
        set(handles.menu_export,'Enable','off');
    else
        % Send pause() command to VLC and stop timer
        handles.vlc.playlist.togglePause();
        stop(handles.timer2);
        set(hObject,'String','Resume','Value',0);
        set(handles.menu_multimedia,'Enable','on');
        set(handles.menu_export,'Enable','on');
    end
    guidata(hObject, handles);
end

% ===============================================================================

function timer2_Callback(~,~,handles)
    handles = guidata(handles.figure_review);
    if handles.vlc.input.state == 3
        % While playing, update annotations plot
        ts = handles.vlc.input.time/1000;
        update_plots(handles);
        axes(handles.axis_X);
        hold on;
        plot(handles.axis_X,[ts,ts],[handles.mag,-1*handles.mag],'k');
        hold off;
        axes(handles.axis_Y);
        hold on;
        plot(handles.axis_Y,[ts,ts],[handles.mag,-1*handles.mag],'k');
        hold off;
        drawnow();
    elseif handles.vlc.input.state == 6 || handles.vlc.input.state == 5
        % When done, send stop() command to VLC
        stop(handles.timer2);
        update_plots(handles);
        set(handles.toggle_playpause,'String','Play','Value',0);
        set(handles.menu_export,'Enable','on');
        handles.vlc.input.time = 0;
    else
        % Otherwise, wait
        return;
    end
end

% ===============================================================================

function axis_click_Callback(hObject,~,axis)
    handles = guidata(hObject);
    % Jump VLC playback to clicked position
    if strcmp(axis,'X')
        coord = get(handles.axis_X,'CurrentPoint');
    elseif strcmp(axis,'Y')
        coord = get(handles.axis_Y,'CurrentPoint');
    end
    duration = handles.vlc.input.length;
    if coord(1,1) > 0 && coord(1,1)*1000 < duration
        % if clicked on a valid position, go to that position
        handles.vlc.input.time = coord(1,1)*1000;
    else
        % if clicked on an invalid position, go to video start
        handles.vlc.input.time = 0;
    end
    pause(.05);
    % While playing, update annotations plot
    ts = handles.vlc.input.time/1000;
    update_plots(handles);
    axes(handles.axis_X);
    hold on;
    plot(handles.axis_X,[ts,ts],[handles.mag,-1*handles.mag],'k');
    hold off;
    axes(handles.axis_Y);
    hold on;
    plot(handles.axis_Y,[ts,ts],[handles.mag,-1*handles.mag],'k');
    hold off;
    drawnow();
end

% ===============================================================================

function listbox_Callback(hObject,~)
    handles = guidata(hObject);
    val = get(handles.listbox,'value')-1;
    cla(handles.axis_C);
    if val == 0, return; end
    set(handles.axis_C,'XLim',[-1*handles.mag,handles.mag],'YLim',[-1*handles.mag,handles.mag]);
    axes(handles.axis_C);
    CS = get(gca,'ColorOrder');
    colorindex = mod(val,7); if colorindex==0, colorindex = 7; end
    if get(handles.toggle_meanplot,'Value')==get(handles.toggle_meanplot,'Min')
        %If mean plot is toggled off, get all ratings for the selected series
        dataX = handles.AllRatingsX(:,val);
        dataY = handles.AllRatingsY(:,val);
        col = CS(colorindex,:);
    elseif get(handles.toggle_meanplot,'Value')==get(handles.toggle_meanplot,'Max') && val==size(handles.AllRatingsX,2)+1
        %If mean plot is toggled on, get all ratings for the mean series
        dataX = handles.MeanRatingsX;
        dataY = handles.MeanRatingsY;
        col = [1 0 0];
    else
        dataX = handles.AllRatingsX(:,val);
        dataY = handles.AllRatingsY(:,val);
        col = [.8 .8 .8];
    end
    for i = 1:size(dataX,1)
        %Plot semi-transparent circle
        THETA = linspace(0,2*pi,10);
        RHO = ones(1,10)*handles.mag/15;
        [X,Y] = pol2cart(THETA,RHO);
        X = X+dataX(i);
        Y = Y+dataY(i);
        h = fill(X,Y,col);
        axis square;
        set(h,'FaceAlpha',10/size(dataX,1),'EdgeColor','none');
    end
end

% ===============================================================================

function update_plots(handles)
    handles = guidata(handles.figure_review);
    if isempty(handles.AllRatingsX), return; end
    if get(handles.toggle_meanplot,'Value')==get(handles.toggle_meanplot,'Min')
        % Configure first (X) axis for normal plots
        axes(handles.axis_X); cla;
        plot(handles.Seconds,handles.AllRatingsX,'-','LineWidth',2,'ButtonDownFcn',{@axis_click_Callback,'X'});
        ylim([-1*handles.mag,handles.mag]);
        xlim([0,ceil(max(handles.Seconds))+1]);
        set(gca,'YTick',0,'YTickLabel',[],'YGrid','on');
        ylabel(sprintf('%s (X)',handles.labelX),'FontSize',10);
        set(handles.axis_X,'ButtonDownFcn',{@axis_click_Callback,'X'});
        % Configure second (Y) axis for normal plots
        axes(handles.axis_Y); cla;
        plot(handles.Seconds,handles.AllRatingsY,'-','LineWidth',2,'ButtonDownFcn',{@axis_click_Callback,'Y'});
        ylim([-1*handles.mag,handles.mag]);
        xlim([0,ceil(max(handles.Seconds))+1]);
        set(gca,'YTick',0,'YTickLabel',[],'YGrid','on');
        ylabel(sprintf('%s (Y)',handles.labelY),'FontSize',10);
        set(handles.axis_Y,'ButtonDownFcn',{@axis_click_Callback,'Y'});
        handles.CS = get(gca,'ColorOrder');
    elseif get(handles.toggle_meanplot,'Value')==get(handles.toggle_meanplot,'Max')
        % Plot each series of ratings in blue and the mean series in red
        axes(handles.axis_X); cla;
        set(handles.axis_X,'ButtonDownFcn',{@axis_click_Callback,'X'});
        hold on;
        plot(handles.Seconds,handles.AllRatingsX,'-','LineWidth',2,'Color',[.8 .8 .8],'ButtonDownFcn',{@axis_click_Callback,'X'});
        plot(handles.Seconds,handles.MeanRatingsX,'-','LineWidth',2,'Color',[1 0 0],'ButtonDownFcn',{@axis_click_Callback,'X'});
        ylim([-1*handles.mag,handles.mag]);
        xlim([0,ceil(max(handles.Seconds))+1]);
        set(gca,'YTick',0,'YTickLabel',[],'YGrid','on');
        ylabel(sprintf('%s (X)',handles.labelX),'FontSize',10);
        axes(handles.axis_Y); cla;
        set(handles.axis_Y,'ButtonDownFcn',{@axis_click_Callback,'Y'});
        hold on;
        plot(handles.Seconds,handles.AllRatingsY,'-','LineWidth',2,'Color',[.8 .8 .8],'ButtonDownFcn',{@axis_click_Callback,'Y'});
        plot(handles.Seconds,handles.MeanRatingsY,'-','LineWidth',2,'Color',[1 0 0],'ButtonDownFcn',{@axis_click_Callback,'Y'});
        ylim([-1*handles.mag,handles.mag]);
        xlim([0,ceil(max(handles.Seconds))+1]);
        set(gca,'YTick',0,'YTickLabel',[],'YGrid','on');
        ylabel(sprintf('%s (Y)',handles.labelY),'FontSize',10);
        hold off;
    end
    guidata(handles.figure_review,handles);
end

% ===============================================================================

function figure_review_SizeChanged(hObject,~)
    handles = guidata(hObject);
    if isfield(handles,'figure_review')
        pos = getpixelposition(handles.figure_review);
        % Force to remain above a minimum size
        if pos(3) < 1024 || pos(4) < 600
            setpixelposition(handles.figure_review,[pos(1) pos(2) 1024 600]);
            movegui(handles.figure_review,'center');
        end
        % Update the size and position of the VLC controller
        if isfield(handles,'vlc')
            move(handles.vlc,getpixelposition(handles.axis_guide));
        end
    end
end

% =========================================================

function figure_review_CloseRequest(hObject,~)
    handles = guidata(hObject);
    % Remove timer as part of cleanup
    delete(handles.timer2);
    delete(gcf);
end

% =========================================================

function [box] = reliability( X, Y )
	x_k = size(X,2);
	x_alpha = x_k/(x_k-1)*(var(nansum(X'))-nansum(var(X)))/var(nansum(X'));
    y_k = size(Y,2);
	y_alpha = y_k/(y_k-1)*(var(nansum(Y'))-nansum(var(Y)))/var(nansum(Y'));
    
    if x_k == 1
        box = {'# Raters','1'; ...
            '[01] X Mean',num2str(nanmean(X),'%.0f'); ...
            '[01] X SD',num2str(nanstd(X),'%.0f'); ...
            '[01] Y Mean',num2str(nanmean(Y),'%.0f'); ...
            '[01] Y SD',num2str(nanstd(Y),'%.0f')};
    elseif x_k == 2
        box = {'# Raters','2'; ...
            'X Alpha',num2str(x_alpha,'%.3f'); ...
            '[01] X Mean',num2str(nanmean(X(:,1)),'%.0f'); ...
            '[02] X Mean',num2str(nanmean(X(:,2)),'%.0f'); ...
            '[01] X SD',num2str(nanstd(X(:,1)),'%.0f'); ...
            '[02] X SD',num2str(nanstd(X(:,2)),'%.0f'); ...
            'Y Alpha',num2str(y_alpha,'%.3f'); ...
            '[01] Y Mean',num2str(nanmean(Y(:,1)),'%.0f'); ...
            '[02] Y Mean',num2str(nanmean(Y(:,2)),'%.0f'); ...
            '[01] Y SD',num2str(nanstd(Y(:,1)),'%.0f'); ...
            '[02] Y SD',num2str(nanstd(Y(:,2)),'%.0f')};
    elseif x_k > 2
        box = {'# Raters',num2str(x_k,'%d')};
        box = [box;{'X Alpha',num2str(x_alpha,'%.3f')}];
        for i = 1:x_k
            box = [box;{sprintf('[%02d] X Mean',i),num2str(nanmean(X(:,i)),'%.0f');}];
        end
        for i = 1:x_k
            box = [box;{sprintf('[%02d] X SD',i),num2str(nanstd(X(:,i)),'%.0f');}];
        end
        box = [box;{'Y Alpha',num2str(y_alpha,'%.3f')}];
        for i = 1:y_k
            box = [box;{sprintf('[%02d] Y Mean',i),num2str(nanmean(Y(:,i)),'%.0f');}];
        end
        for i = 1:y_k
            box = [box;{sprintf('[%02d] Y SD',i),num2str(nanstd(Y(:,i)),'%.0f');}];
        end
    end
    
end