import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class BarcodeWalletGlanceView extends WatchUi.GlanceView {

	private static var settings = Settings.INSTANCE;
	private static var log = Logger.INSTANCE;

	var qrCodeFonts as Array<Array<Resource>> = [];

	function initialize() {
		GlanceView.initialize();
	}

	// Load your resources here
	function onLayout(dc) {
		log.debug("> onLayout", null);	

		qrCodeFonts = [
			WatchUi.loadResource(Rez.Fonts.qrcode1_1),
			WatchUi.loadResource(Rez.Fonts.qrcode1_2),
			WatchUi.loadResource(Rez.Fonts.qrcode1_3),
			WatchUi.loadResource(Rez.Fonts.qrcode1_4),
			WatchUi.loadResource(Rez.Fonts.qrcode1_5),
			WatchUi.loadResource(Rez.Fonts.qrcode1_6),
			WatchUi.loadResource(Rez.Fonts.qrcode1_7),
			WatchUi.loadResource(Rez.Fonts.qrcode1_8)
		];
		log.debug("< onLayout", null);
	}

	// Called when this View is brought to the foreground. Restore
	// the state of this View and prepare it to be shown. This includes
	// loading resources into memory.
	function onShow() {
	}

	// Update the view
	function onUpdate(dc) {
		log.debug("> OnUpdate", null);
		// Call the parent onUpdate function to redraw the layout
		View.onUpdate(dc);

		var maxWidth = dc.getWidth();
		var maxHeight= dc.getHeight();

		if(_handleErrors(dc)) {
			log.debug("< OnUpdate - error", null);
			return;
		}

		var code = settings.currentCode;
		log.debug("Getting code #{} of {} : {}", [settings.currentIndex, settings.codes.size(), code]);
		if (code == null) {
			code = new Code(-1, 1, null, null, 0, 0, null);
		}
		var data = code.data as Array<String>?;

		if (data == null) {
			displayMessage(dc, code.label + "\n" + WatchUi.loadResource(Rez.Strings.error));
			log.debug("< OnUpdate - no data", null);
			return;
		}

		var height = maxHeight - dc.getFontHeight(Graphics.FONT_XTINY) / 3;
		var width = maxWidth - dc.getFontHeight(Graphics.FONT_XTINY) / 3;
		if(code.height == 1) {
			height = maxHeight * 0.5;
		} else {
			width = height;
		}

		log.debug("Displaying code {}", [code]);
		////////////////////////////////////////////////////////////////
		// Find font size
		////////////////////////////////////////////////////////////////
		var fontIndex = 0;
		// On round watch barcode can be bigger
		for(fontIndex = 0;
			fontIndex < qrCodeFonts.size()-1 &&
			(fontIndex+2) * data[0].length() <= width + 0.001;
			fontIndex++
		) {
			log.debug("fontIndex: {}", [fontIndex]);
		}
		if(settings.zoom) {
			fontIndex++;
		}
		var moduleSize = fontIndex + 1;
		log.debug("Code will be displayed using font size {}", [fontIndex + 1]);

		////////////////////////////////////////////////////////////////
		// Display current code
		////////////////////////////////////////////////////////////////
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
		dc.clear();
		_drawQRCode(dc, code, qrCodeFonts[fontIndex], moduleSize);

		if(settings.forceBacklight) {
			Attention.backlight(1.0);
		}
		log.debug("< OnUpdate", null);
		return;
	}

	// Called when this View is removed from the screen. Save the
	// state of this View here. This includes freeing resources from
	// memory.
	function onHide() {
	}

	function _handleErrors(dc) {
		if (settings.codes == null || settings.debug || settings.state == :NO_TOKEN) {
			switch(settings.state) {
				case :READY:
					break;
				case :WAITING_POSITION:
					displayMessage(dc, WatchUi.loadResource(Rez.Strings.waitingPosition));
					return true;
				case :LOADING:
					displayMessage(dc, WatchUi.loadResource(Rez.Strings.loading));
					return true;
				case :NO_TOKEN:
					settings.currentCode = new Code(
						-1, 1,
						WatchUi.loadResource(Rez.Strings.gettingStarted),
						"https://github.com/macherel/Barcode-Wallet/wiki/Getting-started",
						37, 37,
						["f8bbb8f0db54ef2f35c5ecb4c77180f8bbb8f","e2aaa2e038bce8b4793d6d21f4a9f0e2aaa2e","e38a6bab0e692fd7c231842117d975942f5c8","5c0474a7427716e5dbb721b8d8cc2ed5fcafc","675852a16f835e42ed97c6218866b04b19a76","cfea5da25183e290c2946bb72108ef2a95159","92490bad9b0d11b276e2ef97ccfc1ed5e3ef4","322a2ab07c4f179e168072d54c25f8a8f0e1e","f0eee0f06012cb2c32da76d25594aff9fb7e0","8888888080000808080800808880000088088"]
					);
					displayMessage(dc, WatchUi.loadResource(Rez.Strings.errorNoToken));
					return false;
				case :ERROR:
					displayMessage(dc, WatchUi.loadResource(Rez.Strings.error) + " " + settings.responseCode);
					return true;
				default:
					log.debug("Unknown state : {}", [settings.state]);
					displayMessage(dc, WatchUi.loadResource(Rez.Strings.errorUnknown));
					return true;
			}
		}
		if (settings.codes.size() == 0) {
			displayMessage(dc, WatchUi.loadResource(Rez.Strings.errorNoBarcode));
			return true;
		}
		if(settings.currentIndex < 0 || settings.currentIndex >= settings.codes.size()) {
			log.debug("Wrong index", null);
			displayMessage(dc, WatchUi.loadResource(Rez.Strings.errorUnknown));
			return true;
		}
		return false;
	}

	function _drawQRCode(dc, code as Code, font, moduleSize) {
		var dy = 4;
		var fontHeight = moduleSize * dy;
		var data = code.data;
		if (!(data instanceof Toybox.Lang.Array)) {
			return;
		}
		var fontColor = Graphics.COLOR_BLACK;
		var justification = code.height == 1 ? Graphics.TEXT_JUSTIFY_CENTER : Graphics.TEXT_JUSTIFY_LEFT;
		var offsetY = (dc.getHeight() - code.height * moduleSize) / 2;
		var offsetX = code.height == 1 ? (dc.getWidth()) / 2 : dc.getFontHeight(Graphics.FONT_XTINY) / 4;
		var textOffsetX = code.height == 1 ? (dc.getWidth()) / 2 : offsetX + data[0].length() * moduleSize + (dc.getFontHeight(Graphics.FONT_XTINY) / 4);
		var nbLines = data.size();
		if (code.height == 1) {
			if(moduleSize * data[0].length() > dc.getWidth()) {
				fontColor = Graphics.COLOR_DK_RED;
			}
			var barcodeHeight = dc.getHeight() / 3;
			nbLines = barcodeHeight / moduleSize / 4;
			offsetY = (dc.getHeight() - nbLines * fontHeight) / 2;
		} else {
			if(moduleSize * data[0].length() > dc.getHeight()) {
				fontColor = Graphics.COLOR_DK_RED;
			}
		}

		dc.setColor (fontColor, Graphics.COLOR_WHITE);
		dc.drawText(
			textOffsetX,
			code.height == 1 ? offsetY - dc.getFontHeight(Graphics.FONT_XTINY) : (dc.getHeight() / 2) - dc.getFontHeight(Graphics.FONT_XTINY),
			Graphics.FONT_XTINY,
			code.label,
			justification
		);
		dc.drawText(
			textOffsetX,
			code.height == 1 ? offsetY + (nbLines * dy * moduleSize) : (dc.getHeight() / 2),
			Graphics.FONT_XTINY,
			code.value,
			justification
		);

		if(settings.state == :NO_TOKEN) {
			dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_WHITE);
		} else {
			dc.setColor(fontColor, Graphics.COLOR_WHITE);
		}
		for(var i=0; i<nbLines; i++) {
			var line = code.height == 1 ? data[0] : data[i]; // For barcode, repeat the first raw
			log.debug("Displaying line #{} : {}", [i, line]);
			dc.drawText(
					offsetX,
					offsetY + (i * fontHeight),
					font,
					line,
					justification
			);
		}
	}

	function displayMessage(dc, message) {
		log.debug("Display message \"{}\".", [message]);
		dc.setColor (Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
		dc.clear();
		dc.drawText(
			(dc.getWidth()) / 2,
			(dc.getHeight()) / 2,
			Graphics.FONT_MEDIUM,
			message,
			Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
		);
	}

}
