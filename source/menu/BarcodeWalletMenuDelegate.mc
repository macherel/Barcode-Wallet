using Toybox.WatchUi as Ui;
using Toybox.Application as App;

class BarcodeWalletMenuDelegate extends Ui.MenuInputDelegate {

	function initialize () {
		MenuInputDelegate.initialize ();
	}

	function onMenuItem (item as DMenuItem) {
		System.println("Select code #" + item.id);
		Settings.zoom = false;
		Settings.setCurrentIndex(item.id);
		Settings.currentCode = item.userData;
		Ui.popView(Ui.SLIDE_IMMEDIATE);
	}
}