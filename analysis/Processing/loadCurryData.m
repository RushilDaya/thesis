function Data = loadCurryData( filename, device )
%LOADCURRYDATA Summary of this function goes here
%   Detailed explanation goes here

    %% Initialization
    [pathstr,name,~] = fileparts(filename);
    datfilename = sprintf('%s/%s.dat',pathstr, name);
    rsfilename = sprintf('%s/%s.rs3',pathstr, name);
    dapfilename = sprintf('%s/%s.dap',pathstr, name);
    
    if ~exist(datfilename, 'file')
        error('Error loading file: Cannot find %s', datfilename);
    end
    if ~exist(rsfilename, 'file')
        error('Error loading file: Cannot find %s', rsfilename);
    end
    if ~exist(dapfilename, 'file')
        error('Error loading file: Cannot find %s', dapfilename);
    end
    
    %% Read parameters from dap file
    fid = fopen(dapfilename,'rt');
    cell = textscan(fid,'%s','whitespace','','endofline','§');
    fclose(fid);

    % tokens (second line is for Curry 6 notation)
    tokens = { 'NumSamples'; 'NumChannels'; 'NumTrials'; 'SampleFreqHz';  'TriggerOffsetUsec';  'DataFormat'; 'DataSampOrder' 
              'NUM_SAMPLES';'NUM_CHANNELS';'NUM_TRIALS';'SAMPLE_FREQ_HZ';'TRIGGER_OFFSET_USEC';'DATA_FORMAT';'DATA_SAMP_ORDER' };

    % scan in cell 1 for keywords - all keywords must exist!
    cont = cell2mat(cell{1});
    nb_tokens = size(tokens,1);
    a = zeros(nb_tokens,1);
    for i = 1:nb_tokens
         current_token = tokens{i,1};
         index = strfind(cont,current_token);
         if ~isempty ( index )
             text = sscanf(cont(index+numel(current_token):end),' = %s');     % skip =
             if strcmp ( text,'ASCII' ) || strcmp ( text,'CHAN' ) % test for alphanumeric values
                 a(i) = 1;
             else 
                 c = sscanf(text,'%f');         % try to read a number
                 if ~isempty ( c )
                     a(i) = c;                  % assign if it was a number
                 end
             end
         end 
    end

    % derived variables. numbers (1) (2) etc are the token numbers
    nSamples    = a(1)+a(1+nb_tokens/2);
    nChannels   = a(2)+a(2+nb_tokens/2);
    nTrials     = a(3)+a(3+nb_tokens/2);
    fFrequency  = a(4)+a(4+nb_tokens/2);
    fOffsetUsec = a(5)+a(5+nb_tokens/2);
    nASCII      = a(6)+a(6+nb_tokens/2);
    nMultiplex  = a(7)+a(7+nb_tokens/2);
    
    
    %% read labels from rs3 file
    fid = fopen(rsfilename,'rt');
    cell = textscan(fid,'%s','whitespace','','endofline','§');
    fclose(fid);

    % scan in cell 1 for LABELS (occurs four times per channel group)
    cont = cell2mat(cell{1});
    index = strfind(cont,'LABELS');
    nt = size(index,2);
    nc = 0;
    channel_names = num2cell(1:nChannels);

    % initialize labels
    for i = 1:nChannels
        text = sprintf('EEG%d',i);
        channel_names(i) = cellstr(text);
    end

    for i = 4:4:nt                                                      % loop over channel groups
        newlines = index(i-1) - 1 + strfind(cont(index(i-1):end),char(10));   % newline
        last = nChannels - nc;
        for j = 1:last                                                  % loop over labels
            text = cont(newlines(j)+1:newlines(j+1)-1);
            if isempty(strfind(text,'END_LIST'))
                nc = nc + 1;
                channel_names(nc) = cellstr(text);
            else 
                break
            end
        end 
    end
    
    %% read dat file
    if nASCII == 1
        fid = fopen(datfilename,'rt');
        cell = textscan(fid,'%f',nChannels*nSamples*nTrials);
        fclose(fid);
        data = reshape([cell{1}],nChannels,nSamples*nTrials);
    else
        fid = fopen(datfilename,'rb');
        data = fread(fid,[nChannels,nSamples*nTrials],'float32');
        fclose(fid);
    end

    % transpose?
    if nMultiplex == 1
        data = data';
    end
    
    trigger_channel_idx = find(strcmp(channel_names, 'Trigger'));
    if numel(trigger_channel_idx) == 1
        labels = data(trigger_channel_idx,:);
        channel_names(trigger_channel_idx) = [];
        data(trigger_channel_idx,:) = [];
        
        if strcmp(device, 'Neuvo')
            baseline_marker = 65408;
        elseif strcmp(device, 'Synamps')
            baseline_marker = 128; 
        else
            error('Error in loadCurryData : Unknown Neuroscan Device');
        end
                
        tmpLabels = zeros(1, size(data,2));
        onset_samples = find(diff(labels))+1;
        tmpLabels(onset_samples) = labels(onset_samples);
%         tmpLabels(onset_samples) = labels(onset_samples)-baseline_marker;
        
        labels = tmpLabels;
        nChannels = nChannels - 1;
    else
        labels = zeros(1,nSamples);
    end
    
    Data.EEG = data;
    Data.nb_channels = nChannels;
    Data.channel_names = channel_names;
    Data.sample_rate = fFrequency;
    Data.labels = labels;
end

