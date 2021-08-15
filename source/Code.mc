using Toybox.Application as App;
using Toybox.System as System;

class Code {
	var id;
	var label;
	var value;
	var data;
	var height;
	var width;

	function initialize(id, label, value, width, height, data) {
		self.id = id;
		if(label == null) {
			self.label = "";
		} else {
			self.label = label;
		}
		self.value = value;
		if(width == null) {
			self.width = data[0].length();
		} else {
			self.width = width;
		}
		if(height == null) {
			self.height = data.size() * 4;
		} else {
			self.height = height;
		}
		self.data = data;
	}

	function fromResponseData(id, data) {
		return new Code(
			id,
			data["name"],
			data["value"],
			data["width"],
			data["height"],
			data["encodedData"]
		);
	}
	
	function toString() {
		return "Code("
			+ "id=" + self.id
			+ ", label=" + self.label
			+ ", value=" + self.value
			+ ", width=" + self.width
			+ ", height="+ self.height
			+ ", data="  + self.data
			+ ")";
	}

}
