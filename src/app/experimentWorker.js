var base64 = {};
base64.PADCHAR = '=';
base64.ALPHA = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

base64.getbyte = function(s,i) {
    var x = s.charCodeAt(i) & 0xFF;
    return x;
}

base64.encode = function(s) {
    var padchar = base64.PADCHAR;
    var alpha   = base64.ALPHA;
    var getbyte = base64.getbyte;

    var i, b10;
    var x = [];

    // convert to string
    s = '' + s;

    var imax = s.length - s.length % 3;

    if (s.length === 0) {
        return s;
    }
    for (i = 0; i < imax; i += 3) {
        b10 = (getbyte(s,i) << 16) | (getbyte(s,i+1) << 8) | getbyte(s,i+2);
        x.push(alpha.charAt(b10 >> 18));
        x.push(alpha.charAt((b10 >> 12) & 0x3F));
        x.push(alpha.charAt((b10 >> 6) & 0x3f));
        x.push(alpha.charAt(b10 & 0x3f));
    }
    switch (s.length - imax) {
    case 1:
        b10 = getbyte(s,i) << 16;
        x.push(alpha.charAt(b10 >> 18) + alpha.charAt((b10 >> 12) & 0x3F) +
               padchar + padchar);
        break;
    case 2:
        b10 = (getbyte(s,i) << 16) | (getbyte(s,i+1) << 8);
        x.push(alpha.charAt(b10 >> 18) + alpha.charAt((b10 >> 12) & 0x3F) +
               alpha.charAt((b10 >> 6) & 0x3f) + padchar);
        break;
    }
    return x.join('');
}

var toBase64 = base64.encode;//(undefined === btoa) ? base64.encode : btoa;

var encodeData = function(data) {
	var strData = "";
	if (typeof data === "string") {
		strData = data;
	} else {
		strData = String.fromCharCode.apply(null, data);
	}
	return toBase64(strData);
};

// Adapted from http://www.nihilogic.dk/labs/canvas2image/canvas2image.js - sped up a fair bit
var createBMP = function(width, height, data) {
	var aHeader = [];

	var iWidth = width;
	var iHeight = height;

	aHeader.push(0x42); // magic 1
	aHeader.push(0x4D); 

	var iFileSize = iWidth*iHeight*3 + 54; // total header size = 54 bytes
	aHeader.push(iFileSize & 0xff); iFileSize = (iFileSize >> 8);
	aHeader.push(iFileSize & 0xff); iFileSize = (iFileSize >> 8);
	aHeader.push(iFileSize & 0xff); iFileSize = (iFileSize >> 8);
	aHeader.push(iFileSize & 0xff);

	aHeader.push(0); // reserved
	aHeader.push(0);
	aHeader.push(0); // reserved
	aHeader.push(0);

	aHeader.push(54); // dataoffset
	aHeader.push(0);
	aHeader.push(0);
	aHeader.push(0);

	var aInfoHeader = [];
	aInfoHeader.push(40); // info header size
	aInfoHeader.push(0);
	aInfoHeader.push(0);
	aInfoHeader.push(0);

	var iImageWidth = iWidth;
	aInfoHeader.push(iImageWidth & 0xff); iImageWidth = (iImageWidth >> 8);
	aInfoHeader.push(iImageWidth & 0xff); iImageWidth = (iImageWidth >> 8);
	aInfoHeader.push(iImageWidth & 0xff); iImageWidth = (iImageWidth >> 8);
	aInfoHeader.push(iImageWidth & 0xff);

	var iImageHeight = iHeight;
	aInfoHeader.push(iImageHeight & 0xff); iImageHeight = (iImageHeight >> 8);
	aInfoHeader.push(iImageHeight & 0xff); iImageHeight = (iImageHeight >> 8);
	aInfoHeader.push(iImageHeight & 0xff); iImageHeight = (iImageHeight >> 8);
	aInfoHeader.push(iImageHeight & 0xff);

	aInfoHeader.push(1); // num of planes
	aInfoHeader.push(0);

	aInfoHeader.push(24); // num of bits per pixel
	aInfoHeader.push(0);

	aInfoHeader.push(0); // compression = none
	aInfoHeader.push(0);
	aInfoHeader.push(0);
	aInfoHeader.push(0);

	var iDataSize = iWidth*iHeight*3; 
	aInfoHeader.push(iDataSize & 0xff); iDataSize = (iDataSize >> 8);
	aInfoHeader.push(iDataSize & 0xff); iDataSize = (iDataSize >> 8);
	aInfoHeader.push(iDataSize & 0xff); iDataSize = (iDataSize >> 8);
	aInfoHeader.push(iDataSize & 0xff); 

	for (var i=0;i<16;i++) {
		aInfoHeader.push(0);	// these bytes not used
	}

	var iPadding = (4 - ((iWidth * 3) % 4)) % 4;
	var strPadding = iPadding == 0 ? "" : new Array(iPadding).join(String.fromCharCode(0));

	var aImgData = data;

	var aPixelData = [];
	var aPixelRow = new Array(iWidth + 1);
	var y = iHeight;
	do {
		var iOffsetY = iWidth*(y-1)*4;
		var poke = 0;
		for (var x=0;x<iWidth;x++) {
			var iOffsetX = 4*x;

			aPixelRow[poke++] = String.fromCharCode(aImgData[iOffsetY+iOffsetX+2]);
			aPixelRow[poke++] = String.fromCharCode(aImgData[iOffsetY+iOffsetX+1]);
			aPixelRow[poke++] = String.fromCharCode(aImgData[iOffsetY+iOffsetX]);
		}
		aPixelRow[poke++] = strPadding;
		aPixelData.push(aPixelRow.join(""));
	} while (--y);

	var strEncoded = "data:image/bmp;base64," + encodeData(aHeader.concat(aInfoHeader)) + encodeData(aPixelData.join(""));

	return strEncoded;
};

self.onmessage = function(e) {
	self.postMessage(createBMP(e.data.width, e.data.height, e.data.data));
};