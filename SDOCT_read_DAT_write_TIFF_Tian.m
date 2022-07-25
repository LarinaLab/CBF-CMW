clear;close all force;clc;

b_scan_width = 350;
show_images = 0; % 0 - show images; 1 - don't show images

start_path = 'E:\800nm OCT computer data\011422\800nm_011422_oviduct_infun_1000x20000_1x0.2_7us_10ms';
pathname = uigetdir(start_path,'Select directory with the DAT files');
disp(['Processing ',pathname]);
filename = dir(fullfile(pathname,'*.dat'));
loops = round(length(filename));

spec_filename = dir(fullfile(pathname,'*.spectrum'));
spectrum = (load(fullfile(pathname,spec_filename(1).name)));
spec_len = length(spectrum);
k_space = 2*pi./spectrum;(spec_len))/(spec_len-1);
hann_rep_mat = ((repmat(hann(spec_len),[1,b_scan_width])))
new_ks = k_space(1) -(0:spec_len-1)*(k_space(1)-k_space;

savingpath='E:\800nm OCT computer data\011422\800nm_011422_oviduct_infun_1000x20000_1x0.2_7us_10ms';
mkdir(savingpath,'images');

if show_images == 1
    for counter = 1:loops
        clear image fid raw_fringes linear_k_fringes fft_1;
        fid = fopen(fullfile(pathname,filename(counter).name));
        raw_fringes = fread(fid,[spec_len,b_scan_width],'uint8',0,'b');
        fclose(fid);
        linear_k_fringes = interp1(k_space,raw_fringes,new_ks,'linear');
        fft_1 = fft(bsxfun(@times,hann_rep_mat,linear_k_fringes),[],1);
        fft_1 = fft_1(1:spec_len/2,:);
        image = mat2gray(20*log10(abs(fft_1)),[0,100]);
        figure(1);
        imagesc(image);
        colormap(gray);
        caxis([.1,1]);
        title(['File ',num2str(counter),' of ',num2str(loops)]);
        
        imwrite(image,fullfile(pathname,'images',['image_',num2str(counter,'%06d'),'.tiff']),...
            'compression','lzw');
        pause(0.01);
    end
else
    for counter = 1:10:loops
        fid = fopen(fullfile(pathname,filename(counter).name));
        raw_fringes = fread(fid,[spec_len,b_scan_width],'uint8',0,'b');
        fclose(fid);
        linear_k_fringes = interp1(k_space,raw_fringes,new_ks,'linear');
        fft_1 = fft(bsxfun(@times,hann_rep_mat,linear_k_fringes),[],1);
        fft_1 = fft_1(1:spec_len/2,:);
        image = mat2gray(20*log10(abs(fft_1)),[0,100]);
        imwrite(image,fullfile(savingpath,'images',['image_',num2str(counter,'%06d'),'.tiff']),...
            'compression','lzw');
    end
end
close all force;
clc;
disp(pathname);