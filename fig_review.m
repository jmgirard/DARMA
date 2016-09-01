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
        'Label','Add Annotation File(s)', ...
        'Callback',@menu_addseries_Callback);
    handles.menu_delseries = uimenu(handles.figure_review, ...
        'Parent',handles.figure_review, ...
        'Label','Remove Annotation Files');
    handles.menu_delall = uimenu(handles.menu_delseries, ...
        'Parent',handles.menu_delseries, ...
        'Label','Remove All Files', ...
        'Callback',@menu_delall_Callback);
    handles.menu_delone = uimenu(handles.menu_delseries, ...
        'Parent',handles.menu_delseries, ...
        'Label','Remove Selected File', ...
        'Callback',@menu_delone_Callback);
    handles.menu_export = uimenu(handles.figure_review, ...
        'Parent',handles.figure_review, ...
        'Label','Export Mean Ratings', ...
        'Enable','off', ...
        'Callback',@menu_export_Callback);
    handles.menu_stats = uimenu(handles.figure_review, ...
        'Parent',handles.figure_review, ...
        'Label','Reliability Type');
    handles.menu_agree = uimenu(handles.menu_stats, ...
        'Parent',handles.menu_stats, ...
        'Label','Agreement ICC', ...
        'Checked','on', ...
        'Callback',@menu_agree_Callback);
    handles.menu_consist = uimenu(handles.menu_stats, ...
        'Parent',handles.menu_stats, ...
        'Label','Consistency ICC', ...
        'Callback',@menu_consist_Callback);
    handles.menu_help = uimenu(handles.figure_review, ...
        'Parent',handles.figure_review, ...
        'Label','Help');
    handles.menu_about = uimenu(handles.menu_help, ...
        'Parent',handles.menu_help, ...
        'Label','About', ...
        'Callback',@menu_about_Callback);
    handles.menu_document = uimenu(handles.menu_help, ...
        'Parent',handles.menu_help, ...
        'Label','Documentation', ...
        'Callback',@menu_document_Callback);
    handles.menu_report = uimenu(handles.menu_help, ...
        'Parent',handles.menu_help, ...
        'Label','Report Issues', ...
        'Callback',@menu_report_Callback);
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
        'FontSize',10, ...
        'Position',[rc .485 .10 .50], ...
        'Callback',@listbox_Callback);
    handles.toggle_meanplot = uicontrol('Style','togglebutton', ...
        'Parent',handles.figure_review, ...
        'Units','normalized', ...
        'Position',[rc .435 10/100 4.5/100], ...
        'String','Toggle Mean Plot', ...
        'FontSize',12, ...
        'Enable','off', ...
        'Callback',@toggle_meanplot_Callback);
    handles.reliability = uitable(...
        'Parent',handles.figure_review, ...
        'Units','normalized', ...
        'Position',[rc .14 .10 .29], ...
        'ColumnName',[], ...
        'RowName',[], ...
        'Data',[], ...
        'FontSize',10);
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
        'Enable','off', ...
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
    global stats; stats = 'agree';
    addpath('Functions');
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
        set(handles.toggle_playpause,'String','Play','Enable','on');
    catch err
        msgbox(err.message,'Error loading multimedia file.'); return;
    end
    guidata(handles.figure_review,handles);
end

% ===============================================================================

function menu_addseries_Callback(hObject,~)
    handles = guidata(hObject);
    if get(handles.toggle_meanplot,'Value')==1
        msgbox('Please turn off mean plotting before adding annotation files.');
        return;
    end
    global settings;
    % Prompt user for import file.
    [filenames,pathname] = uigetfile({'*.csv;*.xlsx;*.xls','DARMA Annotations (*.csv, *.xlsx, *.xls)'},'Open Annotations',fullfile(settings.folder),'MultiSelect','on');
    if ~iscell(filenames)
        if filenames==0, return; end
        filenames = {filenames};
    end
    w = waitbar(0,'Importing annotation files...');
    for f = 1:length(filenames)
        filename = filenames{f};
        [~,~,ext] = fileparts(filename);
        if strcmp(ext,'.csv')
            fileID = fopen(fullfile(pathname,filename),'r');
            magcell = textscan(fileID,'%*s%f%*s%*s%[^\n\r]',1,'Delimiter',',', 'HeaderLines',2,'ReturnOnError',false);
            mag = magcell{1};
            fclose(fileID);
            fileID = fopen(fullfile(pathname,filename),'r');
            labels = textscan(fileID,'%*s%s%s%*s%[^\n\r]',1, 'Delimiter',',','HeaderLines',3,'ReturnOnError',false);
            labelX = labels{1}{1};
            labelY = labels{2}{1};
            fclose(fileID);
            fileID = fopen(fullfile(pathname,filename),'r');
            datacell = textscan(fileID,'%f%f%f%f%[^\n\r]','Delimiter',',','HeaderLines',5,'ReturnOnError',false);
            data = [datacell{:,1},datacell{:,2},datacell{:,3}];
            fclose(fileID);
        else
            [nums,txts] = xlsread(fullfile(pathname,filename),'','','basic');
            mag = nums(3,2);
            labelX = txts{4,2};
            labelY = txts{4,3};
            data = nums(6:end,1:3);
        end
        % Get settings from import file    
        if isempty(handles.mag)
            handles.mag = mag;
            handles.labelX = labelX;
            handles.labelY = labelY;
        elseif handles.mag ~= mag
            msgbox('Annotation files must have the same magnitude to be loaded together.','Error','Error');
            return;
        end
        % Check that the import file matches the multimedia file
        if ~isempty(handles.AllRatingsX) && size(handles.AllRatingsX,1)~=size(data,1)
            msgbox('Annotation file must have the same bin size as the other annotation files.','Error','Error');
            return;
        else
            % Append the new file to the stored data
            handles.Seconds = data(:,1);
            handles.AllRatingsX = [handles.AllRatingsX,data(:,2)];
            handles.AllRatingsY = [handles.AllRatingsY,data(:,3)];
            [~,fn,~] = fileparts(filename);
            handles.AllFilenames = [handles.AllFilenames;fn];
            % Update mean series
            handles.MeanRatingsX = nanmean(handles.AllRatingsX,2);
            handles.MeanRatingsY = nanmean(handles.AllRatingsY,2);
            guidata(hObject,handles);
        end
        waitbar(f/length(filenames));
    end
    update_plots(handles);
    % Update list box
    CS = get(gca,'ColorOrder');
    rows = {'<html><u>Annotation Files'};
    for i = 1:size(handles.AllRatingsX,2)
        colorindex = mod(i,7); if colorindex==0, colorindex = 7; end
        rows = [cellstr(rows);sprintf('<html><font color="%s">[%02d]</font> %s',rgbconv(CS(colorindex,:)),i,handles.AllFilenames{i})];
    end
    set(handles.listbox,'String',rows,'Value',1,'ButtonDownFcn',@listbox_Callback);
    % Update reliability box
    box = reliability(handles.AllRatingsX,handles.AllRatingsY);
    set(handles.reliability,'Data',box);
    plot_centroids(handles.figure_review,[]);
    guidata(handles.figure_review,handles);
    delete(w);
    set(handles.toggle_meanplot,'Enable','on');
    set(handles.menu_export,'Enable','on');
    guidata(handles.figure_review,handles);
end

% ===============================================================================

function menu_delone_Callback(hObject,~)
    handles = guidata(hObject);
    if get(handles.toggle_meanplot,'Value')==1
        msgbox('Please turn off mean plotting before removing annotation files.');
        return;
    end
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
        rows = [cellstr(rows);sprintf('<html><font color="%s">[%02d]</font> %s',rgbconv(CS(1,:)),1,handles.AllFilenames{1})];
        box = reliability(handles.AllRatingsX,handles.AllRatingsY);
        set(handles.toggle_meanplot,'Enable','off','Value',0);
        set(handles.menu_export,'Enable','off');
    else
        for i = 1:size(handles.AllRatingsX,2)
            colorindex = mod(i,7); if colorindex==0, colorindex = 7; end
            rows = [cellstr(rows);sprintf('<html><font color="%s">[%02d]</font> %s',rgbconv(CS(colorindex,:)),i,handles.AllFilenames{i})];
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

function menu_delall_Callback(hObject,~)
    handles = guidata(hObject);
    if get(handles.toggle_meanplot,'Value')==1
        msgbox('Please turn off mean plotting before removing annotation files.');
        return;
    end
    handles.AllRatingsX = zeros(0,1);
    handles.AllRatingsY = zeros(0,1);
    handles.MeanRatingsX = zeros(0,1);
    handles.MeanRatingsY = zeros(0,1);
    handles.AllFilenames = cell(0,1);
    handles.mag = zeros(0,1);
    cla(handles.axis_C);
    cla(handles.axis_X);
    cla(handles.axis_Y);
    set(handles.axis_X,'PickableParts','none');
    set(handles.axis_Y,'PickableParts','none');
    % Update list box
    set(handles.listbox,'Value',1);
    rows = {'<html><u>Annotation Files'};
    box = '';
    set(handles.toggle_meanplot,'Enable','off','Value',0);
    set(handles.menu_export,'Enable','off');
    set(handles.listbox,'String',rows);
    set(handles.reliability,'Data',box);
    % Update guidata with handles
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
    [filename,pathname] = uiputfile({'*.csv','Comma-Separated Values (*.csv)'},'Save as',fullfile(settings.folder,defaultname));
    if isequal(filename,0), return; end
    % Create export file as a CSV
    success = cell2csv(fullfile(pathname,filename),output);
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

function menu_agree_Callback(hObject,~)
    handles = guidata(hObject);
    global stats;
    stats = 'agree';
    box = reliability(handles.AllRatingsX,handles.AllRatingsY);
    set(handles.reliability,'Data',box);
    set(handles.menu_agree,'Checked','on');
    set(handles.menu_consist,'Checked','off');
    guidata(handles.figure_review,handles);
end

% ===============================================================================

function menu_consist_Callback(hObject,~)
    handles = guidata(hObject);
    global stats;
    stats = 'consist';
    box = reliability(handles.AllRatingsX,handles.AllRatingsY);
    set(handles.reliability,'Data',box);
    set(handles.menu_agree,'Checked','off');
    set(handles.menu_consist,'Checked','on');
    guidata(handles.figure_review,handles);
end

% ===============================================================================

function menu_about_Callback(~,~)
    msgbox(sprintf('DARMA version 5.04\nJeffrey M Girard (c) 2014-2016\nhttp://darma.codeplex.com\nGNU General Public License v3'),'About','Help');
end

% ===============================================================================

function menu_document_Callback(~,~)
    web('http://darma.codeplex.com/documentation','-browser');
end

% ===============================================================================

function menu_report_Callback(~,~)
    web('http://darma.codeplex.com/discussions','-browser');
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
            rows = [cellstr(rows);sprintf('<html><font color="%s">[%02d]</font> %s',rgbconv([.8 .8 .8]),i,handles.AllFilenames{i})];
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
           rows = [cellstr(rows);sprintf('<html><font color="%s">[%02d]</font> %s',rgbconv(CS(colorindex,:)),i,handles.AllFilenames{i})];
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
    global ts_X;
    global ts_Y;
    if handles.vlc.input.state == 3
        % While playing, update annotations plot
        ts = handles.vlc.input.time/1000;
        set(ts_X,'XData',[ts,ts]);
        set(ts_Y,'XData',[ts,ts]);
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
    global ts_X;
    global ts_Y;
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
    set(ts_X,'XData',[ts,ts]);
    set(ts_Y,'XData',[ts,ts]);
    drawnow();
end

% ===============================================================================

function listbox_Callback(hObject,~)
    handles = guidata(hObject);
    if isempty(handles.AllRatingsX), return; end
    val = get(handles.listbox,'value')-1;
    cla(handles.axis_C);
    if val == 0, plot_centroids(hObject); return; end
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
        set(h,'FaceAlpha',min([size(dataX,1),10])/size(dataX,1),'EdgeColor','none');
    end
    text(900,0,handles.labelX,'HorizontalAlignment','center','BackgroundColor',[1 1 1],'FontSize',12,'Margin',5,'Rotation',-90);
    text(0,900,handles.labelY,'HorizontalAlignment','center','BackgroundColor',[1 1 1],'FontSize',12,'Margin',5);
end

% ===============================================================================
function plot_centroids(hObject,~)
    handles = guidata(hObject);
    cla(handles.axis_C);
    set(handles.axis_C,'XLim',[-1*handles.mag,handles.mag],'YLim',[-1*handles.mag,handles.mag]);
    axes(handles.axis_C);
    CS = get(gca,'ColorOrder');
    for i = 1:size(handles.AllRatingsX,2)
        dataX = handles.AllRatingsX(:,i);
        dataY = handles.AllRatingsY(:,i);
        a  = 2*(nanstd(dataX)); %horizontal radius
        b  = 2*(nanstd(dataY)); %vertical radius
        x0 = nanmean(dataX); % x0,y0 ellipse centre coordinates
        y0 = nanmean(dataY);
        t  = -pi:0.01:pi;
        x  = x0 + a*cos(t);
        y  = y0 + b*sin(t);
        colorindex = mod(i,7); if colorindex==0, colorindex = 7; end
        col = CS(colorindex,:);
        h = fill(x,y,col);
        axis square;
        set(h,'FaceAlpha',1/3,'EdgeColor','none');
        plot(x0,y0,'o','MarkerFaceColor',col,'MarkerEdgeColor',[0 0 0],'MarkerSize',10);
    end
    for i = 1:size(handles.AllRatingsX,2)
        dataX = handles.AllRatingsX(:,i);
        dataY = handles.AllRatingsY(:,i);
        x0 = nanmean(dataX); % x0,y0 ellipse centre coordinates
        y0 = nanmean(dataY);
        colorindex = mod(i,7); if colorindex==0, colorindex = 7; end
        col = CS(colorindex,:);
        plot(x0,y0,'o','MarkerFaceColor',col,'MarkerEdgeColor',[0 0 0],'MarkerSize',10);
    end
    text(900,0,handles.labelX,'HorizontalAlignment','center','BackgroundColor',[1 1 1],'FontSize',12,'Margin',5,'Rotation',-90);
    text(0,900,handles.labelY,'HorizontalAlignment','center','BackgroundColor',[1 1 1],'FontSize',12,'Margin',5);
end

% ===============================================================================

function update_plots(handles)
    handles = guidata(handles.figure_review);
    global ts_X;
    global ts_Y;
    if isempty(handles.AllRatingsX), return; end
    if get(handles.toggle_meanplot,'Value')==get(handles.toggle_meanplot,'Min')
        % Configure first (X) axis for normal plots
        axes(handles.axis_X); cla;
        plot(handles.Seconds,handles.AllRatingsX,'-','LineWidth',2,'ButtonDownFcn',{@axis_click_Callback,'X'});
        hold on;
        ylim([-1*handles.mag,handles.mag]);
        xlim([0,ceil(max(handles.Seconds))+1]);
        set(gca,'YTick',0,'YTickLabel',[],'YGrid','on');
        ylabel(sprintf('%s (X)',handles.labelX),'FontSize',10);
        set(handles.axis_X,'ButtonDownFcn',{@axis_click_Callback,'X'});
        ts_X = plot(handles.axis_X,[0,0],[handles.mag,-1*handles.mag],'k');
        hold off;
        % Configure second (Y) axis for normal plots
        axes(handles.axis_Y); cla;
        plot(handles.Seconds,handles.AllRatingsY,'-','LineWidth',2,'ButtonDownFcn',{@axis_click_Callback,'Y'});
        hold on;
        ylim([-1*handles.mag,handles.mag]);
        xlim([0,ceil(max(handles.Seconds))+1]);
        set(gca,'YTick',0,'YTickLabel',[],'YGrid','on');
        ylabel(sprintf('%s (Y)',handles.labelY),'FontSize',10);
        set(handles.axis_Y,'ButtonDownFcn',{@axis_click_Callback,'Y'});
        handles.CS = get(gca,'ColorOrder');
        ts_Y = plot(handles.axis_Y,[0,0],[handles.mag,-1*handles.mag],'k');
        hold off;
    elseif get(handles.toggle_meanplot,'Value')==get(handles.toggle_meanplot,'Max')
        % Configure first (X) axis for mean plots
        axes(handles.axis_X); cla;
        set(handles.axis_X,'ButtonDownFcn',{@axis_click_Callback,'X'});
        hold on;
        plot(handles.Seconds,handles.AllRatingsX,'-','LineWidth',2,'Color',[.8 .8 .8],'ButtonDownFcn',{@axis_click_Callback,'X'});
        plot(handles.Seconds,handles.MeanRatingsX,'-','LineWidth',2,'Color',[1 0 0],'ButtonDownFcn',{@axis_click_Callback,'X'});
        ylim([-1*handles.mag,handles.mag]);
        xlim([0,ceil(max(handles.Seconds))+1]);
        set(gca,'YTick',0,'YTickLabel',[],'YGrid','on');
        ylabel(sprintf('%s (X)',handles.labelX),'FontSize',10);
        ts_X = plot(handles.axis_X,[0,0],[handles.mag,-1*handles.mag],'k');
        hold off;
        % Configure second (Y) axis for mean plots
        axes(handles.axis_Y); cla;
        set(handles.axis_Y,'ButtonDownFcn',{@axis_click_Callback,'Y'});
        hold on;
        plot(handles.Seconds,handles.AllRatingsY,'-','LineWidth',2,'Color',[.8 .8 .8],'ButtonDownFcn',{@axis_click_Callback,'Y'});
        plot(handles.Seconds,handles.MeanRatingsY,'-','LineWidth',2,'Color',[1 0 0],'ButtonDownFcn',{@axis_click_Callback,'Y'});
        ylim([-1*handles.mag,handles.mag]);
        xlim([0,ceil(max(handles.Seconds))+1]);
        set(gca,'YTick',0,'YTickLabel',[],'YGrid','on');
        ylabel(sprintf('%s (Y)',handles.labelY),'FontSize',10);
        ts_Y = plot(handles.axis_Y,[0,0],[handles.mag,-1*handles.mag],'k');
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
        rel_width = getpixelposition(handles.reliability);
        handles.reliability.ColumnWidth = {floor(rel_width(3)/2)-1};
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

function [box] = reliability(X, Y)
	global stats;
    % Find and remove rows that contain NaNs
    index = any(isnan(X),2);
    X2 = X;
    Y2 = Y;
    X2(index,:) = [];
    Y2(index,:) = [];
	x_k = size(X2,2);
    y_k = size(Y2,2);
    % Populate reliability window
    if x_k == 1
        box = { ...
            '[01] X Mean',num2str(nanmean(X),'%.0f'); ...
            '[01] X SD',num2str(nanstd(X),'%.0f'); ...
            '[01] Y Mean',num2str(nanmean(Y),'%.0f'); ...
            '[01] Y SD',num2str(nanstd(Y),'%.0f')};
    elseif x_k > 1
        if strcmp(stats,'agree')
            box = {'X ICC(A,1)',num2str(ICC_A_1(X2),'%.3f'); ...
                'Y ICC(A,1)',num2str(ICC_A_1(Y2),'%.3f'); ...
                'X ICC(A,k)',num2str(ICC_A_k(X2),'%.3f'); ...
                'Y ICC(A,k)',num2str(ICC_A_k(Y2),'%.3f')};
        elseif strcmp(stats,'consist')
            box = {'X ICC(C,1)',num2str(ICC_C_1(X2),'%.3f'); ...
                'Y ICC(C,1)',num2str(ICC_C_1(Y2),'%.3f'); ...
                'X ICC(C,k)',num2str(ICC_C_k(X2),'%.3f'); ...
                'Y ICC(C,k)',num2str(ICC_C_k(Y2),'%.3f')};
        end
        for i = 1:x_k
            box = [box;{sprintf('[%02d] X Mean',i),num2str(nanmean(X(:,i)),'%.0f');}];
        end
        for i = 1:x_k
            box = [box;{sprintf('[%02d] X SD',i),num2str(nanstd(X(:,i)),'%.0f');}];
        end
        for i = 1:y_k
            box = [box;{sprintf('[%02d] Y Mean',i),num2str(nanmean(Y(:,i)),'%.0f');}];
        end
        for i = 1:y_k
            box = [box;{sprintf('[%02d] Y SD',i),num2str(nanstd(Y(:,i)),'%.0f');}];
        end
    end
    
end