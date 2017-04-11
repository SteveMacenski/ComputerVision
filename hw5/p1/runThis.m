% Steve Macenski (c) 2017

% face detection with eigenfaces and fisherfaces
faces_path = './faces/';
NUM_PEOPLE = 10;
NUM_IM_PER_PERSON = 64;
NUM_IM = NUM_PEOPLE*NUM_IM_PER_PERSON;

[im, person, number, subset] = readFaceImages(faces_path);
im_size = size(im{1,1}); %50x50

%% Eigen-Faces

% (1) for each training image from subset 1: (im-mean)/std then resize to 2500xNUM_IM
training_im = im(subset == 1| subset == 5 );
NUM_TRAINING_IM = size(training_im,2);

X_train = zeros(im_size(1)*im_size(2), NUM_TRAINING_IM);
k=1;
for i = 1:NUM_TRAINING_IM
    image = im{i}(:);
    image = (image - mean(image)) / std(image);
    X_train(:,k) = image;
    k = k + 1;
end
mu = mean(X_train,2); %mean face
X_train = X_train - repmat(mu, [1, NUM_TRAINING_IM]);

% (2) Perform PCA, retain 9,30 principal components of training
largest_eig_keep = 9;
[U,Lambda] = eig(X_train'*X_train);
U = fliplr(U);                            % reorder highest values first
V = X_train*U;                            % project
for i=1:size(U,2);
    V(:,i) = V(:,i)/sqrt(sum(V(:,i).^2)); % normalize
end
V = V(:,1:largest_eig_keep);              % N eigenfaces

% visualize top eigenfaces (number 2)
for i = 1:9
   figure(1)
   subplot(3,3,i)
   imagesc(reshape(V(:,i),im_size)); colormap gray; axis off; axis image;
end

% (3) Project testing faces to Eigenspace
X_test = zeros(im_size(1)*im_size(2), NUM_IM);
k=1;
for i = 1:NUM_IM
    image = im{i}(:);
    image = (image - mean(image)) / std(image);
    X_test(:,k) = image;
    k = k + 1;
end
X_test = X_test - repmat(mu, [1, NUM_IM]);
X_test = V'*X_test;
X_train = X_test(:,subset == 1 | subset == 5);

% (4) Classify by nearest neighbor L2 norm for subsets 1-5
matches = zeros(NUM_IM,2);
matches(:,1) = person';
for i = 1:NUM_IM
    dist_min = inf;
    for j = 1:NUM_TRAINING_IM
        dist = abs(norm(X_test(:,i) - X_train(:,j)));
        if dist < dist_min
            dist_min = dist;
            training_order = find(subset == 1 | subset == 5 );%  | subset == 5 
            matches(i,2) = person(training_order(j)); 
        end
    end
end

% visualize face reconstruction for report (number 3)
reconstruct_images = [1 8 20 32 46];
for i = 1:length(reconstruct_images)
    figure(2)
    subplot(2,5,i)
    X_project(:,i) = mu + V*X_test(:,reconstruct_images(i));
    imagesc(reshape(X_project(:,i),im_size)); colormap gray; axis off; axis image;
    subplot(2,5,i+5)
    imagesc(im{reconstruct_images(i)}); colormap gray; axis off; axis image;
end

% error of classification (number 1) TODO 
for i = 1:5
    imgs = find(subset == i);
    matchesconfirmed = find(matches(imgs,1) == matches(imgs,2));
    err(i) = 1 - length(matchesconfirmed)/length(imgs);
end


