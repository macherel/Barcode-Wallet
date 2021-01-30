using Toybox.Application as App;

class Code {
	var id;
	var label;
	var value;
	var data;

	function initialize(id, label, value, data) {
		self.id = id;
		if(label == null) {
			self.label = "";
		} else {
			self.label = label;
		}
		self.value = value;
		self.data = data;
	}

	function fromResponseData(id, data) {
		return new Code(
			id,
			data["name"],
			data["value"],
			data["encodedData"]
		);
	}
	
	function toString() {
		return "Code("
			+ "id=" + self.id
			+ ", label=" + self.label
			+ ", value=" + self.value
			+ ", data=" + self.data
			+ ")";
	}

}
