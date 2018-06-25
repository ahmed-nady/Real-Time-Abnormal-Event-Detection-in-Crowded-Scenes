  clear all; 
 setup;
  Dataset= get_image_sequence_of_specific_dirct('F:\master degree\Publish Paper\S3_HL\Crowd_PETS09\S3\High_Level\Time_14-33\View_004\','*.jpg');
  %TrnData = Dataset(:,:,3:32);
  TrnData = Dataset(:,:,80:180);
% % TstData(:,:,1:79) = Dataset(:,:,1:79);
% %  TstData(:,:,80:277) =Dataset(:,:,181:end);
 TstData = Dataset;%(:,:,1:108);
% 
 training_features = extract_stacog_feature(TrnData);

fprintf('\n ====== Training k medoids ======= \n')

  [idx,medoids] = kmedoids(training_features',15);
   
  tic;
 fprintf('\n=========Test STACOG Features=========\n')
   test_features= extract_stacog_feature(TstData);
  test_samples=size(test_features,2);
 
score_anomaly_euclidean =min(pdist2(test_features',medoids,'euclidean'),[],2);
 
TimeperTest = toc;
 Averaged_TimeperTest = toc/test_samples;

fprintf('\n     Average testing time %.2f secs per test sample. \n\n',Averaged_TimeperTest);
