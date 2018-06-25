function ImgVol = get_image_sequence_from_video(videoPath)

crowdVideo = VideoReader(videoPath);
ii = 1;

 while hasFrame(crowdVideo)
    img = readFrame(crowdVideo);
    if size(img, 3) == 3 % if color images, convert it to gray
        img = rgb2gray(img);
    end
    ImgVol(:, :, ii) =  im2double(imresize(img,[480,480]));
    ii = ii+1;
 end
end