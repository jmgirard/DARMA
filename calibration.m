%Prompt for start
choice = questdlg('Run joystick calibration?', ...
	'Calibration', ...
	'Calibrate','Exit','Calibrate');
if strcmp(choice,'Calibrate')
    %Create output file
    diary(sprintf('%s.txt',datestr(now,30)));
    a = axes('XLim',[-1,1],'YLim',[-1,1],'NextPlot','add');
    %Start joystick
    try
        j = vrjoystick(1);
    catch err
        errordlg('No joystick detected.');
        error('No joystick detected.');
    end
    disp(caps(j));
    %Move up
    fprintf('Up\n');
    p = plot(0,0.9,'ro','MarkerSize',10);
    t = text(0,0.8,'Move joystick up','HorizontalAlignment','center');
    pause(1);
    for i = 1:4
        [j_axes,j_buttons,j_povs] = read(j);
        fprintf('%s\t%s\t%s\n',mat2str(j_axes),mat2str(j_buttons),mat2str(j_povs));
        pause(1);
    end
    delete(p);
    delete(t);
    %Move right
    fprintf('\nRight\n');
    p = plot(0.9,0,'ro','MarkerSize',10);
    t = text(0.8,0,'Move joystick right','HorizontalAlignment','right');
    pause(1);
    for i = 1:4
        [j_axes,j_buttons,j_povs] = read(j);
        fprintf('%s\t%s\t%s\n',mat2str(j_axes),mat2str(j_buttons),mat2str(j_povs));
        pause(1);
    end
    delete(p);
    delete(t);
    %Move down
    fprintf('\nDown\n');
    p = plot(0,-0.9,'ro','MarkerSize',10);
    t = text(0,-0.8,'Move joystick down','HorizontalAlignment','center');
    pause(1);
    for i = 1:4
        [j_axes,j_buttons,j_povs] = read(j);
        fprintf('%s\t%s\t%s\n',mat2str(j_axes),mat2str(j_buttons),mat2str(j_povs));
        pause(1);
    end
    delete(p);
    delete(t);
    %Move left
    fprintf('\nLeft\n');
    p = plot(-0.9,0,'ro','MarkerSize',10);
    t = text(-0.8,0,'Move joystick left','HorizontalAlignment','left');
    pause(1);
    for i = 1:4
        [j_axes,j_buttons,j_povs] = read(j);
        fprintf('%s\t%s\t%s\n',mat2str(j_axes),mat2str(j_buttons),mat2str(j_povs));
        pause(1);
    end
    delete(p);
    delete(t);
    %Pull trigger
    fprintf('\nTrigger\n');
    p = plot(0,0,'ro','MarkerSize',10);
    t = text(0,-0.1,'Pull and hold trigger','HorizontalAlignment','center');
    pause(1);
    for i = 1:4
        [j_axes,j_buttons,j_povs] = read(j);
        fprintf('%s\t%s\t%s\n',mat2str(j_axes),mat2str(j_buttons),mat2str(j_povs));
        pause(1);
    end
    delete(p);
    delete(t);
    %End
    m = msgbox('Calibration complete');
    waitfor(m);
end
delete(gcf);
diary off;