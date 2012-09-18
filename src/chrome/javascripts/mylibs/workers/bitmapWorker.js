// https://gist.github.com/2661137
var base64 = {};
base64.PADCHAR = '=';
base64.ALPHA = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';


base64.getbyte = function(s,i) {
    return s.charCodeAt(i);
};

base64.encode = function(s) {
    if (arguments.length !== 1) {
        throw new SyntaxError("Not enough arguments");
    }
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
};

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

var pushInt32 = function(array, value) {
	array.push(value & 0xff); value = (value >> 8);
	array.push(value & 0xff); value = (value >> 8);
	array.push(value & 0xff); value = (value >> 8);
	array.push(value & 0xff);
};

var getBMPHeader = function(width, height) {
	var header = [];
	var infoHeader = [];
	var fileSize = width*height*3 + 54; // total header size = 54 bytes

	header.push(0x42); // magic 1
	header.push(0x4D); 

	pushInt32(header, fileSize);

	header.push(0); // reserved
	header.push(0);
	header.push(0); // reserved
	header.push(0);

	header.push(54); // dataoffset
	header.push(0);
	header.push(0);
	header.push(0);

	infoHeader.push(40); // info header size
	infoHeader.push(0);
	infoHeader.push(0);
	infoHeader.push(0);

	pushInt32(infoHeader, width);
	pushInt32(infoHeader, height);

	infoHeader.push(1); // num of planes
	infoHeader.push(0);

	infoHeader.push(24); // num of bits per pixel
	infoHeader.push(0);

	infoHeader.push(0); // compression = none
	infoHeader.push(0);
	infoHeader.push(0);
	infoHeader.push(0);

	pushInt32(infoHeader, width*height*3);

	for (var i=0;i<16;i++) {
		infoHeader.push(0);	// these bytes not used
	}

	return header.concat(infoHeader);
};

var headers = {};

// Adapted from http://www.nihilogic.dk/labs/canvas2image/canvas2image.js - sped up a fair bit
var createBMP = function(width, height, rawImageData) {
	var header = headers[width + " " + height] || (headers[width + " " + height] = encodeData(getBMPHeader(width, height)));

	var paddingLength = (4 - ((width * 3) % 4)) % 4;

	var pixelRows = [];
	var pixelRow = new Array(width + paddingLength);
	var i = pixelRow.length;
	while (i--) { pixelRow[i] = 0; }
	var y = height;
	var width4 = 4 * width;
	var offsetX, offsetY, poke;

	do {
		offsetY = width4*(y-1);
		poke = 0;
		for (var offsetX=0;offsetX<width4;offsetX += 4) {
			pixelRow[poke++] = rawImageData[offsetY+offsetX+2];
			pixelRow[poke++] = rawImageData[offsetY+offsetX+1];
			pixelRow[poke++] = rawImageData[offsetY+offsetX];
		}
		pixelRows.push(String.fromCharCode.apply(null, pixelRow));
	} while (--y);

	return "data:image/bmp;base64," + header + encodeData(pixelRows.join(""));
};

self.onmessage = function(e) {
	var startTime = Date.now();
	self.postMessage({
		src: createBMP(e.data.width, e.data.height, e.data.data),
		key: e.data.key,
		latency: Date.now() - startTime
	});
};