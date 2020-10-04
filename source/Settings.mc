using Toybox.Application as App;
using Toybox.Application.Properties as Properties;
using Toybox.WatchUi as Ui;
using Toybox.System as System;

module Settings {

	var token;
	var displayLabel;
	var codes = null;
	var currentIndex = null;
	var state = :UNKNOWN;
	var responseCode = null;

	function getToken() {
		return _getProperty("token");
	}

	function hasToken() {
		return !isNullOrEmpty(getToken());
	}
	
	function setCurrentIndex(index) {
		currentIndex = index;
		_setProperty("currentIndex", index);
	}

	function load() {
		token = _getProperty("token");
		displayLabel = _getProperty("displayLabel");
		currentIndex = _getProperty("currentIndex");
		if(currentIndex == null) {
			currentIndex = 0;
		}
	}

	function loadCodes() {
		codes = [];
		var i = 0;
		var code = _loadCode(i);
		while (code != null) {
			codes.add(code);
			i++;
			code = _loadCode(i);
		}
	}
	
	function storeCodes(newCodes) {
		codes = newCodes;
		for(var i=0; i<codes.size(); i++) {
			_storeCode(codes[i]);
		}
	}

	function _storeCode(code) {
		if (App has :Storage) {
			App.Storage.setValue(
				"code#" + code.id,
				{
					:label => label,
					:data => data,
				}
			);
		} else {
			var app = App.getApp();
			app.setProperty("code#" + id + "-label", code.label);
			app.setProperty("code#" + id + "-data", code.data);
		}
	}

	function _loadCode(id) {
		var label = null;
		var data = null;
		if (App has :Storage) {
			var code = App.Storage.getValue("code#" + id);
			if(code != null) {
				return new Code(id, code[:label], code[:data]);
			}
		} else {
			var app = App.getApp();
			var label= app.getProperty("code#" + id + "-label");
			var data = app.getProperty("code#" + id + "-data");
			if(data != null) {
				return new Code(id, label, data);
			}
		}
		return null;
	}

	function _setProperty(key, value) {
		if (App has :Properties) {
			Properties.setValue(key, value);
		} else {
			var app = App.getApp();
			app.setProperty(key, value);
		}
	}

	function _getProperty(key) {
		if (App has :Properties) {
			return Properties.getValue(key);
		} else {
			var app = App.getApp();
			return app.getProperty(key);
		}
	}
}