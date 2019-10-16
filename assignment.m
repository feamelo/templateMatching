%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Test Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                        %
% Autora: Fernanda Amaral Melo                                           %
% Contato: fernanda.amaral.melo@gmail.com                                %
%                                                                        %
% Script usado para detecção de um template de avião em                  %
% uma foto aérea de aeroporto                                            %
%                                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
clc;

%% Average filter
% Corrupted by Gaussian noise
k=1; % Y (Iluminance)

addpath('Images');
original_img = rgb2ycbcr(imread(sprintf('%d.bmp',1)));
avrg_filt = original_img;
soma = zeros(720);

% Sum the correspondent pixels of all images
for n=1:100
    picture = rgb2ycbcr(imread(sprintf('%d.bmp',n)));
    soma = soma + double(picture(:,:,k));
end

% Take the median value to remove statistical noise
soma = soma./100;
avrg_filt(:,:,1) = uint8(soma);
[h, x, k] = size(original_img);

%% Notch Filter
% Texture caused by the presence of an unwanted frequency components
k=3; % Cr (chrominances)

plota=0; % Set plota variable to see the image on frequency domain
mult=144; % The noise dots on frequency are equally spaced by 144 pixels
radius=1; 

notch_filt=avrg_filt;
F = fftshift(fft2(avrg_filt(:,:,k))); % get fft
H = ones(h,x); % create filter

for i=1:4
    for j=1:4
        H(i*mult-radius:i*mult+radius, j*mult-radius:j*mult+radius) = 0;
        % Band-stop these pixels and its nearest neighbours
    end
end

F_new=F.*H; % Multiply original fft and the filter
notch_filt(:,:,k)=uint8(real(ifft2(fftshift(F_new)))); % Inverse FFT

if(plota)
    figure();
    subplot(1,2,1); title('Freq domain'); imshow(abs(F).^0.15,[])
    subplot(1,2,2); title('Notch filter'); imshow(abs(F_new).^0.15,[])
end

%% Median Filter
% Impulsive salt and pepper noise
k=2; % Cb

orig=notch_filt;
median_filt=notch_filt;

% Take a group of pixels arround the chosen one and sort its value
for i = 2:h-1
    for j = 2:x-1
        Bloco = orig(i-1:i+1, j-1:j+1, k);
        V = sort(Bloco(:));
        median_filt(i,j,k) = V(5);
    end
end

%% Plots of part 1

figure();
subplot(1,4,1); imshow(ycbcr2rgb(original_img)); title('Original')
subplot(1,4,2); imshow(ycbcr2rgb(avrg_filt)); title('Average Filter')
subplot(1,4,3); imshow(ycbcr2rgb(notch_filt)); title('Notch Filter')
subplot(1,4,4); imshow(ycbcr2rgb(median_filt)); title('Median Filter')

imwrite(ycbcr2rgb(median_filt), 'airport.png');

%% %%%%%%%%% Part 2: Finding the airplanes %%%%%%%%% %%

clear;
clc;
airport=double(rgb2gray(imread('airport.png')));

%% Rotate the planes

plane_template=rgb2gray(imread('plane.png'));
h=50; w=65; % Half of size that fits the airplane in all possible angles
planes=uint8(zeros(w*2,h*2,11));
figure();

for i=1:11
    rotate = imrotate(plane_template,-54+9*i);
    [x,y,k]=size(rotate); x=round(x/2); y=round(y/2);
    
    % Remove black borders from rotation img and save it on planes variable
    planes(:,:,i) = rotate(x-w : x+w-1 , y-h : y+h-1);
    subplot(3,4,i); imshow(planes(:,:,i)); title(-54+9*i);
end

planes=double(planes);

%% Cross correlation

tic
pic_size=size(airport);
h=100; w=130; % Template size

pic_padding = uint8(zeros(pic_size(1)+2*w-1, pic_size(1)+2*h-1));
pic_padding(w:size(pic_padding,1)-w , h:size(pic_padding,2)-h) = airport;
corr_norm=zeros(979,919,11);

for plane=1:11
    template = planes(:,:,plane) - squeeze(mean(mean(planes(:,:,plane))));    
    for x=1:pic_size(1)
        for y=1:pic_size(2)
            img = double(pic_padding(x:x+w-1 , y:y+h-1)) - squeeze(mean(mean(double(pic_padding(x:x+w-1 , y:y+h-1 )))));
            numerator = sum(sum(img.*template));
            denominator = sqrt( sum(sum(template.^2)) .* sum(sum(img.^2)) );
            corr_norm(x,y,plane) = numerator/denominator;
            
            % If the correlation is above a threshold, turn all pixels of
            % that interval to black so the same plane will not be
            % recognized twice
            if(corr_norm(x,y,plane) > 0.45) 
                pic_padding(x:x+w-1 , y:y+h-1)=0;
            end
        end
    end
end
toc
% save('correlacao.mat','corr_norm');

%% Plot of part 2

% The cross correlation calculation takes a long time
% but its reasults are saved and can be loaded with load_variables = true
load_variables = true; 
if(load_variables)
    load_ = matfile('correlacao.mat');
    corr_norm = load_.corr_norm; % Cross correlation 
    airport=double(rgb2gray(imread('airport.png'))); % Filtered img
    pic_size=size(airport); % Image size
    h=100; w=130; % Template size
end

figure();
imshow(uint8(airport));

for plane=1:11
    for x=1:pic_size(1)
        for y=1:pic_size(2)
            if(corr_norm(x,y,plane) > 0.45)
                hold on
                rectangle('Position', [y-h, x-w, h, w], 'EdgeColor', 'r' ,'LineWidth', 2);
            end
        end
    end
end
