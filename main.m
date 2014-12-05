function main
%MAIN Code for the main DARMA window and functions
% License: https://darma.codeplex.com/license

    % Create and center main window
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    handles.figure_main = figure( ...
        'Units','normalized', ...
        'Name','DARMA: Dual Axis Rating and Media Annotation', ...
        'MenuBar','none', ...
        'ToolBar','none', ...
        'NumberTitle','off', ...
        'Visible','off', ...
        'Color',defaultBackground, ...
        'SizeChangedFcn',@figure_main_SizeChanged, ...
        'KeyPressFcn',@figure_main_KeyPress, ...
        'CloseRequestFcn',@figure_main_CloseReq);
    % Create menu bar elements
    handles.menu_multimedia = uimenu(handles.figure_main, ...
        'Parent',handles.figure_main, ...
        'Label','Open Multimedia File', ...
        'Callback',@menu_multimedia_Callback);
    handles.menu_annotation = uimenu(handles.figure_main, ...
        'Parent',handles.figure_main, ...
        'Label','Import Annotation File', ...
        'Callback',@menu_annotation_Callback, ...
        'Enable','off');
    handles.menu_settings = uimenu(handles.figure_main, ...
        'Parent',handles.figure_main, ...
        'Label','Configure Settings', ...
        'Callback',@menu_settings_Callback);
    handles.menu_about = uimenu(handles.figure_main, ...
        'Parent',handles.figure_main, ...
        'Label','About DARMA', ...
        'Callback',@menu_about_Callback);
    pause(0.1);
    set(handles.figure_main,'Position',[0.1 0.1 0.8 0.8]);
    % Create uicontrol elements
    handles.text_report = uicontrol('Style','edit', ...
        'Parent',handles.figure_main, ...
        'Units','Normalized', ...
        'Position',[.01 .02 .22 .05], ...
        'String','Open File', ...
        'FontSize',14.0, ...
        'Enable','off');
    handles.text_filename = uicontrol('Style','edit', ...
        'Parent',handles.figure_main, ...
        'Units','Normalized', ...
        'Position',[.24 .02 .40 .05], ...
        'FontSize',14.0, ...
        'Enable','off');
    handles.text_duration = uicontrol('Style','edit', ...
        'Parent',handles.figure_main, ...
        'Units','Normalized', ...
        'Position',[.65 .02 .22 .05], ...
        'FontSize',14.0, ...
        'Enable','off');
    handles.toggle_playpause = uicontrol('Style','togglebutton', ...
        'Parent',handles.figure_main, ...
        'Units','Normalized', ...
        'Position',[.88 .02 .11 .05], ...
        'String','Play', ...
        'FontSize',14.0, ...
        'Callback',@toggle_playpause_Callback, ...
        'Enable','inactive');
    handles.axis_guide = axes('Units','normalized', ...
        'Parent',handles.figure_main, ...
        'Position',[.01 .09 .63 .89], ...
        'Box','on','XTick',[],'YTick',[],'Color','black');
    handles.axis_circle = axes('Units','normalized', ...
        'Parent',handles.figure_main, ...
        'OuterPosition',[.65 .09 .34 .89], ...
        'LooseInset',[0 0 0 0], ...
        'XLim',[-1,1],'YLim',[-1,1], ...
        'NextPlot','add', ...
        'Box','on','XTick',[],'YTick',[],'Layer','top');
    axis square;
    % Check for and find VideoLAN VLC Player ActiveX Controller
    axctl = actxcontrollist;
    index = strcmp(axctl(:,2),'VideoLAN.VLCPlugin.2');
    if sum(index)==0
        choice = questdlg('DARMA requires the free, open source VLC media player. Open download page?',...
            'DARMA','Yes','No','Yes');
        switch choice
            case 'Yes'
                web('http://www.videolan.org/','-browser');
        end
        delete(handles.figure_main);
        return;
    end
    % Configure default settings
    handles.mag = 1000;
    handles.sps = 2;
    handles.label0 = 'Friendly';
    handles.label1 = 'Extraverted';
    handles.label2 = 'Dominant';
    handles.label3 = 'Disagreeable';
    handles.label4 = 'Separate';
    handles.label5 = 'Introverted';
    handles.label6 = 'Submissive';
    handles.label7 = 'Agreeable';
    % Invoke and configure VLC ActiveX Controller
    handles.vlc = actxcontrol('VideoLAN.VLCPlugin.2',getpixelposition(handles.axis_guide),handles.figure_main);
    pause(2);
    handles.vlc.AutoPlay = 0;
    handles.vlc.Toolbar = 0;
    handles.vlc.FullscreenEnabled = 0;
    try
        handles.joy = vrjoystick(1);
    catch
        e = errordlg('DARMA could not detect a joystick.','Error','modal');
        waitfor(e);
        quit force;
    end
    % Create timer
    handles.recording = 0;
    handles.timer = timer(...
        'ExecutionMode','fixedRate', ...
        'Period',0.08, ...
        'TimerFcn',{@timer_Callback,handles}, ...
        'ErrorFcn',{@timer_ErrorFcn,handles});
    % Save handles to guidata
    handles.figure_main.Visible = 'on';
    guidata(handles.figure_main,handles);
    create_axis(handles);
end

% =========================================================

function figure_main_KeyPress(hObject,eventdata)
    handles = guidata(hObject);
    % Escape if the playpause button is disabled
    if strcmp(get(handles.toggle_playpause,'enable'),'inactive'), return; end
    % Pause playback if the pressed key is spacebar
    if strcmp(eventdata.Key,'space') && get(handles.toggle_playpause,'value')
        handles.vlc.playlist.togglePause();
        stop(handles.timer);
        set(handles.toggle_playpause,'String','Resume','Value',0);
    else
        return;
    end
    guidata(hObject,handles);
end

% =========================================================

function toggle_playpause_Callback(hObject,~)
    handles = guidata(hObject);
    if get(hObject,'Value')
        % If toggle button is set to play, update GUI elements
        start(handles.timer);
        set(hObject,'Enable','Off','String','...');
        set(handles.menu_multimedia,'Enable','off');
        set(handles.menu_annotation,'Enable','off');
        set(handles.menu_settings,'Enable','off');
        set(handles.menu_about,'Enable','off');
        % Clear axis_circle
        create_axis(handles);
        % Start three second countdown before starting
        set(handles.text_report,'String','...3...'); pause(1);
        set(handles.text_report,'String','..2..'); pause(1);
        set(handles.text_report,'String','.1.'); pause(1);
        set(hObject,'Enable','On','String','Pause');
        handles.recording = 1;
        guidata(hObject,handles);
        % Send play() command to VLC and wait for it to start playing
        handles.vlc.playlist.play();
    else
        % If toggle button is set to pause, send pause() command to VLC
        handles.vlc.playlist.togglePause();
        stop(handles.timer);
        handles.recording = 0;
        set(hObject,'String','Resume','Value',0);
        guidata(hObject,handles);
    end
end

% =========================================================

function program_reset(handles)
    handles = guidata(handles.figure_main);
    handles.recording = 0;
    handles.vlc.playlist.items.clear();
    % Update GUI elements to starting configuration
    set(handles.text_report,'String','Open File');
    set(handles.text_filename,'String','');
    set(handles.text_duration,'String','');
    set(handles.toggle_playpause,'Enable','off','String','Play');
    set(handles.menu_multimedia,'Enable','on');
    set(handles.menu_annotation,'Enable','off');
    set(handles.menu_settings,'Enable','on');
    set(handles.menu_about,'Enable','on');
    guidata(handles.figure_main,handles);
    create_axis(handles);
end

% =========================================================

function timer_Callback(~,~,handles)
    handles = guidata(handles.figure_main);
    % Before playing
    if handles.recording==0
        try
            [a,b,~] = read(handles.joy);
        catch
            handles.joy = vrjoystick(1);
            guidata(handles.figure_main,handles);
            return;
        end
        x = a(1); y = a(2)*-1;
        create_axis(handles);
        if b(1)==0, color = 'w'; else color = 'y'; end
        plot(handles.axis_circle,x,y,'ko','LineWidth',2,'MarkerSize',15,'MarkerFace',color);
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
            guidata(handles.figure_main,handles);
            return;
        end
        t = handles.vlc.input.time / 1000;
        x = a(1); y = a(2)*-1;
        create_axis(handles);
        if b(1)==0, color = 'r'; else color = 'g'; end
        plot(handles.axis_circle,x,y,'ko','LineWidth',2,'MarkerSize',15,'MarkerFace',color);
        handles.rating = [handles.rating; t,x*handles.mag,y*handles.mag,b(1)];
        set(handles.text_report,'string',datestr(handles.vlc.input.time/1000/24/3600,'HH:MM:SS'));
        drawnow();
        guidata(handles.figure_main,handles);
    % After playing
    elseif handles.vlc.input.state == 5 || handles.vlc.input.state == 6
        stop(handles.timer);
        handles.recording = 0;
        handles.vlc.playlist.stop();
        set(handles.toggle_playpause,'Value',0);
        create_axis(handles);
        set(handles.text_report,'string','Processing...');
        % Average ratings per second of playback
        rating = handles.rating;
        mean_ratings = [];
        anchors = [0,(1/handles.sps:1/handles.sps:handles.dur)];
        for i = 1:length(anchors)-1
            s_start = anchors(i);
            s_end = anchors(i+1);
            index = (rating(:,1) >= s_start) & (rating(:,1) < s_end);
            bin = rating(index,2:end);
            mean_ratings = [mean_ratings;s_end,mean(bin(:,1:2)),max(bin(:,3))];
        end
        % Prompt user to save the collected annotations
        [~,defaultname,ext] = fileparts(handles.MRL);
        [filename,pathname] = uiputfile({'*.xlsx','Excel 2007 Spreadsheet (*.xlsx)';...
            '*.xls','Excel 2003 Spreadsheet (*.xls)';...
            '*.csv','Comma-Separated Values (*.csv)'},'Save as',defaultname);
        if ~isequal(filename,0) && ~isequal(pathname,0)
            % Add metadata to mean ratings and timestamps
            output = [ ...
                {'Time of Rating'},{datestr(now)},{''},{''}; ...
                {'Multimedia File'},{sprintf('%s%s',defaultname,ext)},{''},{''}; ...
                {'Magnitude'},{handles.mag},{''},{''}; ...
                {'Second'},{'X'},{'Y'},{'B'}; ...
                {'%%%%%%'},{'%%%%%%'},{'%%%%%%'},{'%%%%%%'}; ...
                num2cell(mean_ratings)];
            % Create export file depending on selected file type
            [~,~,ext] = fileparts(filename);
            if strcmpi(ext,'.XLS') || strcmpi(ext,'.XLSX')
                % Create XLS/XLSX file if that is the selected file type
                [success,message] = xlswrite(fullfile(pathname,filename),output);
                if strcmp(message.identifier,'MATLAB:xlswrite:dlmwrite')
                    % If Excel is not installed, create CSV file instead
                    serror = errordlg('Exporting to .XLS/.XLSX requires Microsoft Excel to be installed. CARMA will now export to .CSV instead.');
                    uiwait(serror);
                    success = cell2csv(fullfile(pathname,filename),output);
                end
            elseif strcmpi(ext,'.CSV')
                % Create CSV file if that is the selected file type
                success = cell2csv(fullfile(pathname,filename),output);
            end
            % Report saving success or failure
            if success
                h = msgbox('Export successful.');
                waitfor(h);
            else
                h = msgbox('Export error.');
                waitfor(h);
            end
        else
            filename = 'Unsaved';
        end
        % Open the collected annotations for viewing and exporting
        program_reset(handles);
        % Ask user to open annotation viewer
        choice = questdlg('Open ratings in annotations viewer?', ...
            'DARMA','Yes','No','Yes');
        switch choice
            case 'Yes'
                annotations('MRL',handles.MRL,'Ratings',mean_ratings,'Duration',handles.dur,'Magnitude',handles.mag,'Filename',filename);
            case 'No'
                return;
        end
    % While transitioning or paused
    else
        return;
    end
end

% =========================================================

function timer_ErrorFcn(~,~,handles)
    handles = guidata(handles.figure_main);
    handles.vlc.playlist.togglePause();
    stop(handles.timer);
    msgbox('Timer callback error.','Error','error');
    disp(handles.rating);
    guidata(handles.figure_main,handles);
end

% =========================================================

function create_axis(handles)
    handles = guidata(handles.figure_main);
    axes(handles.axis_circle); cla;
    plot(handles.axis_circle,[-1,1],[0,0],'k-');
    plot(handles.axis_circle,[0,0],[-1,1],'k-');
    text(0.9,0.0,handles.label0,'HorizontalAlignment','right','VerticalAlignment','middle','BackgroundColor',[1 1 1],'FontSize',12,'Margin',5);
    text(0.64,0.64,handles.label1,'HorizontalAlignment','center','VerticalAlignment','middle','BackgroundColor',[1 1 1],'FontSize',12,'Margin',5);
    text(0.0,0.9,handles.label2,'HorizontalAlignment','center','VerticalAlignment','middle','BackgroundColor',[1 1 1],'FontSize',12,'Margin',5);
    text(-0.64,0.64,handles.label3,'HorizontalAlignment','center','VerticalAlignment','middle','BackgroundColor',[1 1 1],'FontSize',12,'Margin',5);
    text(-0.9,0.0,handles.label4,'HorizontalAlignment','left','VerticalAlignment','middle','BackgroundColor',[1 1 1],'FontSize',12,'Margin',5);
    text(-0.64,-0.64,handles.label5,'HorizontalAlignment','center','VerticalAlignment','middle','BackgroundColor',[1 1 1],'FontSize',12,'Margin',5);
    text(0.0,-0.9,handles.label6,'HorizontalAlignment','center','VerticalAlignment','middle','BackgroundColor',[1 1 1],'FontSize',12,'Margin',5);
    text(0.64,-0.64,handles.label7,'HorizontalAlignment','center','VerticalAlignment','middle','BackgroundColor',[1 1 1],'FontSize',12,'Margin',5);
    guidata(handles.figure_main,handles);
end

% =========================================================

function figure_main_SizeChanged(hObject,~)
    handles = guidata(hObject);
    if isfield(handles,'figure_main')
        pos = getpixelposition(handles.figure_main);
        % Force to remain above a minimum size
        if pos(3) < 1024 || pos(4) < 600
            setpixelposition(handles.figure_main,[pos(1) pos(2) 1024 600]);
            movegui(handles.figure_main,'center');
        end
        % Update the size and position of the VLC controller
        if isfield(handles,'vlc')
            move(handles.vlc,getpixelposition(handles.axis_guide));
        end
    end
end

% =========================================================

function figure_main_CloseReq(hObject,~)
    handles = guidata(hObject);
    % Pause playback and rating
    if handles.vlc.input.state==3,handles.vlc.playlist.togglePause(); end
    if strcmp(handles.timer.Running,'on'), stop(handles.timer); end
    set(handles.toggle_playpause,'String','Resume','Value',0);
    handles.recording = 0;
    guidata(handles.figure_main,handles);
    pause(.1); 
    if handles.vlc.input.state==4
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
        choice = questdlg('Do you want to exit DARMA?', ...
            'DARMA','Yes','No','No');
        switch choice
            case 'Yes'
                delete(handles.timer);
                delete(gcf);
            case 'No'
                return;
        end
    end
end

% =========================================================

function menu_multimedia_Callback(hObject,~)
    handles = guidata(hObject);
    % Reset the GUI elements
    program_reset(handles);
    % Browse for, load, and get text_duration for a multimedia file
    [video_name,video_path] = uigetfile({'*.*','All Files (*.*)'},'Select an audio or video file');
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
    catch err
        msgbox(err.message,'Error loading multimedia file.'); return;
    end
    % Update GUI elements
    set(handles.menu_annotation,'Enable','On');
    set(handles.text_report,'String','Press Play');
    set(handles.text_filename,'String',video_name);
    set(handles.text_duration,'String',datestr(handles.dur/24/3600,'HH:MM:SS'));
    set(handles.toggle_playpause,'Enable','On');
    handles.rating = [];
    guidata(hObject,handles);
end

% =========================================================

function menu_annotation_Callback(hObject,~)
    handles = guidata(hObject);
    [filename,pathname] = uigetfile({'*.xls; *.xlsx; *.csv','CARMA Export Formats (*.xls, *.xlsx, *.csv)'},'Open Annotations');
    if filename==0, return; end
    %TODO: replace with CSV read if CSV import file
    [~,~,data] = xlsread(fullfile(pathname,filename));
    % Browse for an annotation file
    Ratings = cell2mat(data(6:end,:));
    Magnitude = cell2mat(data(3,2));
    % Execute the annotations() function
    annotations('MRL',handles.MRL,'Ratings',Ratings,'Duration',handles.dur,'Magnitude',Magnitude,'Filename',filename);
end

% =========================================================

function menu_settings_Callback(hObject,~)
    handles = guidata(hObject);
    prompt = {'Magnitude','Samples per second','Label 0:','Label 1:','Label 2:','Label 3:','Label 4:','Label 5:','Label 6:','Label 7:'};
    dlg_title = 'DARMA Settings';
    num_lines = 1;
    def = {num2str(handles.mag),num2str(handles.sps),handles.label0,handles.label1,handles.label2,handles.label3,handles.label4,handles.label5,handles.label6,handles.label7};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    if isempty(answer), return; end
    handles.mag = str2double(answer{1});
    handles.sps = str2double(answer{2});
    handles.label0 = answer{3};
    handles.label1 = answer{4};
    handles.label2 = answer{5};
    handles.label3 = answer{6};
    handles.label4 = answer{7};
    handles.label5 = answer{8};
    handles.label6 = answer{9};
    handles.label7 = answer{10};
    guidata(handles.figure_main,handles);
    create_axis(handles);
end

% =========================================================

function menu_about_Callback(~,~)
    % Display information menu_about CARMA
    line1 = 'Dual Axis Rating and Media Annotation';
    line2 = 'Version 2.00 <DEC 05 2014>';
    line3 = 'Manual: http://darma.codeplex.com/documentation';
    line4 = 'Support: http://darma.codeplex.com/discussion';
    line5 = 'License: http://darma.codeplex.com/license';
    msgbox(sprintf('%s\n%s\n%s\n%s\n%s',line1,line2,line3,line4,line5),'About DARMA','help');
end
