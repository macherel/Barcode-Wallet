function getBit(bit, value) {
	return (value & Math.pow(2, bit)) >> bit;
}
function toPixels(size, value) {
 return new Array(size).fill()
	.map((v,i, arr) => new Array(size).fill()
		.map((v, j) => {
			if(i < (size/2) && j < (size/2)) {
				return getBit(3, value)*255
			}
			if(i < (size/2) && j >= (size/2)) {
				return getBit(2, value)*255
			}
			if(i >= (size/2) && j < (size/2)) {
				return getBit(1, value)*255
			}
			if(i >= (size/2) && j >= (size/2)) {
				return getBit(0, value)*255
			}
		})
	)
	.map((v,i, arr) => v
		.map((v, j) => {
			if(size%2==0) return v;
			if(i == Math.floor(size/2) && j != Math.floor(size/2)) {
				return Math.floor((arr[i-1][j] + arr[i+1][j]) / 2)
			}
			if(i != Math.floor(size/2) && j == Math.floor(size/2)) {
				return Math.floor((arr[i][j-1] + arr[i][j+1]) / 2)
			}
			return v
		})
	)
	.map((v,i, arr) => v
		.map((v, j) => {
			if(size%2==0) return v;
			if(i == Math.floor(size/2) && j == Math.floor(size/2)) {
				return Math.floor((arr[i][j-1] + arr[i][j+1] + arr[i-1][j] + arr[i+1][j]) / 4)
			}
			return v
		})
	)
	.map((v,i, arr) => v
		.map((v, j) => {
			return 255 - v;
		})
	)
}


function transpose(matrix) {
	return matrix[0].map((_, colIndex) => matrix.map(row => row[colIndex]));
}

function concat(matrixes) {
	return transpose(matrixes.flatMap(matrix => transpose(matrix)));
}
function downloadURI(uri, name) {
  var link = document.createElement("a");
  link.download = name;
  link.href = uri;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  delete link;
}

function downloadFontImage(size) {
	const n = 16;
	const start = 0
	const height=size;
	const width=n*size;
	const mimetype = 'image/png';
	const canvas = document.createElement('canvas');
	canvas.height=height;
	canvas.width=width;
	const context = canvas.getContext("2d");
	const imageData=context.createImageData(width, height);
	const data=imageData.data;
	concat(new Array(n).fill().map((v, i) => toPixels(size, i+start)))
		.forEach((v, i) =>
			v.forEach((v, j) => {
				data[4*(i*width+j)+0] = v;
				data[4*(i*width+j)+1] = v;
				data[4*(i*width+j)+2] = v;
				data[4*(i*width+j)+3] = 255;
			}
			)
		)
	context.putImageData(imageData, 0, 0); // at coords 0,0

	//document.getElementsByTagName('body')[0].appendChild(canvas);

	var dataUrl=canvas.toDataURL(mimetype);
	downloadURI(dataUrl, `qrcode2-${size}.png`)
}

function downloadFontFile(size) {
	const fontFileContent = [
		`info face="QR code" size="12" bold="0" italic="0" charset="" unicode="" stretchH="100" smooth="1" aa="1" padding="0,0,0,0" spacing="1,1" outline="0"`,
		`common lineHeight="${size}"  base="1" scaleW="16" scaleH="64" pages="1" packed="0"`,
		`page id="0" file="qrcode2-${size}.png"`,
		`chars count="16"`,
		[48,49,50,51,52,53,54,55,56,57,97,98,99,100,101,102].map((v,i) => `char id="${v}"  x="${i*size}"  y="0" width="${size}" height="${size}"  xoffset="0" yoffset="0" xadvance="${size}" page="0" chnl="0"`).join('\n'),
		''
	].join('\n');
	const dataUrl = encodeURI('data:text/fnt;charset=utf-8,' + fontFileContent);
	downloadURI(dataUrl, `qrcode2-${size}.fnt`)
}

window.addEventListener('load', () => {
	for(var i=2; i<=32; i++)
	{
		//downloadFontImage(i);
		downloadFontFile(i);
	}
});