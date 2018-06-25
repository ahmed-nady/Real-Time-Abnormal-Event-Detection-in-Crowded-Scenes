function training_features = get_image_vol_from_videos( basePath,extension)
% %loop through each training sample
    %basePath = 'F:\master degree\Dataset\UCSD_Anomaly_Dataset\UCSDped1\Train\';
    setup;
    currentFolder = pwd
   
    video_index =0;
    

    cd (basePath); % please replace "..." by your images path
        a = dir(extension); % directory of images, ".jpg" can be changed, for example, ".bmp" if you use
        video_count = length(a);
        for i = 1: video_count
            video_index = video_index +1;
            videoPath = getfield(a, {i}, 'name');
            ImgVol = get_image_sequence_from_video(videoPath);
            %% Extract STACOG Features
            training_features{i} = extract_stacog_feature(ImgVol);
%             fname = sprintf('%d.mat', i);
%             save(fname,'ImgVol');
            clear ImgVol;
            %VolData{i}=  ImgVol;
             
        end
    
   cd(currentFolder);
end