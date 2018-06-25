# Real-Time-Abnormal-Event-Detection-in-Crowded-Scenes
This project is based on STACOG descriptor [1] to detect anomalous event in real-time.

The underlying assumption of the method presented here is that the abnormal event differs from normal ones in their space-time motion pattern. So, STACOG features that considered as spatio-temporal representation is extracted from video sequences. We then perform K-medoids clustering using training features. During the test phase, the anomaly score of each frame is determined from distances between frame-based feature STACOG and center of the clusters.

The proposed anomaly detection method was tested on benchmark dataset: UMN dataset, PETS2009. Experiments show that the proposed method achieves comparable results with the state-of-the-art methods in terms of accuracy while requiring a low computational cost than alternative approaches


References
[1]	T. Kobayashi and N. Otsu, “Motion recognition using local auto-correlation of space–time gradients,” Pattern Recognition Letters, vol. 33, no. 9, pp. 1188–1195, 2012.
