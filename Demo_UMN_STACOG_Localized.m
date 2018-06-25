clear all; 
addpath('F:\master degree\Implementation\PCANet_demo\');
setup;

TrnData = get_image_sequence_of_specific_dirct('F:\master degree\Dataset\UMN Optical Flow Magnitude\UMN Image Sequence\Train\','*.jpg');
 TstData = get_image_sequence_of_specific_dirct('F:\master degree\Dataset\UMN Optical Flow Magnitude\UMN Image Sequence\Test\','*.jpg');

 % localized the anomaly in the scene---So we divide the frame to
 % non-overlapping regions
 ImgHeight = 240; 
ImgWidth =320;
Num_regions_vertical =6;
Num_regions_horisontal=8;
TrnSize =517;
TstSize=930;%950
 % ==== prepare the training images ============
 
TrnData_map = cell(Num_regions_vertical,Num_regions_horisontal);

map_y_index =1;
 for y=1:40:ImgHeight
     map_x_index=1;
     for x= 1:40:ImgWidth
         TrnData_map{map_y_index,map_x_index}=TrnData(y:y+39,x:x+39,:);
         map_x_index =map_x_index+1;
     end
     map_y_index = map_y_index+1;
 end
% ===========================================================
STACOG_map = cell(Num_regions_vertical,Num_regions_horisontal);
fprintf('\n ====== STACOG Feature Extraction ======= \n')

for map_y_index=1:Num_regions_vertical
    for map_x_index=1:Num_regions_horisontal
        map_y_index
        map_x_index
        ftrain = extract_stacog_feature(TrnData_map{map_y_index,map_x_index});
        STACOG_map{map_y_index,map_x_index} = ftrain';
    end
end
 
fprintf('\n ====== Training k medoids ======= \n')
tic;
 
kmedoids_centers_map = cell(Num_regions_vertical,Num_regions_horisontal);
for map_y_index=1:Num_regions_vertical
    for map_x_index=1:Num_regions_horisontal
          map_y_index
        map_x_index
        temp =STACOG_map{map_y_index,map_x_index};
         [idx,C] = kmedoids(temp,5);
         kmedoids_centers_map{map_y_index,map_x_index} =C;
    end
end

kmedoids_TrnTime = toc;
%clear PCANet_map; 

 fprintf('\n=========Test STACOG Features=========\n')
% ==== prepare the training images ============
TstData_map = cell(Num_regions_vertical,Num_regions_horisontal);

map_y_index =1;
 for y=1:40:ImgHeight
     map_x_index=1;
     for x= 1:40:ImgWidth
         TstData_map{map_y_index,map_x_index}=TstData(y:y+39,x:x+39,:);
         map_x_index =map_x_index+1;
     end
     map_y_index = map_y_index+1;
 end
%===========================================================
 STACOG_map_test = cell(Num_regions_vertical,Num_regions_horisontal);
fprintf('\n ====== STACOG Feature Extraction for Test Samples======= \n')

for map_y_index=1:Num_regions_vertical
    for map_x_index=1:Num_regions_horisontal
        map_y_index
        map_x_index
        ftrain = extract_stacog_feature(TstData_map{map_y_index,map_x_index});
        STACOG_map_test{map_y_index,map_x_index} = ftrain';
    end
end

score_anomaly_map = cell(Num_regions_vertical,Num_regions_horisontal);
test_correlation = cell(TstSize,1);
tic; 
for idx = 1:TstSize
      
    for map_y_index=1:Num_regions_vertical
        for map_x_index=1:Num_regions_horisontal
          test_features=  STACOG_map_test{map_y_index,map_x_index}(idx,:);
          medoids =cell2mat(kmedoids_centers_map(map_y_index,map_x_index));
          score_anomaly_map{map_y_index,map_x_index}= min(pdist2(test_features,medoids,'correlation'));
        end
    end
    test_correlation{idx,1} = score_anomaly_map;
end
  