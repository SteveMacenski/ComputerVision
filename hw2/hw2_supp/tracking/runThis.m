%Steve Macenski (c) 2017

%%
%Hw2 problem 1.1: keypoint selection

    %open image and get key points
im = imread('./images/hotel.seq0.png');
tau = 250000;
[Xkey, Ykey] = getKeyPoints(im, tau);
num_keypoints = length(Xkey);

    % display results
figure(1)
imshow(im);
hold on;
plot(Xkey,Ykey, 'g.', 'linewidth',3);
title('Steve Macenski Harris Feature Detector 1.1')


%%
%Hw2 problem 1.2: tracking

    %for each image, find file path
num_im = 50;
images = 0:1:num_im;
im_loc = './images/hotel.seq';
image_files = {};
for i=1:num_im+1
    image_files{i} = [im_loc, num2str(images(i)), '.png'];
end

%starting with keys in image 0
startXs = Xkey; startYs = Ykey;
trackingXs(:,1) = Xkey; trackingYs(:,1) = Ykey;

for j = 1:num_im
    
    %read in images
    im0 = double(imread(image_files{j}));
    im1 = double(imread(image_files{j+1}));

    [newXs, newYs] = predictTranslationAll( startXs, startYs, im0, im1 );
    
    % update starting point for next frame
    startXs = newXs; startYs = newYs; 
    
    % save keypoints over time
    trackingXs(:,j+1) = newXs; trackingYs(:,j+1) = newYs;
end
%%
                            % display ALL results for visualization
%                         figure(2)
%                         imshow(im);
%                         hold on;
%                         plot(trackingXs,trackingYs, 'g.', 'linewidth',3);
%                         title('Steve Macenski Kanade-Lucas-Tomasi Tracker 1.2')
%                         
%                         points_out_of_boundsX = [];
%                         points_out_of_boundsY = [];
%                         points_in_boundX = [];
%                         points_in_boundY = [];
%%
%find what points are in and out of bounds
n=1;m=1;
for i=1:num_keypoints
   if length(find(trackingXs(i,:) == 0)) >= 2 || length(find(trackingYs(i,:) == 0)) >= 2
      points_out_of_boundsX(n,:) = trackingXs(i,:); 
      points_out_of_boundsY(n,:) = trackingYs(i,:); 
      n=n+1;
   else
      points_in_boundX(m,:) = trackingXs(i,:); 
      points_in_boundY(m,:) = trackingYs(i,:); 
      m=m+1;
   end
end

% find 20 evenly distributed points to track that were in bounds
step_size = length(points_in_boundX)/20;
step_size = floor(step_size);
for i = 1:20
    points_in_bound_plotX(i,:) = points_in_boundX(step_size*i,:);
    points_in_bound_plotY(i,:) = points_in_boundY(step_size*i,:);
end
%%
    % display requested output 1 
figure(3)
imshow(im);
hold on;
plot(points_in_bound_plotX,points_in_bound_plotY, 'g.', 'linewidth',3);
title('Steve Macenski Kanade-Lucas-Tomasi Tracker 20 keypoints 1.2')

    % display requested output 2
figure(4)
imshow(im);
hold on;
plot(points_out_of_boundsX,points_out_of_boundsY, 'g.', 'linewidth',3);
title('Steve Macenski Kanade-Lucas-Tomasi Tracker out of frame 1.2')

%%