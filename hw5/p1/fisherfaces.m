% Steve Macenski (c) 2017
% face detection with fisherfaces

faces_path = './faces/';
NUM_PEOPLE = 10;
NUM_IM_PER_PERSON = 64;
NUM_IM = NUM_PEOPLE*NUM_IM_PER_PERSON;
C = 31; %31

[im, person, number, subset] = readFaceImages(faces_path);
im_size = size(im{1,1}); %50x50

% (1) for each training image from subset 1: (im-mean)/std then resize to 2500xNUM_IM
training_im = im(subset == 1| subset == 5); %| subset == 5
NUM_TRAINING_IM = size(training_im,2);

X_test = zeros(im_size(1)*im_size(2), NUM_IM);
k=1;
for i = 1:NUM_IM
    image = im{i}(:);
    image = (image - mean(image)) / std(image);
    X_test(:,k) = image;
    k = k + 1;
end

% (2) Seperate the training and testing sets
X_train = X_test(:,subset==1| subset == 5); %|subset==5
IM_OF_PERSON_TRAINING = size(X_train,2) / NUM_PEOPLE;

% (3) Do FLD 
Mu_ = zeros(size(X_train,1));

for i = 1:NUM_PEOPLE
    starting = (i-1) * IM_OF_PERSON_TRAINING + 1;
    ending = i * IM_OF_PERSON_TRAINING;
    Mu_(:,i) = mean(X_train(:,starting:ending),2);
end
Mu = mean(Mu_,2);

[U,Lambda] = eig(X_train'*X_train);
U = fliplr(U);                            % reorder highest values first
V = X_train*U;                            % project
max_components = size(V,2) - C;           % FLD components to keep
V = V(:,1:max_components);                % N eigen components

S_i = zeros(size(X_train,1),size(X_train,1),NUM_PEOPLE);
S_w = zeros(size(X_train,1),size(X_train,1));
S_b = zeros(size(X_train,1),size(X_train,1));

for i = 1:NUM_PEOPLE
    X_Train_person = X_train(:  ,  (i-1)*IM_OF_PERSON_TRAINING + 1  :  i*IM_OF_PERSON_TRAINING);
    for j=1:IM_OF_PERSON_TRAINING
        S_i(:,:,i) = S_i(:,:,i) + (X_Train_person(:,j)-Mu(i)) * (X_Train_person(:,j)-Mu(i))';
    end
end

for i = 1:NUM_PEOPLE
    S_w = S_w + S_i(:,:,i);
    S_b = S_b + NUM_TRAINING_IM * ((Mu_(:,i) - Mu(i)) * (Mu_(:,i) - Mu(i))');
end

S_b = V'*S_b*V;
S_w = V'*S_w*V;

[U,Lambda] = eig(S_b,S_w);
[val,order] = sort( diag(Lambda) , 'descend' ); %sort since eig(A,B) is unordered
U = U(:,order);
Wopt = V*U;

for i=1:size(Wopt,2);
    Wopt(:,i) = Wopt(:,i)/sqrt(sum(Wopt(:,i).^2)); % normalize
end
V = Wopt(:,1:(C-1)); % set map to V to reuse code from eigenfaces below

% (4) Normalize by mean face and project onto Face-Space
mu = mean(X_train,2);
X_test = X_test - repmat(mu, [1, NUM_IM]);
X_test = V'*X_test;
X_train = X_train - repmat(mu, [1,NUM_TRAINING_IM]);
X_train = V'*X_train;

% (5) find matches
matches = zeros(NUM_IM,2);
matches(:,1) = person';
for i = 1:NUM_IM
    dist_min = inf;
    for j = 1:NUM_TRAINING_IM
        dist = abs(norm(X_test(:,i) - X_train(:,j)));
        if dist < dist_min
            dist_min = dist;
            training_order = find(subset == 1| subset == 5); %|subset==5
            matches(i,2) = person(training_order(j)); 
        end
    end
end

% (6) error of classification
for i = 1:5
    imgs = find(subset == i);
    matchesconfirmed = find(matches(imgs,1) == matches(imgs,2));
    errFisher(i) = 1 - length(matchesconfirmed)/length(imgs);
end
errFisher