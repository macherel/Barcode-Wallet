using Toybox.WatchUi as Ui;
using Toybox.Application as App;

class BarcodeWalletDelegate extends Ui.BehaviorDelegate {

	function initialize() {
		BehaviorDelegate.initialize();
	}

	function onNextPage() {
		if (Settings.codes.size() == 0) {
			return false;
		}
		Settings.setCurrentIndex((Settings.currentIndex + 1) % Settings.codes.size());
		Ui.switchToView(new BarcodeWalletView(), new BarcodeWalletDelegate(), Ui.SLIDE_UP);
		return true;
	}

	function onPreviousPage() {
		if (Settings.codes.size() == 0) {
			return false;
		}
		Settings.setCurrentIndex((Settings.currentIndex - 1 + Settings.codes.size()) % Settings.codes.size());
		Ui.switchToView(new BarcodeWalletView(), new BarcodeWalletDelegate(), Ui.SLIDE_UP);
		return true;
	}

	function onSelect() {
		if (Settings.codes.size() > 0) {
			var codesMenu = [];
			for(var i=0; i<Settings.codes.size(); i++) {
				var code = Settings.codes[i];
				codesMenu.add(new DMenuItem(i, code.label, code.value, code));
			}
			var view = new DMenu(codesMenu, Ui.loadResource(Rez.Strings.mainMenuTitle));
			view.updateIndex(Settings.currentIndex);

			Ui.pushView(view, new DMenuDelegate(view, new BarcodeWalletMenuDelegate()), Ui.SLIDE_IMMEDIATE);
		} else {
			Ui.requestUpdate();
		}
		return true;
	}
	function onMenu() {	
		Settings.zoom = !Settings.zoom;
		Ui.requestUpdate();
	}
	
	function onSwipe(swipeEvent) {
		switch(swipeEvent.getDirection()) {
			case WatchUi.SWIPE_LEFT:
				break;
			default:
				return false;
		}
		if (Settings.codes.size() == 0) {
			return true;
		}
		
		var index = Settings.currentIndex;
		var transition = Ui.SLIDE_IMMEDIATE;
		switch(swipeEvent.getDirection()) {
			case WatchUi.SWIPE_LEFT:
				index++;
				transition = Ui.SLIDE_LEFT;
				break;
		}
		index = (index + Settings.codes.size()) % Settings.codes.size();
		Settings.setCurrentIndex(index);
		Ui.switchToView(new BarcodeWalletView(), new BarcodeWalletDelegate(), transition);

		return true;
	}
}
