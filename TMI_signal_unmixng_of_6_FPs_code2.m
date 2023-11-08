
clear
clc
load('41matlab3.mat')

imageWidth = 1566;
imageHeight = 1200;
imageFrames = 41;
stack = zeros(imageWidth,imageHeight,imageFrames);

for ii = 1:imageFrames
    currentImage = imread('mfRFPs.tif', ii);
    stack(:,:,ii) = currentImage;
end

composition_image1 = zeros(imageWidth,imageHeight);
composition_image2 = zeros(imageWidth,imageHeight);
status_indicator   = zeros(imageWidth,imageHeight) - 10;

options = optimoptions('fmincon', 'Display', 'none');

parfor ii = 1:imageWidth
    for jj = 1:imageHeight
        if stack(ii,jj,1) < 10
	    % ignore background pixels for faster computation
            composition_image1(ii,jj) = 0;
            composition_image2(ii,jj) = 0;

        else
            [predicted_vals, ~, exitflag, ~] = fmincon(@(coeffs) signalseparation6G_fmincon(mCardinal, mfRFP_A, squeeze(stack(ii,jj,:)), coeffs), ... % obj. fun.
                                        [0 0], ... % initial guess
                                        [], [], ... % inequalities (N/A)
                                        [1,1], ... % equality constraint left hand side
                                        1, ... % equality constraint right hand side -- this ensures they add up to 1
                                        [0,0], ... % lower bounds
                                        [1,1], ... % upper bounds
                                        [], ... % nonlinear options (N/A)
                                        options); % see options variable above --  currently only disables print output
              composition_image1(ii,jj) = predicted_vals(1);
              composition_image2(ii,jj) = predicted_vals(2);
             
              status_indicator(ii, jj)  = exitflag; % we need this value to know if the optimization succeeded
        end
    end
disp(['Done with ' num2str(ii) ' of ' num2str(imageHeight)]);      
end

% Clip the values so that they are all between 0 and 1 inclusive.
% This is technically not necessary for this approach, but we do it anyway
% just to be safe.
composition_image1(composition_image1 <0) = 0;
composition_image1(composition_image1 >1) = 1;
composition_image2(composition_image2 <0) = 0;
composition_image2(composition_image2 >1) = 1;


% Multiply the values with the first frame in the stack
% to compute intensities for each channel.
% Because we strictly defined the values to add up to 1 using
% the MATLAB optimization options and specifying an equality constraint,
% these channels also add up to exactly the original video.
mCardinal_ch = composition_image1.*stack(:,:,1); % mfRFP 
mfRFP_A_ch = composition_image2.*stack(:,:,1); % mfRFPA

% Save resulting new images in the working directory.
imwrite(uint16(mCardinal_ch), 'mCardinal_ch-code2.tif'); % mfRFP
imwrite(uint16(mfRFP_A_ch), 'mfRFPA_ch-code2.tif'); % mfRFPA

