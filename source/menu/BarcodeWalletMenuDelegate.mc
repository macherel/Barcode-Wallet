using Toybox.WatchUi as Ui;
using Toybox.Application as App;

class BarcodeWalletMenuDelegate extends Ui.MenuInputDelegate {

	function initialize () {
		MenuInputDelegate.initialize ();
	}

	function onMenuItem (item) {
		System.println("Select code #" + item.id);
		Settings.setCurrentIndex(item.id);
		Ui.popView(Ui.SLIDE_IMMEDIATE);
	}
}