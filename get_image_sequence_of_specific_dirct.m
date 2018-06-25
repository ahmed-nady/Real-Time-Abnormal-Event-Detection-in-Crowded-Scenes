function VolData = get_image_sequence_of_specific_dirct( basePath,extension)
% %loop through each training sample
    %basePath = 'F:\master degree\Dataset\UCSD_Anomaly_Dataset\UCSDped1\Train\';
    currentFolder = pwd
   
    img_index =0;
    
        cd (basePath); % please replace "..." by your images path
        a = dir(extension); % directory of images, ".jpg" can be changed, for example, ".bmp" if you use
        img_count = length(a);
        for i = 1: img_count
            img_index = img_index +1;
            ImgName = getfield(a, {i}, 'name');
            Imgdat = imread(ImgName);
            %Imgdat = imresize(Imgdat,[160,240]);
            %imshow(Imgdat)
            if size(Imgdat, 3) == 3 % if color images, convert it to gray
                Imgdat = rgb2gray(Imgdat);
            end
%             [height width] = size(Imgdat);
%             if img_index == 1
%                 VolData = zeros(height, width, length(a));
%             end
            VolData(:, :, img_index) =  im2double(Imgdat);
            %imshow( VolData(:, :, 1))
        end
    
   cd(currentFolder);
end