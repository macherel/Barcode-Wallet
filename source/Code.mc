import Toybox.Application;
import Toybox.Lang;
import Toybox.System;

class Code {
	var id;
	var version;
	var label;
	var value;
	var data as Array<String>;
	var height;
	var width;

	function initialize(id, version, label, value, width, height, data as Array<String>?) {
		self.id = id;
		if(version == null) {
			self.version = 1;
		} else {
			self.version = version.toNumber();
		}
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

	function fromResponseData(id, data as Dictionary) {
		return new Code(
			id,
			data["version"],
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
			+ ", version=" + self.version
			+ ", label=" + self.label
			+ ", value=" + self.value
			+ ", width=" + self.width
			+ ", height="+ self.height
			+ ", data="  + self.data
			+ ")";
	}

}
