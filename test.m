function test
%addpath('F:\master degree\Implementation\PCANet_demo\');
setup;
%ImgVol =video2imageVolume('F:\master degree\Dataset\UCF Web\Abnormal Crowds\3452204_031_c.avi');
ImgVol = get_image_sequence_of_specific_dirct('F:\master degree\Dataset\UCSD_Anomaly_Dataset\UCSDped2\Test\Test006\','*.tif');
%- Input movie -%
img = ImgVol;%rand(240,320,10);

%- Spatio-temporal gradients -%
grad3d = @(I) cat(3, I(2:end-1,3:end,2)-I(2:end-1,1:end-2,2), I(3:end,2:end-1,2)-I(1:end-2,2:end-1,2), I(2:end-1,2:end-1,3)-I(2:end-1,2:end-1,1));

%%-- Frame-baesd Feature Extraction --%%
prms = struct('rvecs',2,'nxybin',4,'ntbin',2,'reflect',true);
G = zeros(size(img,1)-2,size(img,2)-2,3,2);
%- Initial gradients -%
G(:,:,:,1) =  grad3d(img(:,:,1:3));
for i = 4:size(img,3)
	%- Current gradients -%
	G(:,:,:,2) = grad3d(img(:,:,i-2:i));

	%- STACOG feature (frame-wise) -%
	[fvec(:,i-3) prms] = stacog(G, prms);
    
	%- Update gradients -%
	G = circshift(G, [0,0,0,-1]);
%     %-------- PCA to reduce the dimensions
% COEFF = princomp(fvec(:,i-3)');                     %compress raws
% Tw = COEFF(:,1:100)';
% feaMatPCA = Tw*fvec(:,i-3); 
%%-- Visualization --%%
%- Show the orientation bins -%
figure('name','Orientation bins for stacog');
display_orientation_bins(prms);

figure('name','stacog features');
ford_ind = feature_order_index(prms);
display_feat(fvec(ford_ind==0),fvec(ford_ind==1),prms,[0.05,0.5,0.9,0.5]);
text(prms.nbin*(0.5:1:size(prms.rvecs,1)),zeros(size(prms.rvecs,1),1),num2str(prms.rvecs),'FontSize',8,'HorizontalAlignment','center');
text(prms.nbin*size(prms.rvecs,1),0,'=(\Delta_x \Delta_y)');

end
F = sum(fvec,2);

%%-- Visualization --%%
%- Show the orientation bins -%
figure('name','Orientation bins for stacog');
display_orientation_bins(prms);

figure('name','stacog features');
ford_ind = feature_order_index(prms);
display_feat(F(ford_ind==0),F(ford_ind==1),prms,[0.05,0.5,0.9,0.5]);
text(prms.nbin*(0.5:1:size(prms.rvecs,1)),zeros(size(prms.rvecs,1),1),num2str(prms.rvecs),'FontSize',8,'HorizontalAlignment','center');
text(prms.nbin*size(prms.rvecs,1),0,'=(\Delta_x \Delta_y)');

%%---- Utility function ----%%
function display_feat(feat0th, feat1st, prms, pos)
	nr = size(prms.rvecs,1);
	width_per_bin = min(pos(4)/prms.nbin, pos(3)/(prms.nbin*nr+3));
	axes('position',[pos(1),pos(2),width_per_bin,width_per_bin*prms.nbin]);
	imagesc(feat0th);                      title('0th order'); axis off;
	axes('position',[pos(1)+width_per_bin*3,pos(2),width_per_bin*prms.nbin*nr,width_per_bin*prms.nbin]);
	imagesc(reshape(feat1st,prms.nbin,[]));title('1st order'); axis off;
	line(0.5+prms.nbin*ones(2,1)*[1:nr],repmat([-1;prms.nbin+1],1,nr),'color',[0.8,0.8,0.8],'linewidth',2);
