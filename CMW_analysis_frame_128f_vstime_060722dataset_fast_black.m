    clear all;
    clc;

%128 steppings 128->128 65->65
%mask right nor not  
%it seems that i cannot catch the signal not that the mask is not right and
%it is not the drifting that matters 
    
    fileDirectory = 'G:\Working station data\071221 oviduct OCT\800nm_071221_oviduct_ampulla_1000x10000_0.2x0.1_7us_10ms\';

    fileName1='image_';
    fileName2 = '.tiff';
    Vol(1:512,1:1000,1:128) = 0;
    
    startnum=0;
    endnum=9000;
    
    mkdir(strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_128f_result_2std\threshold55_2to15\pure_freq'));
    mkdir(strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_128f_result_2std\threshold55_2to15\hist'));
    mkdir(strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_128f_result_2std\threshold55_2to15\complete_freq'));
    mkdir(strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_128f_result_2std\threshold55_2to15\complete_phase'));
    mkdir(strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_128f_result_2std\threshold55_2to15\pure_phase_gray'));
   
    
 for bas_num=startnum:endnum
    %progressbar(j/100);
    for fileNumber = 1:128
        frameNumber = fileNumber+bas_num;
        dataRaw = imread(strcat(fileDirectory,fileName1, num2str(frameNumber,'%06g'),fileName2));
        
        Vol(:,:,fileNumber) = dataRaw(1:512,:);
        
        %img = mat2gray(dataSelected);
        %imwrite(img,strcat(num2str(fileNumber),'.png'));

    end
    
    avg=mean(Vol,3);
    imageThreshold = 55;
    zeroIndice = avg < imageThreshold;
    avg(zeroIndice) = 0;
    binaryImage = avg;
    oneIndice = avg >= imageThreshold ;
    binaryImage(oneIndice)=1;
    figure(2);
    imshow(binaryImage);

    Fs = 100;  % Sampling frequency                    
    T = 1/Fs;  % Sampling period                   
    L = 128;   % Length of signal                  
    t = (0:L-1)*T;   % Time vector

    NFFT = 128;
    f = Fs/2*linspace(0,1,NFFT/2+1);
    timeProfile(1:512,1:1000,1:128) = 0;
    
    %figure(3);
    %hold on
    uppersignal= ceil(15*L/Fs);
    lowersignal= ceil(2*L/Fs);
    uppernoise= ceil(35*L/Fs);
    lowernoise= ceil(30*L/Fs);
    
    
    spectralImage2D(1:512,1:1000) = 0;
    thresholdMatrix(1:512,1:1000) = 0;
    phasevol(1:512,1:1000,1:65)=0;                          
                      
            
            timeProfile(:,:,:) = Vol(:,:,1:128);
            timeProfileNoDC = timeProfile- mean(timeProfile,3);
            frequencyProfile =  fft(timeProfileNoDC,NFFT,3);
           
            phasevol(:,:,1:65)= frequencyProfile(:,:,1:65);
                        
            frequencyAmplitudeProfile = (2*abs(frequencyProfile(:,:,1:NFFT/2+1)));
                     
            spectralImage2D(:,:)=max(frequencyAmplitudeProfile(:,:,lowersignal:uppersignal),[],3).*binaryImage(:,:);
            thresholdMatrix(:,:)=binaryImage(:,:).*max(frequencyAmplitudeProfile(:,:,lowernoise:uppernoise),[],3);

   

    thresholdVector = reshape(thresholdMatrix,[512*1000 1]);
    thresholdAmplitude = mean(thresholdVector(thresholdVector~=0))+ 2*std(thresholdVector(thresholdVector~=0)); 
    
    spectralImage2D(spectralImage2D<=thresholdAmplitude) = 0;
    filteredSpectralImage2D = medfilt2(spectralImage2D, [4 4]);
   
    
    %imwrite (mat2gray(filteredSpectralImage2D),strcat(fileDirectory,'result_2std_3to10\','Amp',num2str(bas_num),'.tif'));
    
    imageThreshold = 0;
    zeroIndice = find(filteredSpectralImage2D <= imageThreshold);
    binaryImage(zeroIndice) = 0;
    
    oneIndice = find(filteredSpectralImage2D > imageThreshold );
    binaryImage(oneIndice)=1;
    
    
    
    frequencyImage(1:512,1:1000) = 0;
   
    tarRegion(1:uppersignal-lowersignal+1) = 0;
    

    for o = 1:1000
        for q = 1:512
            if binaryImage(q,o) == 1
               tarRegion(:) =  frequencyAmplitudeProfile(q,o,lowersignal:uppersignal);
              
               P = find(tarRegion == max(tarRegion));
               frequencyImage(q,o) = (P(1)+lowersignal-1)*Fs/L;
            else   
               frequencyImage(q,o) = 0;
          
            end    
        end
    end
    
    uniquenumber=unique(reshape(frequencyImage,[512*1000 1]));
    %imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),hot(128)),strcat(fileDirectory,'result_2std\','res',num2str(bas_num),'.tif'));
    orgimg1=ind2rgb(im2uint8(mat2gray(frequencyImage)),parula);
    redChannel1 = uint8(orgimg1(:, :, 1)*256);
    greenChannel1 = uint8(orgimg1(:, :, 2)*256);
    blueChannel1 = uint8(orgimg1(:, :, 3)*256);
    backgroundpixel = redChannel1 == 62 & greenChannel1  == 39 & blueChannel1  == 169;
    redChannel1(backgroundpixel) = 0;
    greenChannel1(backgroundpixel) = 0;
    blueChannel1(backgroundpixel) = 0;
    outputimg1 = cat(3, redChannel1, greenChannel1, blueChannel1);
    imwrite (outputimg1,strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_128f_result_2std\threshold55_2to15\pure_freq\',fileName1,'pure_freq',num2str(bas_num),'.tif'));
    
    
    hFig=figure;
    imagesc(frequencyImage);
    colorbar;
    [cdata,colorMap]=getframe(hFig);
    redChannel = cdata(:, :, 1);
    greenChannel = cdata(:, :, 2);
    blueChannel = cdata(:, :, 3);
    backgroundpixel = redChannel == 61 & greenChannel  == 38 & blueChannel  == 168;
    redChannel(backgroundpixel) = 0;
    greenChannel(backgroundpixel) = 0;
    blueChannel(backgroundpixel) = 0;
    outputimg2 = cat(3, redChannel, greenChannel, blueChannel);
    imwrite(outputimg2,strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_128f_result_2std\threshold55_2to15\complete_freq\','complete',num2str(bas_num),'.tif'));
    close(hFig);
    
    
    
    %{
    for t=2:size(uniquenumber)
      
        location = find(frequencyImage ~= uniquenumber(t));
        replace=filteredSpectralImage2D;
        replace(location)=0;
        mkdir(strcat(fileDirectory,'result_2std\spectralImage\freq',num2str(uniquenumber(t))));
        imwrite (mat2gray(replace),strcat(fileDirectory,'result_2std\spectralImage\freq',num2str(uniquenumber(t)),'\Amplitude',num2str(bas_num),'.tif'));
       
    end 
    %}
    
    f=figure;
    stretchfreq=reshape(frequencyImage,[512*1000 1]);
    stretchfreq=stretchfreq(stretchfreq~=0);
    hist(stretchfreq,unique(stretchfreq));
    saveas(f, strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_128f_result_2std\threshold55_2to15\hist\',fileName1,'hist',num2str(bas_num),'.tif'));
    close(f);
    
    
    
    for t=2:size(uniquenumber)
        mkdir(strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_128f_result_2std\threshold55_2to15_',num2str(uniquenumber(t)),'Hz'));
        Indice = find(frequencyImage ~= uniquenumber(t));
        
                temp = angle(phasevol(:,:,:));
                phaseImage2D(:,:)=(temp(:,:,round(3*NFFT/Fs)+1)+3.14).*binaryImage(:,:);
                   
    
        phaseImage2D(Indice)=0;
        imwrite (ind2rgb(im2uint8(mat2gray(phaseImage2D)),parula),strcat(fileDirectory,num2str(startnum),'to',num2str(endnum),'_128f_result_2std\threshold55_2to15_',num2str(uniquenumber(t)),'Hz\',fileName1,'pure_phase_at_freq',num2str(uniquenumber(t)),'Hz',num2str(bas_num),'.tif'));
        
        %{
        hFig=figure;
        imagesc(phaseImage2D);
        colorbar;
        [cdata,colorMap]=getframe(hFig);
        imwrite(cdata,strcat(fileDirectory,'128f_result_2std\threshold55_2to15\complete_phase\',num2str(bas_num),'_',num2str(uniquenumber(t)),'.tif'));
        close(hFig);
        
        imwrite(mat2gray(phaseImage2D),strcat(fileDirectory,'128f_result_2std\threshold55_2to15\pure_phase_gray\',num2str(bas_num),'_',num2str(uniquenumber(t)),'.tif'));
        %}
    end
 end 
    %imwrite (ind2rgb(im2uint8(mat2gray(frequencyImage)),parula(128)),strcat(fileDirectory,'result_3\','res',num2str(bas_num),'.tif'));
    %copyfile(strcat(fileDirectory,num2str(bas_num),fileName),strcat(fileDirectory,'result_70656'));
    %dlmwrite(strcat(fileDirectory,num2str(i),'.txt'),frequencyImage);
    
    %figure(4); %imshow(frequencyImage,[]);
    %imagesc(frequencyImage)
    
    
    %title(strcat('frequency map for',num2str(i*512+24257)))
    %colorbar;
    

