function setup
%
% Set up path
%

pname = fileparts(mfilename('fullpath'));
addpath(pname);
addpath(fullfile(pname,'mex',mexext));
