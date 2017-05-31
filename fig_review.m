function fig_review
%FIG_REVIEW Window for the review of existing ratings
% License: https://github.com/jmgirard/DARMA/blob/master/LICENSE.txt

    % Create and maximize annotation window
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    handles.figure_review = figure( ...
        'Name','DARMA: Review Ratings', ...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'ToolBar','none', ...
        'Visible','off', ...
        'Color',defaultBackground, ...
        'ResizeFcn',@figure_review_Resize, ...
        'CloseRequestFcn',@figure_review_CloseRequest);
    %Create menu bar elements
    handles.menu_media = uimenu(handles.figure_review, ...
        'Label','Media');        
    handles.menu_openmedia = uimenu(handles.menu_media, ...
        'Label','Open Media File', ...
        'Callback',@menu_openmedia_Callback);
    handles.menu_volume = uimenu(handles.menu_media, ...
        'Label','Adjust Volume', ...
        'Callback',@menu_volume_Callback);
    handles.menu_closemedia = uimenu(handles.menu_media, ...
        'Label','Close Media File', ...
        'Enable','off', ...
        'Callback',@menu_closemedia_Callback);
    handles.menu_annotations = uimenu(handles.figure_review, ...
        'Label','Annotations');
    handles.menu_addseries = uimenu(handles.menu_annotations, ...
        'Label','Import Annotation Files', ...
        'Callback',@addseries_Callback);
    handles.menu_remsel = uimenu(handles.menu_annotations, ...
        'Label','Remove Selected Annotation File', ...
        'Callback',@remsel_Callback);
    handles.menu_remall = uimenu(handles.menu_annotations, ...
        'Label','Remove All Annotation Files', ...
        'Callback',@remall_Callback);
    handles.menu_export = uimenu(handles.menu_annotations, ...
        'Label','Export Mean Series to New File', ...
        'Enable','off', ...
        'Callback',@menu_export_Callback);
    handles.menu_analyze = uimenu(handles.figure_review, ...
        'Label','Analyze');
    handles.menu_analyzeratings = uimenu(handles.menu_analyze, ...
        'Label','Analyze Ratings', ...
        'Enable','off', ...
        'Callback',@analyzeratings_Callback);
    handles.menu_help = uimenu(handles.figure_review, ...
        'Label','Help');
    handles.menu_about = uimenu(handles.menu_help, ...
        'Label','About', ...
        'Callback',@menu_about_Callback);
    handles.menu_document = uimenu(handles.menu_help, ...
        'Label','Documentation', ...
        'Callback',@menu_document_Callback);
    handles.menu_report = uimenu(handles.menu_help, ...
        'Label','Report Issues', ...
        'Callback',@menu_report_Callback);
    % Set minimum size
    set(handles.figure_review,'Units','normalized','Position',[0.1,0.1,0.8,0.8],'Visible','on');
    drawnow;
    jFig = get(handle(handles.figure_review),'JavaFrame');
    jClient = jFig.fHG2Client;
    jWindow = jClient.getWindow;
    jWindow.setMinimumSize(java.awt.Dimension(1024,768));
    %Create uicontrol elements
    global ts_X ts_Y;
    lc = .01; rc = .89;
    handles.axis_X = axes('Units','Normalized', ...
        'Parent',handles.figure_review, ...
        'TickLength',[0.005 0], ...
        'OuterPosition',[0 0 1 1], ...
        'Position',[lc+.01 .24 .86 .16], ...
        'YLim',[-100,100],'YTick',linspace(-100,100,5),'YTickLabel',[],'YGrid','on', ...
        'XLim',[0,11],'XTick',(1:10),'Box','on', ...
        'PickableParts','none', ...
        'ButtonDownFcn',{@axis_click_Callback,'X'});
    ylabel('X Axis','FontSize',10);
    hold on;
    ts_X = plot(handles.axis_X,[0,0],[-100,100],'k');
    hold off;
    handles.axis_Y = axes('Units','Normalized', ...
        'Parent',handles.figure_review, ...
        'TickLength',[0.005 0], ...
        'OuterPosition',[0 0 1 1], ...
        'Position',[lc+.01 .04 .86 .16], ...
        'YLim',[-100,100],'YTick',linspace(-100,100,5),'YTickLabel',[],'YGrid','on', ...
        'XLim',[0,11],'XTick',(1:10),'Box','on', ...
        'PickableParts','none', ...
        'ButtonDownFcn',{@axis_click_Callback,'Y'});
    ylabel('Y Axis','FontSize',10);
    hold on;
    ts_Y = plot(handles.axis_Y,[0,0],[-100,100],'k');
    hold off;
    handles.listbox = uicontrol('Style','listbox', ...
        'Parent',handles.figure_review, ...
        'Units','normalized', ...
        'FontSize',10, ...
        'Position',[rc .42 .10 .565], ...
        'Callback',@listbox_Callback);
    handles.push_addfile = uicontrol('Style','pushbutton', ...
        'Parent',handles.figure_review, ...
        'Units','normalized', ...
        'Position',[rc .35 10/100 4.5/100], ...
        'String','Add Annotations', ...
        'FontSize',12, ...
        'Callback',@addseries_Callback);
    handles.push_remsel = uicontrol('Style','pushbutton', ...
        'Parent',handles.figure_review, ...
        'Units','normalized', ...
        'Position',[rc .30 10/100 4.5/100], ...
        'String','Remove Selected', ...
        'FontSize',12, ...
        'Callback',@remsel_Callback);
    handles.push_remall = uicontrol('Style','pushbutton', ...
        'Parent',handles.figure_review, ...
        'Units','normalized', ...
        'Position',[rc .25 10/100 4.5/100], ...
        'String','Remove All Files', ...
        'FontSize',12, ...
        'Callback',@remall_Callback);
    handles.toggle_meanplot = uicontrol('Style','togglebutton', ...
        'Parent',handles.figure_review, ...
        'Units','normalized', ...
        'Position',[rc .20 10/100 4.5/100], ...
        'String','Show Mean Plot', ...
        'FontSize',12, ...
        'Enable','off', ...
        'Callback',@meanplot_Callback);
    handles.push_analyze = uicontrol('Style','pushbutton', ...
        'Parent',handles.figure_review, ...
        'Units','normalized', ...
        'Position',[rc .15 10/100 4.5/100], ...
        'String','Analyze Ratings', ...
        'FontSize',12, ...
        'Enable','off', ...
        'Callback',@analyzeratings_Callback);
    handles.axis_guide = axes('Units','normalized', ...
        'Parent',handles.figure_review, ...
        'Position',[lc*2 .42 .50 .565], ...
        'Box','on','XTick',[],'YTick',[],'Color','black');
    handles.axis_C = axes('Units','normalized', ...
        'Parent',handles.figure_review, ...
        'OuterPosition',[.53 .42 .35 .565], ...
        'TickLength',[0 0], ...
        'YLim',[-100,100],'YTick',linspace(-100,100,3),'YTickLabel',[],'YMinorGrid','on', ...
        'XLim',[-100,100],'XTick',linspace(-100,100,3),'XTickLabel',[],'XMinorGrid','on', ...
        'Box','on','NextPlot','add', ...
        'LooseInset',[0 0 0 0],'PlotBoxAspectRatioMode','manual','PlotBoxAspectRatio',[1 1 1]);
    handles.axis_C.YRuler.MinorTickValues = linspace(-100,100,5);
    handles.axis_C.XRuler.MinorTickValues = linspace(-100,100,5);
    set(handles.axis_C,'YGrid','on','XGrid','on','GridColor',[.5 .5 .5],'GridAlpha',1);
    handles.toggle_playpause = uicontrol('Style','togglebutton', ...
        'Parent',handles.figure_review, ...
        'Units','Normalized', ...
        'Position',[rc .02 .10 .10], ...
        'String','Play', ...
        'FontSize',16.0, ...
        'Enable','off', ...
        'Callback',@toggle_playpause_Callback);
    % Invoke and configure VLC ActiveX Controller
    handles.vlc = actxcontrol('VideoLAN.VLCPlugin.2',getpixelposition(handles.axis_guide),handles.figure_review);
    handles.vlc.AutoPlay = 0;
    handles.vlc.Toolbar = 0;
    handles.vlc.FullscreenEnabled = 0;
    % Preallocate variables
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

function menu_openmedia_Callback(hObject,~)
    handles = guidata(hObject);
    % Reset the GUI elements
    handles.vlc.playlist.items.clear();
    % Browse for, load, and get text_duration for a media file
    [video_name,video_path] = uigetfile({'*.*','All Files (*.*)'},'Select an audio or video file:');
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
        set(handles.menu_closemedia,'Enable','on');
        set(handles.axis_X,'XLim',[0,handles.dur],'XTick',round(linspace(0,handles.dur,11)),'PickableParts','Visible');
        set(handles.axis_Y,'XLim',[0,handles.dur],'XTick',round(linspace(0,handles.dur,11)),'PickableParts','Visible');
    catch err
        msgbox(err.message,'Error loading media file.','error'); return;
    end
    guidata(handles.figure_review,handles);
end

% ===============================================================================

function menu_volume_Callback(hObject,~)
    handles = guidata(hObject);
    ovol = handles.vlc.audio.volume;
    nvol = inputdlg(sprintf('Enter volume percentage:\n0=Mute, 100=Full Sound'),'',1,{num2str(ovol)});
    nvol = str2double(nvol);
    if isempty(nvol), return; end
    if isnan(nvol), return; end
    if nvol < 0, nvol = 0; end
    if nvol > 100, nvol = 100; end
    handles.vlc.audio.volume = nvol;
    guidata(handles.figure_review,handles);
end

% ===============================================================================

function menu_closemedia_Callback(hObject,~)
    handles = guidata(hObject);
    handles.vlc.playlist.stop();
    handles.vlc.playlist.items.clear();
    set(handles.menu_closemedia,'Enable','off');
    guidata(handles.figure_review,handles);
end

% ===============================================================================

function menu_export_Callback(hObject,~)
    handles = guidata(hObject);
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
        {'Media File'},{sprintf('%s%s',name,ext)},{''},{''}; ...
        {'Magnitude'},{handles.mag},{''},{''}; ...
        {'Second'},{handles.labelX},{handles.labelY},{'B'}; ...
        {'%%%%%%'},{'%%%%%%'},{'%%%%%%'},{'%%%%%%'}; ...
        num2cell([handles.Seconds,handles.MeanRatingsX,handles.MeanRatingsY,zeros(length(handles.Seconds),1)])];
    %Prompt user for output filepath
    [filename,pathname] = uiputfile({'*.csv','Comma-Separated Values (*.csv)'},'Save as',defaultname);
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

function menu_about_Callback(~,~)
    global version;
    msgbox(sprintf('DARMA version %.2f\nJeffrey M Girard (c) 2014-2017\nhttp://darma.jmgirard.com\nGNU General Public License v3',version),'About','Help');
end

% ===============================================================================

function menu_document_Callback(~,~)
    web('https://github.com/jmgirard/DARMA/wiki','-browser');
end

% ===============================================================================

function menu_report_Callback(~,~)
    web('https://github.com/jmgirard/DARMA/issues','-browser');
end

% ===============================================================================

function addseries_Callback(hObject,~)
    handles = guidata(hObject);
    if get(handles.toggle_meanplot,'Value')==1
        msgbox('Please turn off mean plotting before adding annotation files.');
        return;
    end
    % Prompt user for import file.
    [filenames,pathname] = uigetfile({'*.csv;*.xlsx;*.xls','DARMA Annotations (*.csv, *.xlsx, *.xls)'},'Open Annotations','','MultiSelect','on');
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
        % Check that the import file matches the media file
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
        disp = handles.AllFilenames{i};
        disp(disp=='_') = '-';
        rows = [cellstr(rows);sprintf('<html><font color="%s">[%02d]</font> %s',rgbconv(CS(colorindex,:)),i,disp)];
    end
    set(handles.listbox,'String',rows,'Value',1,'ButtonDownFcn',@listbox_Callback);
    plot_centroids(handles.figure_review,[]);
    delete(w);
    set(handles.menu_analyzeratings,'Enable','on');
    set(handles.push_analyze,'Enable','on');
    if size(handles.AllRatingsX,2)>1
        set(handles.menu_export,'Enable','on');
        set(handles.toggle_meanplot,'Enable','on');
    end
    guidata(handles.figure_review,handles);
end

% ===============================================================================

function remsel_Callback(hObject,~)
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
        guidata(handles.figure_review,handles);
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
        set(handles.toggle_meanplot,'Enable','off','Value',0);
        set(handles.menu_export,'Enable','off');
        set(handles.menu_analyzeratings,'Enable','off');
        set(handles.push_analyze,'Enable','off');
    elseif size(handles.AllRatingsX,2)==1
        disp = handles.AllFilenames{1};
        disp(disp=='_') = '-';
        rows = [cellstr(rows);sprintf('<html><font color="%s">[%02d]</font> %s',rgbconv(CS(1,:)),1,disp)];
        set(handles.toggle_meanplot,'Enable','off','Value',0);
        set(handles.menu_export,'Enable','off');
    else
        for i = 1:size(handles.AllRatingsX,2)
            colorindex = mod(i,7); if colorindex==0, colorindex = 7; end
            disp = handles.AllFilenames{i};
            disp(disp=='_') = '-';
            rows = [cellstr(rows);sprintf('<html><font color="%s">[%02d]</font> %s',rgbconv(CS(colorindex,:)),i,disp)];
        end
        meanplot_Callback(handles.toggle_meanplot,[]);
    end
    set(handles.listbox,'String',rows);
    listbox_Callback(handles.listbox,[]);
    % Update guidata with handles
    guidata(handles.figure_review,handles);
end

% ===============================================================================

function remall_Callback(hObject,~)
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
    set(handles.toggle_meanplot,'Enable','off','Value',0);
    set(handles.menu_export,'Enable','off');
    set(handles.menu_analyzeratings,'Enable','off');
    set(handles.push_analyze,'Enable','off');
    set(handles.listbox,'String',rows);
    % Update guidata with handles
    guidata(handles.figure_review,handles);
end

% ===============================================================================

function meanplot_Callback(hObject,~)
    handles = guidata(hObject);
    update_plots(handles);
    if get(handles.toggle_meanplot,'Value')==1
        %If toggle is set to on, update list box with mean series
        set(handles.listbox,'Value',size(handles.AllRatingsX,2)+2);
        set(handles.toggle_meanplot,'String','Hide Mean Plot');
        rows = {'<html><u>Annotation Files'};
        for i = 1:size(handles.AllRatingsX,2)
            disp = handles.AllFilenames{i};
            disp(disp=='_') = '-';
            rows = [cellstr(rows);sprintf('<html><font color="%s">[%02d]</font> %s',rgbconv([.8 .8 .8]),i,disp)];
        end
        rows = [cellstr(rows);'<html><font color="red">[M]</font> Mean Plot'];
        set(handles.listbox,'String',rows);
    elseif get(handles.toggle_meanplot,'Value')==0
        %If toggle is set to off, update list box without mean series
        set(handles.listbox,'Value',1);
        set(handles.toggle_meanplot,'String','Show Mean Plot');
        CS = get(gca,'ColorOrder');
        rows = {'<html><u>Annotation Files'};
        for i = 1:size(handles.AllRatingsX,2)
           colorindex = mod(i,7); if colorindex==0, colorindex = 7; end
           disp = handles.AllFilenames{i};
           disp(disp=='_') = '-';
           rows = [cellstr(rows);sprintf('<html><font color="%s">[%02d]</font> %s',rgbconv(CS(colorindex,:)),i,disp)];
        end
        set(handles.listbox,'String',rows);
    end
    guidata(hObject,handles);
    listbox_Callback(handles.figure_review,[]);
end

% ===============================================================================

function analyzeratings_Callback(hObject,~)
    handles = guidata(hObject);
    fig_analyze(handles.AllRatingsX,handles.AllRatingsY,handles.AllFilenames,handles.labelX,handles.labelY,handles.mag);
end

% ===============================================================================

function toggle_playpause_Callback(hObject,~)
    handles = guidata(hObject);
    if get(hObject,'Value')==get(hObject,'Max')
        % Do this when play/resume toggle is clicked
        handles.vlc.playlist.play();
        start(handles.timer2);
        set(hObject,'String','Pause');
        set(handles.menu_media,'Enable','off');
        set(handles.menu_annotations,'Enable','off');
        set(handles.menu_export,'Enable','off');
        set(handles.menu_analyze,'Enable','off');
        set(handles.menu_help,'Enable','off');
        set(handles.listbox,'Enable','inactive');
        set(handles.push_addfile,'Enable','off');
        set(handles.push_remsel,'Enable','off');
        set(handles.push_remall,'Enable','off');
        set(handles.toggle_meanplot,'Enable','off');
        set(handles.push_analyze,'Enable','off');
    else
        % Do this when pause toggle is clicked
        handles.vlc.playlist.togglePause();
        stop(handles.timer2);
        set(hObject,'String','Resume');
        set(handles.menu_media,'Enable','on');
        set(handles.menu_annotations,'Enable','on');
        set(handles.menu_analyze,'Enable','on');
        set(handles.menu_help,'Enable','on');
        set(handles.listbox,'Enable','on');
        set(handles.push_addfile,'Enable','on');
        set(handles.push_remsel,'Enable','on');
        set(handles.push_remall,'Enable','on');
        if size(handles.AllRatingsX,2)>1
            set(handles.menu_export,'Enable','on');
            set(handles.toggle_meanplot,'Enable','on');
        end
        if ~isempty(handles.AllRatingsX)
            set(handles.menu_analyzeratings,'Enable','on');
            set(handles.push_analyze,'Enable','on');
        end
    end
    guidata(hObject, handles);
    drawnow();
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
        set(handles.menu_media,'Enable','on');
        set(handles.menu_annotations,'Enable','on');
        set(handles.menu_analyze,'Enable','on');
        set(handles.menu_help,'Enable','on');
        set(handles.listbox,'Enable','on');
        set(handles.push_addfile,'Enable','on');
        set(handles.push_remsel,'Enable','on');
        set(handles.push_remall,'Enable','on');
        set(handles.push_analyze,'Enable','on');
        if size(handles.AllRatingsX,2)>1
            set(handles.menu_export,'Enable','on');
            set(handles.toggle_meanplot,'Enable','on');
        end
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
    set(handles.axis_C, ...
        'XLim',[-1*handles.mag,handles.mag],'YLim',[-1*handles.mag,handles.mag], ...
        'XTick',linspace(-1*handles.mag,handles.mag,3),'YTick',linspace(-1*handles.mag,handles.mag,3));
    handles.axis_C.YRuler.MinorTickValues = linspace(-1*handles.mag,handles.mag,5);
    handles.axis_C.XRuler.MinorTickValues = linspace(-1*handles.mag,handles.mag,5);
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
        set(gca,'YTick',linspace(-1*handles.mag,handles.mag,5),'YTickLabel',[],'YGrid','on','TickLength',[0.005 0]);
        ylabel(handles.labelX,'FontSize',10);
        set(handles.axis_X,'ButtonDownFcn',{@axis_click_Callback,'X'});
        ts_X = plot(handles.axis_X,[0,0],[handles.mag,-1*handles.mag],'k');
        hold off;
        % Configure second (Y) axis for normal plots
        axes(handles.axis_Y); cla;
        plot(handles.Seconds,handles.AllRatingsY,'-','LineWidth',2,'ButtonDownFcn',{@axis_click_Callback,'Y'});
        hold on;
        ylim([-1*handles.mag,handles.mag]);
        xlim([0,ceil(max(handles.Seconds))+1]);
        set(gca,'YTick',linspace(-1*handles.mag,handles.mag,5),'YTickLabel',[],'YGrid','on','TickLength',[0.005 0]);
        ylabel(handles.labelY,'FontSize',10);
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
        set(gca,'YTick',linspace(-1*handles.mag,handles.mag,5),'YTickLabel',[],'YGrid','on');
        ylabel(handles.labelX,'FontSize',10);
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
        set(gca,'YTick',linspace(-1*handles.mag,handles.mag,5),'YTickLabel',[],'YGrid','on');
        ylabel(handles.labelY,'FontSize',10);
        ts_Y = plot(handles.axis_Y,[0,0],[handles.mag,-1*handles.mag],'k');
        hold off;
    end
    guidata(handles.figure_review,handles);
end

% ===============================================================================

function figure_review_Resize(hObject,~)
    handles = guidata(hObject);
    if isfield(handles,'figure_review') && isfield(handles,'vlc')
        % Update the size and position of the VLC controller
        move(handles.vlc,getpixelposition(handles.axis_guide));
    end
end

% =========================================================

function figure_review_CloseRequest(hObject,~)
    handles = guidata(hObject);
    delete(timerfind);
    delete(handles.figure_review);
end