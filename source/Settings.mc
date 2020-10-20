using Toybox.Application as App;
using Toybox.Application.Properties as Properties;
using Toybox.WatchUi as Ui;
using Toybox.System as System;

module Settings {

	var debug = false;
	var token;
	var displayLabel;
	var codes = null;
	var currentIndex = null;
	var state = :UNKNOWN; // UNKNOWN, READY, ERROR, LOADING, NO_TOKEN
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
		codes = _loadCodes();
		token = _getProperty("token");
		debug = _getProperty("debug");
		displayLabel = _getProperty("displayLabel");
		currentIndex = _getProperty("currentIndex");
		if (currentIndex == null) {
			currentIndex = 0;
		}
		validateCurrentIndex();
	}

	function _loadCodes() {
		codes = [];
		var i = 0;
		var code = _loadCode(i);
		while (code != null) {
			codes.add(code);
			i++;
			code = _loadCode(i);
		}
		return codes;
	}
	
	function storeCodes(newCodes) {
		codes = newCodes;
		var i = 0;
		while(i<codes.size()) {
			_storeCode(codes[i]);
			i++;
		}
		while(_loadCode(i) != null) {
			_removeCode(i);
			i++;
		}
		
		validateCurrentIndex();
	}

	function validateCurrentIndex() {
		if (currentIndex > codes.size()-1) {
			setCurrentIndex(codes.size()-1);
		}
	}

	function _storeCode(code) {
		if (App has :Storage) {
			App.Storage.setValue(
				"code#" + code.id,
				{
					"label" => code.label,
					"data" => code.data,
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
			if (code != null) {
				return new Code(id, code["label"], code["data"]);
			}
		} else {
			var app = App.getApp();
			var label= app.getProperty("code#" + id + "-label");
			var data = app.getProperty("code#" + id + "-data");
			if (data != null) {
				return new Code(id, label, data);
			}
		}
		return null;
	}

	function _removeCode(id) {
		if (App has :Storage) {
			App.Storage.deleteValue("code#" + id);
		} else {
			var app = App.getApp();
			app.setProperty("code#" + id + "-data", null);
		}
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