name='bimodal.png'
raw=double(imread(name));
rawgray=raw(:,:,1);
smoothgray=imgaussfilt(rawgray,70);
figure()
surf(rawgray,'edgecolor','none')
figure()
surf(smoothgray,'edgecolor','none')
imwrite(uint16(smoothgray*255),['green' name '.tiff']);
testIN=imread(['green' name]);
figure()
surf(testIN,'edgecolor','none')