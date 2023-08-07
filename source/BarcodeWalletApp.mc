using Toybox.Application;
using Toybox.WatchUi as Ui;

class BarcodeWalletApp extends Application.AppBase {

	private static var settings = Settings.INSTANCE;
	private static var log = Logger.INSTANCE;

	private var clientApi = ClientApi.INSTANCE;

	public function onPosition(info as Toybox.Position.Info) as Void {
		var myLocation = info.position.toDegrees();
		log.debug("Position received : {}", [myLocation]);
		clientApi.loadUser(
			settings.token,
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
		if(settings.forceBacklight) {
			Attention.backlight(true);
		}
    }

	function onSettingsChanged() {
		AppBase.onSettingsChanged();
		_initializeSettings();
	}

    // Return the initial view of your application here
    function getInitialView() {
        return [ new BarcodeWalletView(), new BarcodeWalletDelegate() ];
    }

    // Return the glance view of your application here
    function getGlanceView() {
        return [ new BarcodeWalletGlanceView() ];
    }

	private function _initializeSettings() {
    	settings.load();
    	if (settings.hasToken()) {
			if(settings.usePosition) {
				log.debug("Requesting position...", null);
				settings.state = :WAITING_POSITION;
				Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:onPosition));
			} else {
    			clientApi.loadUser(settings.token, null);
			}
    	} else if(settings.codes == null || settings.codes.size() == 0) {
    		settings.state = :NO_TOKEN;
    	}
    	Ui.requestUpdate();
	}
}