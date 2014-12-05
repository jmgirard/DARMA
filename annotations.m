function status = annotations(varargin)
%ANNOTATIONS Code for the Annotations window and functions
% License: https://darma.codeplex.com/license

    % Create and maximize annotation window
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    handles.figure_annotations = figure( ...
        'Units','normalized', ...
        'Position',[0.1 0.1 0.8 0.8], ...
        'Name','DARMA: Annotation Viewer', ...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'ToolBar','none', ...
        'Visible','off', ...
        'Color',defaultBackground, ...
        'SizeChangedFcn',@figure_annotations_SizeChanged, ...
        'CloseRequestFcn',@figure_annotations_CloseRequest);
    %Create menu bar elements
    handles.menu_addseries = uimenu(handles.figure_annotations, ...
        'Parent',handles.figure_annotations, ...
        'Label','Add Annotation File', ...
        'Callback',@button_addseries_Callback);
    handles.menu_delseries = uimenu(handles.figure_annotations, ...
        'Parent',handles.figure_annotations, ...
        'Label','Remove Annotation File', ...
        'Callback',@button_delseries_Callback);
    handles.menu_export = uimenu(handles.figure_annotations, ...
        'Parent',handles.figure_annotations, ...
        'Label','Export Mean Ratings', ...
        'Callback',@menu_export_Callback);
    pause(0.1);
    %Create uicontrol elements
    lc = .01; rc = .89;
    handles.axis_X = axes('Units','Normalized', ...
        'Parent',handles.figure_annotations, ...
        'TickLength',[0.05 0], ...
        'OuterPosition',[0 0 1 1], ...
        'Position',[lc+.01 .24 .86 .16], ...
        'ButtonDownFcn',{@axis_click_Callback,'X'});
    handles.axis_Y = axes('Units','Normalized', ...
        'Parent',handles.figure_annotations, ...
        'TickLength',[0.05 0], ...
        'OuterPosition',[0 0 1 1], ...
        'Position',[lc+.01 .04 .86 .16], ...
        'ButtonDownFcn',{@axis_click_Callback,'Y'});
    handles.listbox = uicontrol('Style','listbox', ...
        'Parent',handles.figure_annotations, ...
        'Units','normalized', ...
        'FontSize',10, ...
        'Position',[rc .485 .10 .50]);
    handles.button_addseries = uicontrol('Style','pushbutton', ...
        'Parent',handles.figure_annotations, ...
        'Units','normalized', ...
        'Position',[rc .445 3/100 3/100], ...
        'String','+', ...
        'FontSize',16, ...
        'TooltipString','Add Annotation File', ...
        'Callback',@button_addseries_Callback);
    handles.button_delseries = uicontrol('Style','pushbutton', ...
        'Parent',handles.figure_annotations, ...
        'Units','normalized', ...
        'Position',[rc+.005+3/100 .445 3/100 3/100], ...
        'String','–', ...
        'FontSize',16, ...
        'TooltipString','Remove Annotation File', ...
        'Callback',@button_delseries_Callback);
    handles.toggle_meanplot = uicontrol('Style','togglebutton', ...
        'Parent',handles.figure_annotations, ...
        'Units','normalized', ...
        'Position',[rc+.01+6/100 .445 3/100 3/100], ...
        'String','m', ...
        'FontSize',14, ...
        'TooltipString','Toggle Mean Plot', ...
        'Enable','off', ...
        'Callback',@toggle_meanplot_Callback);
    pos = getpixelposition(handles.figure_annotations);
    handles.reliability = uitable(...
        'Parent',handles.figure_annotations, ...
        'Units','normalized', ...
        'Position',[rc .14 .10 .29], ...
        'ColumnWidth',{pos(3)*.099*.65,pos(3)*.099*.25}, ...
        'ColumnName',[], ...
        'RowName',[], ...
        'Data',[], ...
        'FontSize',10);
    handles.axis_guide = axes('Units','normalized', ...
        'Parent',handles.figure_annotations, ...
        'Position',[lc*2 .42 .50 .565], ...
        'Box','on','XTick',[],'YTick',[],'Color','black');
    handles.axis_C = axes('Units','normalized', ...
        'Parent',handles.figure_annotations, ...
        'OuterPosition',[.53 .42 .35 .565], ...
        'XTick',[],'YTick',[],'Box','on', ...
        'YTick',0,'YTickLabel',[],'YGrid','on', ...
        'XTick',0,'XTickLabel',[],'XGrid','on', ...
        'NextPlot','add', ...
        'LooseInset',[0 0 0 0]);
    handles.toggle_playpause = uicontrol('Style','togglebutton', ...
        'Parent',handles.figure_annotations, ...
        'Units','Normalized', ...
        'Position',[rc .02 .10 .10], ...
        'String','Play', ...
        'FontSize',16.0, ...
        'Callback',@toggle_playpause_Callback);
    % Check for and find Window Media Player (WMP) ActiveX Controller
    axctl = actxcontrollist;
    index = strcmp(axctl(:,2),'VideoLAN.VLCPlugin.2');
    if sum(index)==0,errordlg('Please install VideoLAN VLC Media Player'); quit force; end
    % Invoke and configure WMP ActiveX Controller
    handles.vlc = actxcontrol('VideoLAN.VLCPlugin.2',getpixelposition(handles.axis_guide),handles.figure_annotations);
    pause(2);
    handles.vlc.AutoPlay = 0;
    handles.vlc.Toolbar = 0;
    handles.vlc.FullscreenEnabled = 0;
    % Read data passed to function
    handles.Ratings = varargin{find(strcmp(varargin,'Ratings'))+1};
    handles.Seconds = handles.Ratings(:,1);
    handles.AllRatingsX = handles.Ratings(:,2);
    handles.AllRatingsY = handles.Ratings(:,3);
    handles.MRL = varargin{find(strcmp(varargin,'MRL'))+1};
    handles.dur = varargin{find(strcmp(varargin,'Duration'))+1};
    handles.mag = varargin{find(strcmp(varargin,'Magnitude'))+1};
    filename = varargin{find(strcmp(varargin,'Filename'))+1};
    [~,handles.filename,~] = fileparts(filename);
    handles.AllFilenames = {handles.filename};
    handles.vlc.playlist.add(handles.MRL);
    handles.vlc.playlist.play();
    while handles.vlc.input.state ~= 3
        pause(0.001);
    end
    handles.vlc.playlist.togglePause();
    handles.vlc.input.time = 0;
    % Populate list box
    set(handles.listbox,'String',{'<html><u>Annotation Files';sprintf('<html><font color="%s">[01]</font> %s',rgbconv([0 0.4470 0.7410]),handles.filename)});
    % Populate reliability box
    box = reliability(handles.AllRatingsX,handles.AllRatingsY);
    set(handles.reliability,'Data',box);
    % Create timer
	handles.timer2 = timer(...
        'ExecutionMode','fixedRate', ...
        'Period',0.20, ...
        'TimerFcn',{@timer2_Callback,handles});
    % Save handles to guidata
    guidata(handles.figure_annotations,handles);
    set(handles.axis_C,'XLim',[-1*handles.mag,handles.mag],'YLim',[-1*handles.mag,handles.mag]);
    axes(handles.axis_C);
    for i = 1:size(handles.AllRatingsX,1)
        %Plot semi-transparent circle
        THETA = linspace(0,2*pi,10);
        RHO = ones(1,10)*handles.mag/15;
        [X,Y] = pol2cart(THETA,RHO);
        X = X+handles.AllRatingsX(i);
        Y = Y+handles.AllRatingsY(i);
        h = fill(X,Y,[0 0.4470 0.7410]);
        axis square;
        set(h,'FaceAlpha',10/size(handles.AllRatingsX,1),'EdgeColor','none');
    end
    update_plots(handles);
    handles.figure_annotations.Visible = 'on';
    status = 1;
end

% ===============================================================================

function menu_export_Callback(hObject,~)
    handles = guidata(hObject);
    [~,defaultname,ext] = fileparts(handles.URL);
    output = [ ...
        {'Time of Rating'},{datestr(now)},{''},{''}; ...
        {'Multimedia File'},{sprintf('%s%s',defaultname,ext)},{''},{''}; ...
        {'Magnitude'},{handles.mag},{''},{''}; ...
        {'Second'},{'X'},{'Y'},{'B'}; ...
        {'%%%%%%'},{'%%%%%%'},{'%%%%%%'},{'%%%%%%'}; ...
        num2cell([handles.Seconds,handles.MeanRatingsX,handles.MeanRatingsY,zeros(length(handles.Seconds),1)])];
    defaultname = sprintf('%s_Mean',defaultname);
    %Prompt user for output filepath
    [filename,pathname] = uiputfile({'*.xlsx','Excel 2007 Spreadsheet (*.xlsx)';...
        '*.xls','Excel 2003 Spreadsheet (*.xls)';...
        '*.csv','Comma-Separated Values (*.csv)'},'Save as',defaultname);
    if isequal(filename,0), return; end
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
end

% ===============================================================================

function button_addseries_Callback(hObject,~)
    handles = guidata(hObject);
    % Prompt user for import file.
    [filenames,pathname] = uigetfile({'*.xls; *.xlsx; *.csv','DARMA Export Formats (*.xls, *.xlsx, *.csv)'},'Open Annotations','MultiSelect','on');
    if ~iscell(filenames)
        if filenames==0, return; end
        filenames = {filenames};
    end
    for f = 1:length(filenames)
        filename = filenames{f};
        [~,~,data] = xlsread(fullfile(pathname,filename));
        if cell2mat(data(3,2))~=handles.mag
            msgbox('Annotation file must have the same magnitude as the other annotation files.','Error','error');
            return;
        end
        % Check that the import file matches the multimedia file
        if size(handles.AllRatingsX,1) ~= size(data(6:end,:),1)
            msgbox('Annotation file must have the same sampling rate as the other annotation files.','Error','Error');
            return;
        else
            % Append the new file to the stored data
            handles.AllRatingsX = [handles.AllRatingsX,cell2mat(data(6:end,2))];
            handles.AllRatingsY = [handles.AllRatingsY,cell2mat(data(6:end,3))];
            [~,fn,~] = fileparts(filename);
            handles.AllFilenames = [handles.AllFilenames;fn];
            % Update mean series
            handles.MeanRatingsX = mean(handles.AllRatingsX,2);
            handles.MeanRatingsY = mean(handles.AllRatingsY,2);
            guidata(hObject,handles);
            update_plots(handles);
            % Update list box
            rows = {'<html><u>Annotation Files'};
            for i = 1:size(handles.AllRatingsX,2)
                colorindex = mod(i,7); if colorindex==0, colorindex = 7; end
                rows = [cellstr(rows);sprintf('<html><font color="%s">[%02d]</font> %s',rgbconv(handles.CS(colorindex,:)),i,handles.AllFilenames{i})];
            end
            set(handles.listbox,'String',rows);
            % Update reliability box
            box = reliability(handles.AllRatingsX,handles.AllRatingsY);
            set(handles.reliability,'Data',box);
            guidata(handles.figure_annotations,handles);
        end
    end
    set(handles.toggle_meanplot,'Enable','on');
    guidata(handles.figure_annotations,handles);
end

% ===============================================================================

function button_delseries_Callback(hObject,~)
    handles = guidata(hObject);
    % Get currently selected item
    index = get(handles.listbox,'Value')-1;
    % Cancel if the first row is selected
    if index == 0, msgbox('You cannot delete the first row.'); return; end
    % Cancel if only one row remains
    if size(handles.AllRatingsX,2)<2, msgbox('At least one file must remain.'); return; end
    % Remove the selected item from program
    handles.AllRatingsX(:,index) = [];
    handles.AllRatingsY(:,index) = [];
    handles.AllFilenames(index) = [];
    % Update mean series
    handles.MeanRatingsX = mean(handles.AllRatingsX,2);
    handles.MeanRatingsY = mean(handles.AllRatingsY,2);
    % Update plot and listbox
    guidata(handles.figure_annotations,handles);
    update_plots(handles);
    % Update list box
    set(handles.listbox,'Value',1);
    rows = {'<html><u>Annotation Files'};
    for i = 1:size(handles.AllRatingsX,2)
        colorindex = mod(i,7); if colorindex==0, colorindex = 7; end
        rows = [cellstr(rows);sprintf('<html><font color="%s">[%02d]</font> %s',rgbconv(handles.CS(colorindex,:)),i,handles.AllFilenames{i})];
    end
    set(handles.listbox,'String',rows);
    % Update reliability box
    box = reliability(handles.AllRatingsX,handles.AllRatingsY);
    set(handles.reliability,'Data',box);
    % Turn off multiplot options if only one plot is left
    if size(handles.AllRatingsX,2)<2
        set(handles.toggle_meanplot,'Enable','off','Value',0);
        toggle_meanplot_Callback(handles.toggle_meanplot,[]);
    end
    % Update guidata with handles
    guidata(handles.figure_annotations,handles);
end

% ===============================================================================

function toggle_meanplot_Callback(hObject,~)
    handles = guidata(hObject);
    update_plots(handles);
    if get(hObject,'Value')==get(hObject,'Max')
        % Update list box
        set(handles.listbox,'Value',1);
        rows = {'<html><u>Annotation Files'};
        for i = 1:size(handles.AllRatingsX,2)
            rows = [cellstr(rows);sprintf('<html><font color="%s">[%02d]</font> %s',rgbconv([.8 .8 .8]),i,handles.AllFilenames{i})];
        end
        rows = [cellstr(rows);'<html><font color="red">[M]</font> Mean Plot'];
        set(handles.listbox,'String',rows);
    elseif get(hObject,'Value')==get(hObject,'Min')
        % Update list box
        set(handles.listbox,'Value',1);
        rows = {'<html><u>Annotation Files'};
        for i = 1:size(handles.AllRatingsX,2)
           colorindex = mod(i,7); if colorindex==0, colorindex = 7; end
            rows = [cellstr(rows);sprintf('<html><font color="%s">[%02d]</font> %s',rgbconv(handles.CS(colorindex,:)),i,handles.AllFilenames{i})];
        end
        set(handles.listbox,'String',rows);
    end
    guidata(hObject,handles);
end

% ===============================================================================

function toggle_playpause_Callback(hObject,~)
    handles = guidata(hObject);
    if get(hObject,'Value')==get(hObject,'Max')
        % Send play() command to VLC and start timer
        handles.vlc.playlist.play();
        start(handles.timer2);
        set(hObject,'String','Pause');
        set(handles.menu_export,'Enable','off');
    else
        % Send pause() command to VLC and stop timer
        handles.vlc.playlist.togglePause();
        stop(handles.timer2);
        set(hObject,'String','Resume','Value',0);
        set(handles.menu_export,'Enable','on');
    end
    guidata(hObject, handles);
end

% ===============================================================================

function timer2_Callback(~,~,handles)
    handles = guidata(handles.figure_annotations);
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
    % Jump VLC playback to clicked position
    handles = guidata(hObject);
    if strcmp(axis,'X')
        coord = get(handles.axis_X,'CurrentPoint');
    elseif strcmp(axis,'Y')
        coord = get(handles.axis_Y,'CurrentPoint');
    end
    duration = handles.vlc.input.length;
    if coord(1,1) > 0 && coord(1,1)*1000 < duration
        handles.vlc.input.time = coord(1,1)*1000;
    else
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

function update_plots(handles)
    handles = guidata(handles.figure_annotations);
    if get(handles.toggle_meanplot,'Value')==get(handles.toggle_meanplot,'Min')
        % Configure first (X) axis for normal plots
        axes(handles.axis_X); cla;
        plot(handles.Seconds,handles.AllRatingsX,'-','LineWidth',2,'ButtonDownFcn',{@axis_click_Callback,'X'});
        ylim([-1*handles.mag,handles.mag]);
        xlim([0,ceil(handles.dur)+1]);
        set(gca,'YTick',0,'YTickLabel',[],'YGrid','on');
        ylabel('Communion (X)','FontSize',10);
        set(handles.axis_X,'ButtonDownFcn',{@axis_click_Callback,'X'});
        % Configure second (Y) axis for normal plots
        axes(handles.axis_Y); cla;
        plot(handles.Seconds,handles.AllRatingsY,'-','LineWidth',2,'ButtonDownFcn',{@axis_click_Callback,'Y'});
        ylim([-1*handles.mag,handles.mag]);
        xlim([0,ceil(handles.dur)+1]);
        set(gca,'YTick',0,'YTickLabel',[],'YGrid','on');
        ylabel('Agency (Y)','FontSize',10);
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
        xlim([0,ceil(handles.dur)+1]);
        set(gca,'YTick',0,'YTickLabel',[],'YGrid','on');
        ylabel('Communion (X)','FontSize',10);
        axes(handles.axis_Y); cla;
        set(handles.axis_Y,'ButtonDownFcn',{@axis_click_Callback,'Y'});
        hold on;
        plot(handles.Seconds,handles.AllRatingsY,'-','LineWidth',2,'Color',[.8 .8 .8],'ButtonDownFcn',{@axis_click_Callback,'Y'});
        plot(handles.Seconds,handles.MeanRatingsY,'-','LineWidth',2,'Color',[1 0 0],'ButtonDownFcn',{@axis_click_Callback,'Y'});
        ylim([-1*handles.mag,handles.mag]);
        xlim([0,ceil(handles.dur)+1]);
        set(gca,'YTick',0,'YTickLabel',[],'YGrid','on');
        ylabel('Agency (Y)');
        hold off;
    end
    guidata(handles.figure_annotations,handles);
end

% ===============================================================================

function figure_annotations_SizeChanged(hObject,~)
    handles = guidata(hObject);
    if isfield(handles,'figure_annotations')
        pos = getpixelposition(handles.figure_annotations);
        % Force to remain above a minimum size
        if pos(3) < 1024 || pos(4) < 600
            setpixelposition(handles.figure_annotations,[pos(1) pos(2) 1024 600]);
            movegui(handles.figure_annotations,'center');
        end
        % Update the size and position of the VLC controller
        if isfield(handles,'vlc')
            move(handles.vlc,getpixelposition(handles.axis_guide));
        end
    end
end

% =========================================================

function figure_annotations_CloseRequest(hObject,~)
    handles = guidata(hObject);
    % Remove timer as part of cleanup
    delete(handles.timer2);
    delete(gcf);
end