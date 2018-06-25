function [feat prms] = stacog(Grad, prms)
%
% STACOG feature extraction
%
%  [feat prms] = glac(Grad, prms)
%
%  Input:
%   Grad - Gradient data tensor [height x width x 3(dx,dy,dz)  x depth]
%   prms - Parameters [struct]
%          .rvecs   - Displacement (rx,ry,rz) [{[0 1 0; 1 1 0; 1 0 0; 1 -1 0;
%          										 meshgrid(-1:1,-1:1), ones(9,1)]}]
%                     or scalar (r) for [0 r 0; r r 0; r 0 0; r -r 0; r*meshgrid(-1:1,-1:1), ones(9,1)]
%          .ztol    - Tolerance for zero gradients [{0.05}] 
%          .nxybin  - Number of orientation bins in x-y plane  [{4}]
%          .ntbin   - Number of orientation bin-layers along t-axis [{2}]
%          .reflect - true  for calculating direction in half-region (0~180) [{true}|false]
%                     false for whole-region (0~360)
%
%  Output:
%   feat - Feature vector [nbin+nr*nbin^2 x 1]
%           nbin = nxybin*(2*ntbin+1) + 1 for reflect = 1
%                = nxybin*(2*ntbin+1) + 2 for reflect = 0
%   prms - Parameters [struct]
%           in which missing fields are filled with default values.
%
% Reference:
% [1] T. Kobayashi and N. Otsu, 
%     "Motion Recognition Using Local Auto-Correlation of Space-Time Gradients", PRL 33(9), 2012.
%

%- Parameters -%
[rx ry] = meshgrid(-1:1,-1:1);
rz = [zeros(4,1);ones(9,1)];
def_rvecs = [0 1; 1 1; 1 0; 1 -1; rx(:) ry(:)];
if ~exist('prms', 'var') || isempty(prms), prms = struct; end
prms = parseparam(prms, 'rvecs',[def_rvecs,rz], 'ztol',0.05, 'nxybin',4, 'ntbin', 2, 'reflect',true, 'nbin',NaN);
if isscalar(prms.rvecs), prms.rvecs = [prms.rvecs*def_rvecs,rz]; end

%- STACOG -%
[feat prms.nbin] = stacog_mex(Grad, prms.rvecs, prms.ztol, prms.nxybin, prms.ntbin, prms.reflect);
