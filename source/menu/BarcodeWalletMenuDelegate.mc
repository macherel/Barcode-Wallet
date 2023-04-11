import Toybox.Application;
import Toybox.WatchUi;

class BarcodeWalletMenuDelegate extends WatchUi.MenuInputDelegate {

	function initialize () {
		MenuInputDelegate.initialize ();
	}

	function onMenuItem (item) as Void {
		var menu = item as DMenuItem;
		System.println("Select code #" + menu.id);
		Settings.zoom = false;
		Settings.setCurrentIndex(menu.id);
		Settings.currentCode = menu.userData;
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
	}
}