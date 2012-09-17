// https://github.com/davidchambers/Base64.js/blob/master/base64.js
;(function () {

  var
    object = self,
    chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=',
    INVALID_CHARACTER_ERR = (function () {
      // fabricate a suitable error object
      try { document.createElement('$'); }
      catch (error) { return error; }}());

  // encoder
  // [https://gist.github.com/999166] by [https://github.com/nignag]
  object.btoa || (
  object.btoa = function (input) {
    for (
      // initialize result and counter
      var block, charCode, idx = 0, map = chars, output = '';
      // if the next input index does not exist:
      //   change the mapping table to "="
      //   check if d has no fractional digits
      input.charAt(idx | 0) || (map = '=', idx % 1);
      // "8 - idx % 1 * 8" generates the sequence 2, 4, 6, 8
      output += map.charAt(63 & block >> 8 - idx % 1 * 8)
    ) {
      charCode = input.charCodeAt(idx += 3/4);
      if (charCode > 0xFF) throw INVALID_CHARACTER_ERR;
      block = block << 8 | charCode;
    }
    return output;
  });

}());

var encodeData = function(data) {
	var strData = "";
	if (typeof data === "string") {
		strData = data;
	} else {
		strData = String.fromCharCode.apply(null, data);
	}
	return base64.btoa(strData);
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
	self.postMessage({
		src: createBMP(e.data.width, e.data.height, e.data.data),
		key: e.data.key
	});
};