import Toybox.Application;
//import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class Settings {

	public static var debug = false;
	public static var version = 1;
	public static var token;
	public static var displayLabel;
	public static var displayValue;
	public static var forceBacklight;
	public static var codes as Array<Code> = [];
	public static var size = -1;
	public static var usePosition = false;
	public static var vibrate = true;
	public static var currentIndex = -1;
	public static var currentCode as Code? = null;
	public static var state = :UNKNOWN; // UNKNOWN, READY, ERROR, LOADING, NO_TOKEN
	public static var responseCode = null;
	public static var zoom = false;

	public static function getToken() {
		return _getProperty("token");
	}

	public static function hasToken() {
		return !isNullOrEmpty(getToken());
	}
	
	public static function setCurrentIndex(index) {
		System.println("Change currentIndex to "+ Settings.currentIndex);		
		currentIndex = index;
		currentCode = _getCurrentCode();
		Application.getApp().setProperty("currentIndex", index);
		state = :READY;
	}
	
	private static function _getCurrentCode() {
		if(0 <= currentIndex && currentIndex < codes.size()) {
			return codes[currentIndex];
		}
		return null;
	}

	public static function load() {
		var app = Application.getApp();
		size = app.getProperty("size");
		codes = _loadCodes();
		token = _getProperty("token");
		usePosition = app.getProperty("usePosition");
		vibrate = app.getProperty("vibrate");
		version = app.getProperty("version");
		debug = app.getProperty("debug");
		displayLabel = app.getProperty("displayLabel");
		displayValue = app.getProperty("displayValue");
		forceBacklight = app.getProperty("forceBacklight");
		currentIndex = app.getProperty("currentIndex");
		if (currentIndex == null) {
			currentIndex = 0;
		}
		validateCurrentIndex();
		currentCode = _getCurrentCode();
	}

	private static function _loadCodes() as Array<Code> {
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
	
	public static function storeCodes(newCodes) {
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

	private static function validateCurrentIndex() as Void {
		if (currentIndex > codes.size()-1) {
			setCurrentIndex(codes.size()-1);
		}
		if(currentIndex < 0) {
			setCurrentIndex(0);
		} else {
			System.println("Settings.currentIndex = "+ Settings.currentIndex);
		}
	}

	private static function _storeCode(code) as Void {
		var app = Application.getApp();
		app.setProperty("code#" + code.id + "-version", code.version);
		app.setProperty("code#" + code.id + "-label", code.label);
		app.setProperty("code#" + code.id + "-value", code.value);
		app.setProperty("code#" + code.id + "-width", code.width);
		app.setProperty("code#" + code.id + "-height", code.height);
		app.setProperty("code#" + code.id + "-data", code.data);
	}

	private static function _loadCode(id) as Code? {
		var app = Application.getApp();
		var version = app.getProperty("code#" + id + "-version");
		var label = app.getProperty("code#" + id + "-label");
		var value = app.getProperty("code#" + id + "-value");
		var width = app.getProperty("code#" + id + "-width");
		var height= app.getProperty("code#" + id + "-height");
		var data  = app.getProperty("code#" + id + "-data");
		if (data != null) {
			return new Code(id, version, label, value, width, height, data);
		}
		return null;
	}

	private static function _removeCode(id) as Void {
		var app = Application.getApp();
		app.setProperty("code#" + id + "-data", null);
	}

	private static function _getProperty(key) {
		return Application.getApp().getProperty(key);
	}
}