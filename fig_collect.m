function fig_collect
%FIG_COLLECT Window for the collection of ratings
% License: https://darma.codeplex.com/license

    % Get default settings
    if isdeployed
        handles.settings = importdata(fullfile(ctfroot,'DARMA','default.mat'));
    else
        handles.settings = importdata('default.mat');
    end
    % Create and center main window
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    handles.figure_collect = figure( ...
        'Units','normalized', ...
        'Name','DARMA: Collect Ratings', ...
        'MenuBar','none', ...
        'ToolBar','none', ...
        'NumberTitle','off', ...
        'Visible','off', ...
        'Color',defaultBackground, ...
        'SizeChangedFcn',@figure_collect_SizeChanged, ...
        'KeyPressFcn',@figure_collect_KeyPress, ...
        'CloseRequestFcn',@figure_collect_CloseReq);
    % Create menu bar elements
    handles.menu_media = uimenu(handles.figure_collect, ...
        'Label','Media');        
    handles.menu_openmedia = uimenu(handles.menu_media, ...
        'Label','Open Media File', ...
        'Callback',@menu_openmedia_Callback);
    handles.menu_volume = uimenu(handles.menu_media, ...
        'Label','Adjust Volume', ...
        'Callback',@menu_volume_Callback);
    handles.menu_preview = uimenu(handles.menu_media, ...
        'Label','Preview Media File', ...
        'Enable','off', ...
        'Callback',@menu_preview_Callback);
    handles.menu_closemedia = uimenu(handles.menu_media, ...
        'Label','Close Media File', ...
        'Enable','off', ...
        'Callback',@menu_closemedia_Callback);
    handles.menu_settings = uimenu(handles.figure_collect, ...
        'Label','Settings');
    handles.menu_axislabels = uimenu(handles.menu_settings, ...
        'Label','Set Axis Labels', ...
        'Callback',@menu_axislabels_Callback);
    handles.menu_magnitude = uimenu(handles.menu_settings, ...
        'Label','Set Axis Magnitude', ...
        'Callback',@menu_magnitude_Callback);
    handles.menu_binsize = uimenu(handles.menu_settings, ...
        'Label','Set Bin Size', ...
        'Callback',@menu_binsize_Callback);
    handles.menu_defaultdir = uimenu(handles.menu_settings, ...
        'Label','Set Default Folder', ...
        'Callback',@menu_defaultdir_Callback);
    handles.menu_help = uimenu(handles.figure_collect, ...
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
    pause(0.1);
    set(handles.figure_collect,'Position',[0.1 0.1 0.8 0.8]);
    % Create uicontrol elements
    handles.axis_info = axes(handles.figure_collect, ...
        'Units','normalized', ...
        'Position',[.01 .02 .63 .05], ...
        'XLim',[0,100],'YLim',[0,1], ...
        'XTick',(0:10:100),'TickLength',[0.005 0],'XTickLabel',[], ...
        'Box','on','Layer','top','YTick',[]);
    handles.timebar = rectangle(handles.axis_info, ...
        'Position',[0,0,0,1],'FaceColor',[0.000,0.447,0.741]);
    handles.text_filename = text(handles.axis_info, ...
        50,0.5,'Media Filename','HorizontalAlignment','center','Interpreter','none');
    handles.text_timestamp = text(handles.axis_info, ...
        05,0.5,'00:00:00','HorizontalAlignment','center');
    handles.text_duration = text(handles.axis_info, ...
        95,0.5,'00:00:00','HorizontalAlignment','center');
    pos = getpixelposition(handles.figure_collect);
    handles.table_info = uitable(handles.figure_collect, ...
        'Units','normalized', ...
        'Position',[.65 .02 .22 .05], ...
        'RowName',[],'ColumnName',{'Bin Size','Axis Magnitude'}, ...
        'ColumnWidth',num2cell(repmat(round(pos(3)*.22 / 2 - 2),1,2)),'FontSize',10, ...
        'Data',{handles.settings.binsizenum,handles.settings.magnum});
    jscrollpane = findjobj(handles.table_info);
    jTable = jscrollpane.getViewport.getView;
    cellStyle = jTable.getCellStyleAt(0,0);
    cellStyle.setHorizontalAlignment(cellStyle.CENTER);
    jTable.repaint;
    handles.toggle_playpause = uicontrol(handles.figure_collect, ...
        'Style','togglebutton', ...
        'Units','Normalized', ...
        'Position',[.88 .02 .11 .05], ...
        'String','Begin Rating', ...
        'FontSize',14.0, ...
        'Callback',@toggle_playpause_Callback, ...
        'Enable','off');
    handles.axis_guide = axes(handles.figure_collect, ...
        'Units','normalized', ...
        'Position',[.01 .09 .63 .89], ...
        'Box','on','XTick',[],'YTick',[],'Color','black');
    handles.axis_circle = axes(handles.figure_collect, ...
        'Units','normalized', ...
        'OuterPosition',[.65 .09 .34 .89], ...
        'LooseInset',[0 0 0 0], ...
        'XLim',[-1,1],'YLim',[-1,1], ...
        'NextPlot','add', ...
        'Box','on','XTick',[],'YTick',[],'Layer','top');
    axis square;
    % Invoke and configure VLC ActiveX Controller
    handles.vlc = actxcontrol('VideoLAN.VLCPlugin.2',getpixelposition(handles.axis_guide),handles.figure_collect);
    handles.vlc.AutoPlay = 0;
    handles.vlc.Toolbar = 0;
    handles.vlc.FullscreenEnabled = 0;
    try
        handles.joy = vrjoystick(1);
    catch
        e = errordlg('DARMA could not detect a joystick.','Error','modal');
        waitfor(e);
        return;
    end
    % Create timer
    handles.recording = 0;
    handles.timer = timer(...
        'ExecutionMode','fixedRate', ...
        'Period',0.05, ...
        'TimerFcn',{@timer_Callback,handles}, ...
        'ErrorFcn',{@timer_ErrorFcn,handles});
    % Start system clock to improve VLC time stamp precision
    global global_tic recording;
    global_tic = tic;
    recording = 0;
    % Save handles to guidata
    handles.figure_collect.Visible = 'on';
    guidata(handles.figure_collect,handles);
    create_axis(handles);
    addpath('Functions');
    start(handles.timer);
end

% =========================================================

function menu_openmedia_Callback(hObject,~)
    handles = guidata(hObject);
    % Reset the GUI elements
    program_reset(handles);
    global ratings last_ts_vlc last_ts_sys;
    ratings = [];
    last_ts_vlc = 0;
    last_ts_sys = 0;
    handles.vlc.playlist.items.clear();
    % Browse for, load, and get text_duration for a media file
    [video_name,video_path] = uigetfile({'*.*','All Files (*.*)'},'Select an audio or video file',handles.settings.defaultdir);
    if video_name==0, return; end
    try
        MRL = fullfile(video_path,video_name);
        handles.VID = MRL;
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
        if handles.dur == 0
            handles.vlc.playlist.items.clear();
            error('Could not read duration of media file. The file meta-data may be damaged. Transcoding the streams (e.g., with HandBrake) may fix this problem.');
        end
    catch err
        msgbox(err.message,'Error loading media file.'); return;
    end
    % Update GUI elements
    set(handles.timebar,'Position',[0 0 0 1]);
    set(handles.text_timestamp,'String','00:00:00');
    set(handles.text_filename,'String',video_name);
    set(handles.text_duration,'String',datestr(handles.dur/24/3600,'HH:MM:SS'));
    set(handles.menu_preview,'Enable','on');
    set(handles.menu_closemedia,'Enable','on');
    set(handles.toggle_playpause,'Enable','on');
    guidata(hObject,handles);
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
    guidata(handles.figure_collect,handles);
end

% ===============================================================================

function menu_preview_Callback(hObject,~)
    handles = guidata(hObject);
    winopen(handles.VID);
end

% ===============================================================================

function menu_closemedia_Callback(hObject,~)
    handles = guidata(hObject);
    handles.vlc.playlist.stop();
    handles.vlc.playlist.items.clear();
    set(handles.menu_settings,'Enable','on');
    set(handles.menu_closemedia,'Enable','off');
    set(handles.menu_preview,'Enable','off');
    set(handles.timebar,'Position',[0 0 0 1]);
    set(handles.text_timestamp,'String','00:00:00');
    set(handles.text_filename,'String','Media Filename');
    set(handles.text_duration,'String','00:00:00');
    guidata(handles.figure_collect,handles);
end

% ===============================================================================

function menu_axislabels_Callback(hObject,~)
    handles = guidata(hObject);
    settings = handles.settings;
    stop(handles.timer);
    d = dialog('Position',[0 0 500 480],'Name','Set Axis Labels','Visible','off');
    movegui(d,'center');
    set(d,'Visible','on');
    uicontrol(d, ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[.10 .875 .25 .075], ...
        'String','Interpersonal', ...
        'FontSize',12, ...
        'Callback',@push_interpersonal_Callback);
    uicontrol(d, ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[.375 .875 .25 .075], ...
        'String','Affective', ...
        'FontSize',12, ...
        'Callback',@push_affective_Callback);
    uicontrol(d, ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[.65 .875 .25 .075], ...
        'String','Clear', ...
        'FontSize',12, ...
        'Callback',@push_clear_Callback);
    axes(d, ... 
        'Units','normalized', ...
        'Position',[.10 .25 .80 .60], ...
        'NextPlot','add', ...
        'XTick',[],'YTick',[],'Box','on');
    plot([-1,1],[0,0],'k');
    plot([0,0],[-1,1],'k');
    edit_label1 = uicontrol(d, ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',[.35 .75 .3 .075], ...
        'String',settings.label1, ...
        'FontSize',12);
    edit_label2 = uicontrol(d, ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',[.175 .65 .3 .075], ...
        'String',settings.label2, ...
        'FontSize',12);
    edit_label3 = uicontrol(d, ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',[.525 .65 .3 .075], ...
        'String',settings.label3, ...
        'FontSize',12);
    edit_label4 = uicontrol(d, ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',[.125 .515 .3 .075], ...
        'String',settings.label4, ...
        'FontSize',12);
    edit_label5 = uicontrol(d, ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',[.575 .515 .3 .075], ...
        'String',settings.label5, ...
        'FontSize',12);
    edit_label6 = uicontrol(d, ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',[.175 .45 .3 .075], ...
        'String',settings.label6, ...
        'FontSize',12);
    edit_label7 = uicontrol(d, ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',[.525 .45 .3 .075], ...
        'String',settings.label7, ...
        'FontSize',12);
    edit_label8 = uicontrol(d, ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',[.35 .275 .3 .075], ...
        'String',settings.label8, ...
        'FontSize',12);
    align([edit_label8,edit_label7,edit_label5],'none','distribute');
    align([edit_label5,edit_label3,edit_label1],'none','distribute');
    align([edit_label8,edit_label6,edit_label4],'none','distribute');
    align([edit_label4,edit_label2,edit_label1],'none','distribute');
    uicontrol(d, ...
        'Style','text', ...
        'Units','normalized', ...
        'Position',[.10 .135 .10 .075], ...
        'HorizontalAlignment','Left', ...
        'FontSize',12, ...
        'String','X-Axis');
    edit_labelX = uicontrol(d, ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',[.20 .15 .29 .075], ...
        'String',settings.labelX, ...
        'FontSize',12);
    edit_labelY = uicontrol(d, ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',[.51 .15 .29 .075], ...
        'String',settings.labelY, ...
        'FontSize',12);
    uicontrol(d, ...
        'Style','text', ...
        'Units','normalized', ...
        'Position',[.80 .135 .10 .075], ...
        'HorizontalAlignment','Right', ...
        'FontSize',12, ...
        'String','Y-Axis');
    uicontrol(d, ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[.10 .05 .35 .075], ...
        'String','Save as Default', ...
        'FontSize',12, ...
        'Callback',@push_save_Callback);
    uicontrol(d, ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[.55 .05 .35 .075], ...
        'String','Apply this Session', ...
        'FontSize',12, ...
        'Callback',@push_apply_Callback);
    uiwait(d);
    set(handles.l1,'String',settings.label1);
    set(handles.l2,'String',settings.label2);
    set(handles.l3,'String',settings.label3);
    set(handles.l4,'String',settings.label4);
    set(handles.l5,'String',settings.label5);
    set(handles.l6,'String',settings.label6);
    set(handles.l7,'String',settings.label7);
    set(handles.l8,'String',settings.label8);
    handles.settings = settings;
    start(handles.timer);
    guidata(handles.figure_collect,handles);
    function push_interpersonal_Callback(~,~)
        set(edit_labelX,'string','Communion');
        set(edit_labelY,'string','Agency');
        set(edit_label1,'string','Dominant');
        set(edit_label2,'string','Disagreeable');
        set(edit_label3,'string','Extraverted');
        set(edit_label4,'string','Separate');
        set(edit_label5,'string','Friendly');
        set(edit_label6,'string','Introverted');
        set(edit_label7,'string','Agreeable');
        set(edit_label8,'string','Submissive');
    end
    function push_affective_Callback(~,~)
        set(edit_labelX,'string','Valence');
        set(edit_labelY,'string','Arousal');
        set(edit_label1,'string','Activated');
        set(edit_label2,'string','Stressed');
        set(edit_label3,'string','Excited');
        set(edit_label4,'string','Unpleasant');
        set(edit_label5,'string','Pleasant');
        set(edit_label6,'string','Depressed');
        set(edit_label7,'string','Relaxed');
        set(edit_label8,'string','Deactivated');
    end
    function push_clear_Callback(~,~)
        set(edit_labelX,'string','');
        set(edit_labelY,'string','');
        set(edit_label1,'string','');
        set(edit_label2,'string','');
        set(edit_label3,'string','');
        set(edit_label4,'string','');
        set(edit_label5,'string','');
        set(edit_label6,'string','');
        set(edit_label7,'string','');
        set(edit_label8,'string','');
    end
    function push_save_Callback(~,~)
        settings.labelX = get(edit_labelX,'string');
        settings.labelY = get(edit_labelY,'string');
        settings.label1 = get(edit_label1,'string');
        settings.label2 = get(edit_label2,'string');
        settings.label3 = get(edit_label3,'string');
        settings.label4 = get(edit_label4,'string');
        settings.label5 = get(edit_label5,'string');
        settings.label6 = get(edit_label6,'string');
        settings.label7 = get(edit_label7,'string');
        settings.label8 = get(edit_label8,'string');
        if isdeployed
            save(fullfile(ctfroot,'DARMA','default.mat'),'settings');
        else
            save('default.mat','settings');
        end
        delete(d);
        msgbox(sprintf('Saved the current settings as the default settings.\nNext time DARMA is opened, these settings will be used.'));
    end
    function push_apply_Callback(~,~)
        settings.labelX = get(edit_labelX,'string');
        settings.labelY = get(edit_labelY,'string');
        settings.label1 = get(edit_label1,'string');
        settings.label2 = get(edit_label2,'string');
        settings.label3 = get(edit_label3,'string');
        settings.label4 = get(edit_label4,'string');
        settings.label5 = get(edit_label5,'string');
        settings.label6 = get(edit_label6,'string');
        settings.label7 = get(edit_label7,'string');
        settings.label8 = get(edit_label8,'string');
        delete(d);
        msgbox(sprintf('Applied the current settings for the current session.\nNext time DARMA is opened, these settings will be lost.'));
    end
end

% ===============================================================================

function menu_magnitude_Callback(hObject,~)
    handles = guidata(hObject);
    settings = handles.settings;
    d = dialog('Position',[0 0 500 200],'Name','Set Axis Magnitude','Visible','off');
    movegui(d,'center');
    set(d,'Visible','on');
    uicontrol(d, ...
        'Style','text', ...
        'Units','Normalized', ...
        'Position',[.10 .50 .80 .40], ...
        'String','The Axis Magnitude determines the bipolar scaling of the output values. For instance, setting the magnitude to 100 will produce raing values ranging from -100 to 100. Select an axis magnitude below:');
    popup_mag = uicontrol(d, ...
        'Style','popup', ...
        'Units','Normalized', ...
        'Position',[.10 .35 .80 .20], ...
        'String',{'1','10','100','1000'}, ...
        'Value',settings.magval);
    uicontrol(d, ...
        'Style','pushbutton', ...
        'Units','Normalized', ...
        'Position',[.10 .10 .30 .20], ...
        'String','Save as Default', ...
        'Callback',@push_save_Callback);
    uicontrol(d, ...
        'Style','pushbutton', ...
        'Units','Normalized', ...
        'Position',[.60 .10 .30 .20], ...
        'String','Apply Magnitude', ...
        'Callback',@push_apply_Callback);
    stop(handles.timer);
    uiwait(d);
    start(handles.timer);
    handles.settings = settings;
    guidata(handles.figure_collect,handles);
    function push_save_Callback(~,~)
        magval = popup_mag.Value;
        magnum = popup_mag.String{magval};
        magnum = str2double(magnum);
        settings.magval = magval;
        settings.magnum = magnum;
        if isdeployed
            save(fullfile(ctfroot,'DARMA','default.mat'),'settings');
        else
            save('default.mat','settings');
        end
        delete(d);
        msgbox(sprintf('Saved the current settings as the default settings.\nNext time DARMA is opened, these settings will be used.'));
    end
    function push_apply_Callback(~,~)
        magval = popup_mag.Value;
        magnum = popup_mag.String{magval};
        magnum = str2double(magnum);
        settings.magval = magval;
        settings.magnum = magnum;
        delete(d);
        msgbox(sprintf('Applied the current settings for the current session.\nNext time DARMA is opened, these settings will be lost.'));
    end
end

% ===============================================================================

function menu_binsize_Callback(hObject,~)
    handles = guidata(hObject);
    settings = handles.settings;
    d = dialog('Position',[0 0 500 200],'Name','Set Bin Size','Visible','off');
    movegui(d,'center');
    set(d,'Visible','on');
    uicontrol(d, ...
        'Style','text', ...
        'Units','Normalized', ...
        'Position',[.10 .50 .80 .40], ...
        'String','DARMA samples the joystick at 20 Hz. Samples are then averaged into temporal bins which are output in an annotation file. Bin size determines how long each bin is and thus how many samples contribute to it. Select a bin size below:');
    popup_bin = uicontrol(d, ...
        'Style','popup', ...
        'Units','Normalized', ...
        'Position',[.10 .35 .80 .20], ...
        'String',{'0.25 sec (each bin averages 5 samples)','0.50 sec (each bin averages 10 samples)','1.00 sec (each bin averages 20 samples)','2.00 sec (each bin averages 40 samples)','4.00 sec (each bin averages 80 samples)'}, ...
        'Value',settings.binsizeval);
    uicontrol(d, ...
        'Style','pushbutton', ...
        'Units','Normalized', ...
        'Position',[.10 .10 .30 .20], ...
        'String','Save as Default', ...
        'Callback',@push_save_Callback);
    uicontrol(d, ...
        'Style','pushbutton', ...
        'Units','Normalized', ...
        'Position',[.60 .10 .30 .20], ...
        'String','Apply this Session', ...
        'Callback',@push_apply_Callback);
    stop(handles.timer);
    uiwait(d);
    handles.settings = settings;
    guidata(handles.figure_collect,handles);
    start(handles.timer);
    function push_save_Callback(~,~)
        binsizeval = popup_bin.Value;
        binsizenum = popup_bin.String{binsizeval};
        binsizenum = str2double(binsizenum(1,1:4));
        settings.binsizeval = binsizeval;
        settings.binsizenum = binsizenum;
        if isdeployed
            save(fullfile(ctfroot,'DARMA','default.mat'),'settings');
        else
            save('default.mat','settings');
        end
        delete(d);
        msgbox(sprintf('Saved the current settings as the default settings.\nNext time DARMA is opened, these settings will be used.'));
    end
    function push_apply_Callback(~,~)
        binsizeval = popup_bin.Value;
        binsizenum = popup_bin.String{binsizeval};
        binsizenum = str2double(binsizenum(1,1:4));
        settings.binsizeval = binsizeval;
        settings.binsizenum = binsizenum;
        delete(d);
        msgbox(sprintf('Applied the current settings for the current session.\nNext time DARMA is opened, these settings will be lost.'));
    end
end

% ===============================================================================

function menu_defaultdir_Callback(hObject,~)
    handles = guidata(hObject);
    settings = handles.settings;
    path = uigetdir(settings.defaultdir,'Select a new default folder:');
    if isequal(path,0), return; end
    settings.defaultdir = path;
    if isdeployed
        save(fullfile(ctfroot,'DARMA','default.mat'),'settings');
    else
        save('default.mat','settings');
    end
    handles.settings = settings;
    guidata(handles.figure_collect,handles);
end

% ===============================================================================

function menu_about_Callback(~,~)
    global version;
    msgbox(sprintf('DARMA version %.2f\nJeffrey M Girard (c) 2014-2016\nhttp://darma.codeplex.com\nGNU General Public License v3',version),'About','Help');
end

% ===============================================================================

function menu_document_Callback(~,~)
    web('http://darma.codeplex.com/documentation','-browser');
end

% ===============================================================================

function menu_report_Callback(~,~)
    web('http://darma.codeplex.com/discussions','-browser');
end

% =========================================================

function figure_collect_KeyPress(hObject,eventdata)
    handles = guidata(hObject);
    global recording;
    % Escape if the playpause button is disabled
    if strcmp(get(handles.toggle_playpause,'Enable'),'off'), return; end
    % Pause playback if the pressed key is spacebar
    if strcmp(eventdata.Key,'space') && get(handles.toggle_playpause,'Value')
        handles.vlc.playlist.togglePause();
        recording = 0;
        set(handles.toggle_playpause,'String','Resume Rating','Value',0);
    else
        return;
    end
    guidata(hObject,handles);
end

% =========================================================

function toggle_playpause_Callback(hObject,~)
    handles = guidata(hObject);
    global recording;
    if get(hObject,'Value')
        % If toggle button is set to play, update GUI elements
        set(hObject,'Enable','off','String','...');
        set(handles.menu_media,'Enable','off');
        set(handles.menu_settings,'Enable','off');
        set(handles.menu_help,'Enable','off');
        % Start three second countdown before starting
        set(hObject,'String','...3...'); pause(1);
        set(hObject,'String','..2..'); pause(1);
        set(hObject,'String','.1.'); pause(1);
        set(hObject,'Enable','On','String','Pause Rating');
        recording = 1;
        guidata(hObject,handles);
        % Send play() command to VLC and wait for it to start playing
        handles.vlc.playlist.play();
    else
        % If toggle button is set to pause, send pause() command to VLC
        handles.vlc.playlist.togglePause();
        recording = 0;
        set(hObject,'String','Resume Rating','Value',0);
        set(handles.menu_help,'Enable','on');
        guidata(hObject,handles);
    end
end

% =========================================================

function timer_Callback(~,~,handles)
    handles = guidata(handles.figure_collect);
    global ratings last_ts_vlc last_ts_sys global_tic marker recording;
    % Before playing
    if recording == 0
        [a,b,~] = read(handles.joy);
        x = a(1); y = a(2)*-1;
        if b(1)==0, color = 'w'; else color = 'y'; end
        set(marker,'XData',x,'YData',y,'MarkerFace',color);
        return;
    end
    % While playing
    if handles.vlc.input.state == 3
        try
            % Read status of the joystick
            [a,b,~] = read(handles.joy);
        catch
            %If failed, recreate the joystick
            handles.joy = vrjoystick(1);
            guidata(handles.figure_collect,handles);
            return;
        end
        ts_vlc = handles.vlc.input.time/1000;
        ts_sys = toc(global_tic);
        if ts_vlc == last_ts_vlc && last_ts_vlc ~= 0
            ts_diff = ts_sys - last_ts_sys;
            ts_vlc = ts_vlc + ts_diff;
        else
            last_ts_vlc = ts_vlc;
            last_ts_sys = ts_sys;
        end
        x = a(1); y = a(2)*-1;
        if b(1)==0, color = 'r'; else color = 'g'; end
        set(marker,'XData',x,'YData',y,'MarkerFace',color);
        ratings = [ratings; ts_vlc,x*handles.settings.magnum,y*handles.settings.magnum,b(1)];
        set(handles.text_timestamp,'String',datestr(handles.vlc.input.time/1000/24/3600,'HH:MM:SS'));
        frac = (ts_vlc / handles.dur) * 100;
        set(handles.timebar,'Position',[0 0 frac 1]);
        drawnow();
        guidata(handles.figure_collect,handles);
    % After playing
    elseif handles.vlc.input.state == 5 || handles.vlc.input.state == 6
        recording = 0;
        handles.vlc.playlist.stop();
        set(handles.toggle_playpause,'Value',0);
        % Average ratings per second of playback
        rating = ratings;
        disp(rating);
        anchors = [0,(handles.settings.binsizenum:handles.settings.binsizenum:floor(handles.dur))];
        mean_ratings = nan(length(anchors)-1,4);
        mean_ratings(:,1) = anchors(2:end)';
        for i = 1:length(anchors)-1
            s_start = anchors(i);
            s_end = anchors(i+1);
            index = (rating(:,1) >= s_start) & (rating(:,1) < s_end);
            bin = rating(index,2:end);
            if isempty(bin), continue; end
            mean_ratings(i,:) = [s_end,nanmean(bin(:,1)),nanmean(bin(:,2)),nanmax(bin(:,3))];
        end
        disp(mean_ratings);
        % Prompt user to save the collected annotations
        [~,defaultname,ext] = fileparts(handles.MRL);
        [filename,pathname] = uiputfile({'*.csv','Comma-Separated Values (*.csv)'},'Save as',fullfile(handles.settings.defaultdir,defaultname));
        if ~isequal(filename,0) && ~isequal(pathname,0)
            % Add metadata to mean ratings and timestamps
            output = [ ...
                {'Time of Rating'},{datestr(now)},{''},{''}; ...
                {'Multimedia File'},{sprintf('%s%s',defaultname,ext)},{''},{''}; ...
                {'Magnitude'},{handles.settings.magnum},{''},{''}; ...
                {'Second'},{handles.settings.labelX},{handles.settings.labelY},{'Button'}; ...
                {'%%%%%%'},{'%%%%%%'},{'%%%%%%'},{'%%%%%%'}; ...
                num2cell(mean_ratings)];
            % Create export file depending on selected file type
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
        program_reset(handles);
    % While transitioning or paused
    else
        return;
    end
end

% =========================================================

function timer_ErrorFcn(hObject,event,~)
    disp(event.Data);
    handles = guidata(hObject);
    global ratings;
    handles.vlc.playlist.togglePause();
    stop(handles.timer);
    msgbox(sprintf('Timer callback error:\n%s\nAn error log has been saved.',event.Data.message),'Error','error');
    csvwrite(fullfile(handles.settings.folder,sprintf('%s.csv',datestr(now,30))),ratings);
    guidata(handles.figure_collect,handles);
end

% =========================================================

function create_axis(handles)
    handles = guidata(handles.figure_collect);
    settings = handles.settings;
    global marker;
    axes(handles.axis_circle);
    plot(handles.axis_circle,[-1,1],[0,0],'k-');
    plot(handles.axis_circle,[0,0],[-1,1],'k-');
    handles.l1 = text(0.0,0.9,settings.label1,'HorizontalAlignment','center','BackgroundColor',[1 1 1],'FontSize',12,'Margin',5);
    handles.l2 = text(-0.64,0.64,settings.label2,'HorizontalAlignment','center','BackgroundColor',[1 1 1],'FontSize',12,'Margin',5);
    handles.l3 = text(0.64,0.64,settings.label3,'HorizontalAlignment','center','BackgroundColor',[1 1 1],'FontSize',12,'Margin',5); 
    handles.l4 = text(-0.9,0.0,settings.label4,'HorizontalAlignment','left','BackgroundColor',[1 1 1],'FontSize',12,'Margin',5);
    handles.l5 = text(0.9,0.0,settings.label5,'HorizontalAlignment','right','BackgroundColor',[1 1 1],'FontSize',12,'Margin',5);
    handles.l6 = text(-0.64,-0.64,settings.label6,'HorizontalAlignment','center','BackgroundColor',[1 1 1],'FontSize',12,'Margin',5);
    handles.l7 = text(0.64,-0.64,settings.label7,'HorizontalAlignment','center','BackgroundColor',[1 1 1],'FontSize',12,'Margin',5);
    handles.l8 = text(0.0,-0.9,settings.label8,'HorizontalAlignment','center','BackgroundColor',[1 1 1],'FontSize',12,'Margin',5);
    marker = plot(handles.axis_circle,0,0,'ko','LineWidth',2,'MarkerSize',15,'MarkerFaceColor','white');
    guidata(handles.figure_collect,handles);
end

% =========================================================

function figure_collect_SizeChanged(hObject,~)
    handles = guidata(hObject);
    if isfield(handles,'figure_collect')
        pos = getpixelposition(handles.figure_collect);
        % Force to remain above a minimum size
        if pos(3) < 1024 || pos(4) < 600
            setpixelposition(handles.figure_collect,[pos(1) pos(2) 1024 600]);
            movegui(handles.figure_collect,'center');
            set(handles.toggle_playpause,'FontSize',12);
            set(handles.table_info,'ColumnName',[]);
        else
            set(handles.toggle_playpause,'FontSize',14);
            set(handles.table_info,'ColumnName',{'Bin Size','Axis Magnitude'});
        end
        % Update the size and position of the VLC controller
        if isfield(handles,'vlc')
            move(handles.vlc,getpixelposition(handles.axis_guide));
        end
        set(handles.table_info,'ColumnWidth',num2cell(repmat(round(pos(3)*.22 / 2 - 2),1,2)));
    end
end

% =========================================================

function program_reset(handles)
    global recording;
    handles = guidata(handles.figure_collect);
    recording = 0;
    % Update GUI elements to starting configuration
    set(handles.timebar,'Position',[0 0 0 1]);
    set(handles.text_timestamp,'String','00:00:00');
    set(handles.text_filename,'String','Media Filename');
    set(handles.text_duration,'String','00:00:00');
    set(handles.toggle_playpause,'Enable','off','String','Begin Rating');
    set(handles.menu_media,'Enable','on');
    set(handles.menu_settings,'Enable','on');
    set(handles.menu_closemedia,'Enable','off');
    set(handles.menu_preview,'Enable','off');
    set(handles.menu_help,'Enable','on');
    guidata(handles.figure_collect,handles);
end

% =========================================================

function figure_collect_CloseReq(hObject,~)
    handles = guidata(hObject);
    global recording;
    % Pause playback and rating
    if handles.vlc.input.state==3,handles.vlc.playlist.togglePause(); end
    set(handles.toggle_playpause,'String','Resume Rating','Value',0);
    recording = 0;
    guidata(handles.figure_collect,handles);
    if handles.vlc.input.state==4 || handles.vlc.input.state==3
        %If ratings are being collected, prompt user to cancel them
        choice = questdlg('Do you want to cancel your current ratings?', ...
            'DARMA','Yes','No','No');
        switch choice
            case 'Yes'
                handles.vlc.playlist.stop();
                program_reset(handles);
            case 'No'
                return;
        end
    else
        %If ratings are not being collected, exit DARMA
        if strcmp(handles.timer.Running,'on'), stop(handles.timer); end
        delete(timerfind);
        delete(handles.figure_collect);
    end
end