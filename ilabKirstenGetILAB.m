function ILAB=ilabGetILAB(action)
%ILABGETILAB Returns the ILAB data structure
%   ILAB = ILABGETILAB creates a new ILAB data struct if it does not exist.
%   The ILAB data structure contains raw data and all the information necessary
%   to display it. Thus the coordinate system travels with the data enabling
%   conversion to proper screen coordinates on the fly.
%
%   action: The only valid action is 'reset' to clear the ILAB variable. The
%           user must also take care to then clean up the interface.
%
%   The designation of OPTIONAL means that the field doesn't have to be
%   filled in. However, ILAB structures should contain all fields as
%   listed below.
%
%   ILAB fields:
%    path        pathname for fname  (OPTIONAL)
%    fname       filename of dataset (OPTIONAL)
%    type        Type of eyetracker  (OPTIONAL)
%    vers        version of appropriate file format (OPTIONAL)
%    subject     Name of subject (OPTIONAL)
%    date        Date of acquisition (OPTIONAL)
%    time        Time of acquisition (only returned by ASL). (OPTIONAL)
%    comment     Comment string (OPTIONAL)
%    private     variables particular to different manufacturers. Contains
%                information not likely to be generally used by ILAB, but
%                which should be saved anyway. This should be followed by
%                a subfield defining the manufacturer and would generally
%                correspond to the type of data being read: asl, iscan,
%                cortex, iview. Further subfields contain the actual
%                values. (OPTIONAL)
%    coordSys    Assigned coordinate system parameters (REQUIRED)
%       name        name of coordinate system
%       data        Raw data for transformation between computer screen
%                   and eye tracker coordinates
%       params      parameters for linear transformation between
%                   computer screen and eye tracker coordinates
%       screen      Width and Height of computer screen in pixels
%       eyetracker  Width and Height of eye tracker screen in pixels
%    acqRate     Acquisition rate (Hz)  (REQUIRED)
%    acqIntvl    Acquisition interval (ms) = 1000/rate (REQUIRED)
%    trials      Number of trials in dataset (REQUIRED)
%    data        Data values in ILAB coordinate space (REQUIRED)
%    index       Trial index (trials x 2 or 3 col)
%                [start end] or [start end target] (REQUIRED)
%    image       Stimulus image file information (OPTIONAL)
%    trialcodes  Trialcodes used to specify this dataset. This is to deal
%                with the problem of the trialcodes for a dataset being
%                different than the default. In that case when the dataset
%                properties dialog is opened there is the odd situation
%                that a loaded dataset may appear to have an incorrect
%                number of start and stop events if the current set of trialcodes
%                differs from the trialcodes for a dataset. (OPTIONAL)

% Authors: Roger Ray, Darren Gitelman
% $Id: ilabGetILAB.m 91 2010-06-08 16:39:25Z drg $

if nargin == 1
    if strcmpi(action,'reset')
        clear global ILAB
    else
        error('Bad action string for ilabGetILAB.');
    end    
end

global ILAB

if isempty(ILAB)

    % ILAB.coordSys.screen must be set to some nominal value or loading of variables will
    % bomb when it looks for a coordinate system.
    
    ILAB = struct('path',      [],...
        'fname',     [],...
        'type',      [],...
        'vers',      [],...
        'subject',   [],...
        'date',      [],...
        'time',      [],...
        'comment',   [],...
        'private',   [],...
        'coordSys',  struct(...
            'name',      '',...
            'data',      [],...
            'params',    struct('h',[],...
                                'v',[]),...
            'screen',    [640 480],...
            'eyetrack',  []),...
        'acqRate',   [],...
        'acqIntvl',  [],...
        'data',      [],...
        'trials',    0,...
        'index',     [],...
        'image',       struct('files', struct('fname',   '',...
                                              'sfname',  '',...
                                              'trial',   '',...
                                              'start',   '',...
                                              'duration',''),...
                              'pathpref',  1,...
                              'version',  '',...
                              'loaded',    0,...
                              'handle',   [],...
                              'show',      0),...
         'trialCodes',  []);
    
end;

return;
