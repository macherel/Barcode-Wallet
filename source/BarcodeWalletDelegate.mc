import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.Application as App;

class BarcodeWalletDelegate extends Ui.BehaviorDelegate {

	private static var settings = Settings.INSTANCE;

	function initialize() {
		BehaviorDelegate.initialize();
	}

	function onNextPage() {
		if (settings.codes.size() == 0) {
			return false;
		}
		settings.setCurrentIndex((settings.currentIndex + 1) % settings.codes.size());
		Ui.switchToView(new BarcodeWalletView(), new BarcodeWalletDelegate(), Ui.SLIDE_UP);
		return true;
	}

	function onPreviousPage() {
		if (settings.codes.size() == 0) {
			return false;
		}
		settings.setCurrentIndex((settings.currentIndex - 1 + settings.codes.size()) % settings.codes.size());
		Ui.switchToView(new BarcodeWalletView(), new BarcodeWalletDelegate(), Ui.SLIDE_UP);
		return true;
	}

	function onSelect() {
		if (settings.codes.size() > 0) {
			var codesMenu = [];
			for(var i=0; i<settings.codes.size(); i++) {
				var code = (settings.codes as Array<Code>)[i];
				codesMenu.add(new DMenuItem(i, code.label, code.value, code));
			}
			var view = new DMenu(codesMenu, Ui.loadResource(Rez.Strings.mainMenuTitle));
			view.updateIndex(settings.currentIndex);

			Ui.pushView(view, new DMenuDelegate(view, new BarcodeWalletMenuDelegate()), Ui.SLIDE_IMMEDIATE);
		} else {
			Ui.requestUpdate();
		}
		return true;
	}
	function onMenu() {	
		settings.zoom = !settings.zoom;
		Ui.requestUpdate();
		return true;
	}
	
	function onSwipe(swipeEvent) {
		switch(swipeEvent.getDirection()) {
			case WatchUi.SWIPE_LEFT:
				break;
			default:
				return false;
		}
		if (settings.codes.size() == 0) {
			return true;
		}
		
		var index = settings.currentIndex;
		var transition = Ui.SLIDE_IMMEDIATE;
		switch(swipeEvent.getDirection()) {
			case WatchUi.SWIPE_LEFT:
				index++;
				transition = Ui.SLIDE_LEFT;
				break;
		}
		index = (index + settings.codes.size()) % settings.codes.size();
		settings.setCurrentIndex(index);
		Ui.switchToView(new BarcodeWalletView(), new BarcodeWalletDelegate(), transition);

		return true;
	}
}
