function [ output_args ] = saveDetails( details, username)
%saves the time stamps for the run as well
%as other meta information
    currentTime = string(datestr(now,'dd-mm-yyyy HH:MM'));
    fileName = strcat('stimulations/',username, currentTime,'.mat');
    save(char(fileName),'details');
end

