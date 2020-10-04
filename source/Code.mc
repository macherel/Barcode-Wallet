using Toybox.Application as App;

class Code {
	var id;
	var label;
	var data;

	function initialize(id, label, data) {
		self.id = id;
		self.label = label;
		self.data = data;
	}

	function fromResponseData(id, data) {
		return new Code(
			id,
			data["name"],
			data["encodedData"]
		);
	}
	
	function toString() {
		return "Code("
			+ "id=" + self.id
			+ ", label=" + self.label
			+ ", data=" + self.data
			+ ")";
	}

}
