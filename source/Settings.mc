import Toybox.Application;
//import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class Settings {

	public static var INSTANCE = new Settings();

	public var debug = false;
	public var version = 1;
	public var token;
	public var displayLabel;
	public var displayValue;
	public var forceBacklight;
	public var codes as Array<Code> = [];
	public var size = -1;
	public var usePosition = false;
	public var vibrate = true;
	public var currentIndex = -1;
	public var currentCode as Code? = null;
	public var state = :UNKNOWN; // UNKNOWN, READY, ERROR, LOADING, NO_TOKEN
	public var responseCode = null;
	public var zoom = false;

	public function getToken() {
		return getProperty("token");
	}

	public function hasToken() {
		return !isNullOrEmpty(getToken());
	}
	
	public function setCurrentIndex(index) {
		System.println("Change currentIndex to "+ Settings.currentIndex);		
		currentIndex = index;
		currentCode = _getCurrentCode();
		setProperty("currentIndex", index);
		state = :READY;
	}
	
	private function _getCurrentCode() {
		if(0 <= currentIndex && currentIndex < codes.size()) {
			return codes[currentIndex];
		}
		return null;
	}

	public function load() {

		size = getProperty("size");
		codes = _loadCodes();
		token = getProperty("token");
		usePosition = getProperty("usePosition");
		vibrate = getProperty("vibrate");
		version = getProperty("version");
		debug = getProperty("debug");
		displayLabel = getProperty("displayLabel");
		displayValue = getProperty("displayValue");
		forceBacklight = getProperty("forceBacklight");
		currentIndex = getProperty("currentIndex");
		if (currentIndex == null) {
			currentIndex = 0;
		}
		validateCurrentIndex();
		currentCode = _getCurrentCode();
	}

	private function _loadCodes() as Array<Code> {
		codes = [];
		var i = 0;
		var code = _loadCode(i);
		while (code != null && (size <= 0 || i < size)) {
			codes.add(code);
			i++;
			code = _loadCode(i);
		}
		System.println(codes.size() + " codes loaded.");
		return codes;
	}
	
	public function storeCodes(newCodes) {
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
		if(currentCode == null) {
			currentCode = _getCurrentCode();
		}
	}

	private function validateCurrentIndex() as Void {
		if (currentIndex > codes.size()-1) {
			setCurrentIndex(codes.size()-1);
		}
		if(currentIndex < 0) {
			setCurrentIndex(0);
		} else {
			System.println("Settings.currentIndex = "+ Settings.currentIndex);
		}
	}

	private function _storeCode(code) as Void {
		setProperty("code#" + code.id + "-version", code.version);
		setProperty("code#" + code.id + "-label", code.label);
		setProperty("code#" + code.id + "-value", code.value);
		setProperty("code#" + code.id + "-width", code.width);
		setProperty("code#" + code.id + "-height", code.height);
		setProperty("code#" + code.id + "-data", code.data);
	}

	private function _loadCode(id) as Code? {
		var version = getProperty("code#" + id + "-version") as Number;
		var label = getProperty("code#" + id + "-label") as String;
		var value = getProperty("code#" + id + "-value") as String;
		var width = getProperty("code#" + id + "-width") as Number;
		var height= getProperty("code#" + id + "-height") as Number;
		var data  = getProperty("code#" + id + "-data") as Array<String>;
		if (data != null) {
			return new Code(id, version, label, value, width, height, data);
		}
		return null;
	}

	private function _removeCode(id) as Void {
		var app = Application.getApp();
		app.setProperty("code#" + id + "-data", null);
	}

	private function getProperty(key as String) as PropertyValueType {
		return Application.getApp().getProperty(key);
	}

	private function setProperty(key as String, value as PropertyValueType) as Void {
		Application.getApp().setProperty(key, value);
	}
}