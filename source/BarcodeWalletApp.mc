using Toybox.Application;
using Toybox.WatchUi as Ui;

class BarcodeWalletApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    	_initializeSettings();
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

	function onSettingsChanged() {
		AppBase.onSettingsChanged();
		_initializeSettings();
	}

    // Return the initial view of your application here
    function getInitialView() {
        return [ new BarcodeWalletView(), new BarcodeWalletDelegate() ];
    }

	function _initializeSettings() {
    	Settings.load();
    	if (Settings.hasToken()) {
    		Settings.state = :LOADING;
    		ClientApi.loadUser(Settings.token);
    	} else {
    		Settings.state = :NO_TOKEN;
    	}
    	Ui.requestUpdate();
	}
}