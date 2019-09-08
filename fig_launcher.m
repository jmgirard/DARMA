function fig_launcher
%FIG_LAUNCHER Window to launch the other windows
% License: https://github.com/jmgirard/DARMA/blob/master/LICENSE.txt

    global version;
    version = 6.06;
    % Create and center main window
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    handles.figure_launcher = figure( ...
        'Units','pixels', ...
        'Position',[0 0 600 350], ...
        'Name','DARMA: Dual Axis Rating and Media Annotation', ...
        'MenuBar','none', ...
        'ToolBar','none', ...
        'NumberTitle','off', ...
        'Visible','off', ...
        'Resize','off', ...
        'Color',defaultBackground);
    movegui(handles.figure_launcher,'center');
    % Create UI elements
    handles.axis_title = axes(handles.figure_launcher,...
        'Units','normalized', ...
        'Position',[0.05 0.60 0.90 0.30], ...
        'Color',[0.2 0.2 0.2],...
        'Box','on','XTick',[],'YTick',[],...
        'ButtonDownFcn',@website);
    xlim([-1 1]); ylim([-1 1]);
    text(0,0,sprintf('DARMA v%.2f',version),'Color',[1 1 1],'FontSize',42,...
        'FontName','cambria','HorizontalAlignment','center',...
        'ButtonDownFcn',@website);
    handles.push_collect = uicontrol(handles.figure_launcher, ...
        'Style','pushbutton', ...
        'Units','Normalized', ...
        'Position',[0.05 0.10 0.425 0.40], ...
        'String','Collect Ratings', ...
        'FontSize',18, ...
        'Callback','fig_collect()');
    handles.push_review = uicontrol(handles.figure_launcher, ...
        'Style','pushbutton', ...
        'Units','Normalized', ...
        'Position',[0.525 0.10 0.425 0.40], ...
        'String','Review Ratings', ...
        'FontSize',18, ...
        'Callback','fig_review()');
    set(handles.figure_launcher,'Visible','on');
    guidata(handles.figure_launcher,handles);
    addpath('Functions');
    % Check that VLC is installed
    axctl = actxcontrollist;
    index = strcmp(axctl(:,2),'VideoLAN.VLCPlugin.2');
    if sum(index)==0
        choice = questdlg(sprintf('DARMA requires the free, open source VLC Media Player.\nPlease be sure to download the 64-bit Windows version.\nPlease be sure to enable the "ActiveX plugin" option.\nOpen download page?'),...
            'DARMA','Yes','No','Yes');
        switch choice
            case 'Yes'
                web('http://www.videolan.org/vlc/download-windows.html','-browser');
        end
    end
    % Check for updates
    try
        rss = urlread('https://github.com/jmgirard/DARMA/releases');
        index = strfind(rss,'DARMA v');
        newest = str2double(rss(index(1)+7:index(1)+10));
        current = version;
        if current < newest
            choice = questdlg(sprintf('DARMA has detected that an update is available.\nOpen download page?'),...
                'DARMA','Yes','No','Yes');
            switch choice
                case 'Yes'
                    web('https://github.com/jmgirard/DARMA/releases','-browser');
                    delete(handles.figure_launcher);
            end
        end
    catch
    end
end

function website(~,~)
    choice = questdlg('Open DARMA website in browser?','DARMA','Yes','No','Yes');
    switch choice
        case 'Yes'
            web('https://darma.jmgirard.com/','-browser');
        otherwise
            return;
    end
end