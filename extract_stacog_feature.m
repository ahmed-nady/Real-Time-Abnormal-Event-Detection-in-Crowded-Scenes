function fvec =extract_stacog_feature(img)
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
    end
end