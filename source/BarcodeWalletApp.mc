using Toybox.Application;
using Toybox.WatchUi as Ui;

class BarcodeWalletApp extends Application.AppBase {

	function onPosition(info) {
		var myLocation = info.position.toDegrees();
		System.println("Position received : " + myLocation);
		ClientApi.loadUser(
			Settings.token,
			{
				:lat => myLocation[0],
				:lng => myLocation[1]
			}
		);
    	Ui.requestUpdate();
	}

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
			if(Settings.usePosition) {
				System.println("Requesting position...");
				Settings.state = :WAITING_POSITION;
				Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:onPosition));
			} else {
    			ClientApi.loadUser(Settings.token, null);
			}
    	} else {
    		Settings.state = :NO_TOKEN;
    	}
    	Ui.requestUpdate();
	}
}