function [ updated ] = fig_configure( previous )
%CONFIGURE Summary of this function goes here
%   Detailed explanation goes here

    prompt = {'Magnitude','Samples per second','Label X:','Label Y:','Label 0:','Label 1:','Label 2:','Label 3:','Label 4:','Label 5:','Label 6:','Label 7:'};
    dlg_title = 'DARMA Settings';
    num_lines = 1;
    def = {num2str(previous.mag),num2str(previous.sps),previous.labelX,previous.labelY,previous.label0,previous.label1,previous.label2,previous.label3,previous.label4,previous.label5,previous.label6,previous.label7};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    if isempty(answer), updated = previous; return; end
    updated.mag = str2double(answer{1});
    updated.sps = str2double(answer{2});
    updated.labelX = answer{3};
    updated.labelY = answer{4};
    updated.label0 = answer{5};
    updated.label1 = answer{6};
    updated.label2 = answer{7};
    updated.label3 = answer{8};
    updated.label4 = answer{9};
    updated.label5 = answer{10};
    updated.label6 = answer{11};
    updated.label7 = answer{12};
end

