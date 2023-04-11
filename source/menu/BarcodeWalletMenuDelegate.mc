import Toybox.Application;
import Toybox.WatchUi;

class BarcodeWalletMenuDelegate extends WatchUi.MenuInputDelegate {

	private static var settings = Settings.INSTANCE;
	private static var log = Logger.INSTANCE;

	function initialize () {
		MenuInputDelegate.initialize ();
	}

	function onMenuItem (item) as Void {
		var menu = item as DMenuItem;
		log.debug("Select code #{}", [menu.id]);
		settings.zoom = false;
		settings.setCurrentIndex(menu.id);
		settings.currentCode = menu.userData;
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
	}
}