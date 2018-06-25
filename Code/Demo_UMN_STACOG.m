 clear all; 
 setup;
 TrnData = get_image_sequence_of_specific_dirct('F:\master degree\Dataset\UMN Optical Flow Magnitude\UMN Image Sequence\Scene 3\Train\','*.jpg');
 TstData = get_image_sequence_of_specific_dirct('F:\master degree\Dataset\UMN Optical Flow Magnitude\UMN Image Sequence\Scene 3\Test\','*.jpg');

 training_features = extract_stacog_feature(TrnData);

fprintf('\n ====== Training k medoids ======= \n')

  [idx,medoids] = kmedoids(training_features',5);
  %K-means
  %[idx,medoids] = kmeans(training_features',5);
  tic;
 fprintf('\n=========Test STACOG Features=========\n')
  test_features = extract_stacog_feature(TstData);
  test_samples=size(test_features,2);
 %score_anomaly_cityblock = zeros(test_samples,1);
%% score_anomaly_correlation=zeros(test_samples,1);
% for i=1:test_samples
%     %score_anomaly_cityblock(i)= min(pdist2(test_features(:,i)',medoids,'cityblock'));
%     score_anomaly_correlation(i) =min(pdist2(test_features(:,i)',medoids,'correlation'));
% end
%score_anomaly_correlation =min(pdist2(test_features',medoids,'correlation'),[],2);
%score_anomaly_cityblock= min(pdist2(test_features',medoids,'cityblock'),[],2);
score_anomaly_euclidean =min(pdist2(test_features',medoids,'euclidean'),[],2);
TimeperTest = toc;
 Averaged_TimeperTest = toc/test_samples;

fprintf('\n     Average testing time %.2f secs per test sample. \n\n',Averaged_TimeperTest);
