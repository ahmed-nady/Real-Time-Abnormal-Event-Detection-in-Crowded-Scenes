function finds = feature_order_index(prms)
%
% Index of feature order
%
%  feat_inds = feature_order_index(prms)
%
% Input:
%  prms - Parameters for stacog [struct]
%
% Output:
%  feat_inds - Feature order indexes, 0th or 1st  [dim x 1]
%

finds = cat(1, zeros(prms.nbin,1), ones(size(prms.rvecs,1)*prms.nbin^2,1) );
