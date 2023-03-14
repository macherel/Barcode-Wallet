import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class BarcodeWalletView extends WatchUi.View {

	var qrCodeFonts as Array<Array<Resource>> = [];

	function initialize() {
		View.initialize();
	}

	// Load your resources here
	function onLayout(dc) {
		System.println("> onLayout");	

		var qrCodeFont1 = [
			WatchUi.loadResource(Rez.Fonts.qrcode1_1),
			WatchUi.loadResource(Rez.Fonts.qrcode1_2),
			WatchUi.loadResource(Rez.Fonts.qrcode1_3),
			WatchUi.loadResource(Rez.Fonts.qrcode1_4),
			WatchUi.loadResource(Rez.Fonts.qrcode1_5),
			WatchUi.loadResource(Rez.Fonts.qrcode1_6),
			WatchUi.loadResource(Rez.Fonts.qrcode1_7),
			WatchUi.loadResource(Rez.Fonts.qrcode1_8),
			WatchUi.loadResource(Rez.Fonts.qrcode1_9),
			WatchUi.loadResource(Rez.Fonts.qrcode1_10),
			WatchUi.loadResource(Rez.Fonts.qrcode1_11),
			WatchUi.loadResource(Rez.Fonts.qrcode1_12),
			WatchUi.loadResource(Rez.Fonts.qrcode1_13),
			WatchUi.loadResource(Rez.Fonts.qrcode1_14),
			WatchUi.loadResource(Rez.Fonts.qrcode1_15),
			WatchUi.loadResource(Rez.Fonts.qrcode1_16)
		];
		var qrCodeFont2 = [
			WatchUi.loadResource(Rez.Fonts.qrcode2_2),
			WatchUi.loadResource(Rez.Fonts.qrcode2_3),
			WatchUi.loadResource(Rez.Fonts.qrcode2_4),
			WatchUi.loadResource(Rez.Fonts.qrcode2_5),
			WatchUi.loadResource(Rez.Fonts.qrcode2_6),
			WatchUi.loadResource(Rez.Fonts.qrcode2_7),
			WatchUi.loadResource(Rez.Fonts.qrcode2_8),
			WatchUi.loadResource(Rez.Fonts.qrcode2_9),
			WatchUi.loadResource(Rez.Fonts.qrcode2_10),
			WatchUi.loadResource(Rez.Fonts.qrcode2_11),
			WatchUi.loadResource(Rez.Fonts.qrcode2_12),
			WatchUi.loadResource(Rez.Fonts.qrcode2_13),
			WatchUi.loadResource(Rez.Fonts.qrcode2_14),
			WatchUi.loadResource(Rez.Fonts.qrcode2_15),
			WatchUi.loadResource(Rez.Fonts.qrcode2_16),
			WatchUi.loadResource(Rez.Fonts.qrcode2_17),
			WatchUi.loadResource(Rez.Fonts.qrcode2_18),
			WatchUi.loadResource(Rez.Fonts.qrcode2_19),
			WatchUi.loadResource(Rez.Fonts.qrcode2_20),
			WatchUi.loadResource(Rez.Fonts.qrcode2_21),
			WatchUi.loadResource(Rez.Fonts.qrcode2_22),
			WatchUi.loadResource(Rez.Fonts.qrcode2_23),
			WatchUi.loadResource(Rez.Fonts.qrcode2_24),
			WatchUi.loadResource(Rez.Fonts.qrcode2_25),
			WatchUi.loadResource(Rez.Fonts.qrcode2_26),
			WatchUi.loadResource(Rez.Fonts.qrcode2_27),
			WatchUi.loadResource(Rez.Fonts.qrcode2_28),
			WatchUi.loadResource(Rez.Fonts.qrcode2_29),
			WatchUi.loadResource(Rez.Fonts.qrcode2_30),
			WatchUi.loadResource(Rez.Fonts.qrcode2_31),
			WatchUi.loadResource(Rez.Fonts.qrcode2_32)
		];
		qrCodeFonts = [ qrCodeFont1, qrCodeFont2 ];
		System.println("< onLayout");
	}

	// Called when this View is brought to the foreground. Restore
	// the state of this View and prepare it to be shown. This includes
	// loading resources into memory.
	function onShow() {
	}

	// Update the view
	function onUpdate(dc) {
		System.println("> OnUpdate");
		// Call the parent onUpdate function to redraw the layout
		View.onUpdate(dc);

		var dcWidth = dc.getWidth();
		var dcHeight = dc.getHeight();
		var maxWidth = dcWidth  * 0.81111;
		var maxHeight= dcHeight * 0.81111;
		if (maxWidth == maxHeight) {
			// For round device... Otherwise image is hidden in corner
			maxWidth = maxWidth * 0.86;
			maxHeight = maxHeight * 0.86;
		}

		var size = maxWidth<maxHeight?maxWidth:maxHeight;

		if(_handleErrors(dc)) {
			System.println("< OnUpdate - error");
			return;
		}

		var code = Settings.currentCode;
		System.println("Getting code #" + Settings.currentIndex + " of " + Settings.codes.size() + " : " + code);
		if (code == null) {
			code = new Code(-1, 1, null, null, 0, 0, null);
		}
		var data = code.data;

		if (data == null) {
			displayMessage(dc, code.label + "\n" + WatchUi.loadResource(Rez.Strings.error));
			System.println("< OnUpdate - no data");
			return;
		}

		System.println("Displaying code " + code);
		////////////////////////////////////////////////////////////////
		// Find font size
		////////////////////////////////////////////////////////////////
		var version = code.version;
		var qrCodeFont = qrCodeFonts[version-1];
		var fontSizeStep = 1 / version;
		var fontIndex = 1;
		// On round watch barcode can be bigger
		var factor = (maxHeight==maxWidth && data.size()==1) ? 0.8 : 1;			
		for(fontIndex = 0;
			fontIndex < qrCodeFont.size()-1 &&
			(fontIndex+1+version) * data[0].length() <= size/factor + 0.001;
			fontIndex++
		) {
		}
		if(Settings.zoom) {
			fontIndex++;
		}
		var moduleSize = (fontIndex+version) / version.toFloat();
		System.println("Code will be displayed using font size " + (fontIndex+version));

		////////////////////////////////////////////////////////////////
		// Display current code
		////////////////////////////////////////////////////////////////
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
		dc.clear();
		_drawQRCode(dc, code, qrCodeFont[fontIndex], moduleSize, version);

//		dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_WHITE);
//		dc.drawRectangle((dc.getWidth()-size)/2, (dc.getHeight()-size)/2, size, size);

		if(Settings.forceBacklight) {
			Attention.backlight(1.0);
		}
		System.println("< OnUpdate");
		return;
	}

	// Called when this View is removed from the screen. Save the
	// state of this View here. This includes freeing resources from
	// memory.
	function onHide() {
	}

	function _handleErrors(dc) {
		if (Settings.codes == null || Settings.debug || Settings.state == :NO_TOKEN) {
			switch(Settings.state) {
				case :READY:
					break;
				case :WAITING_POSITION:
					displayMessage(dc, WatchUi.loadResource(Rez.Strings.waitingPosition));
					return true;
				case :LOADING:
					displayMessage(dc, WatchUi.loadResource(Rez.Strings.loading));
					return true;
				case :NO_TOKEN:
					Settings.currentCode = new Code(
						-1, 1,
						WatchUi.loadResource(Rez.Strings.gettingStarted),
						"https://github.com/macherel/Barcode-Wallet/wiki/Getting-started",
						37, 37,
						["f8bbb8f0db54ef2f35c5ecb4c77180f8bbb8f","e2aaa2e038bce8b4793d6d21f4a9f0e2aaa2e","e38a6bab0e692fd7c231842117d975942f5c8","5c0474a7427716e5dbb721b8d8cc2ed5fcafc","675852a16f835e42ed97c6218866b04b19a76","cfea5da25183e290c2946bb72108ef2a95159","92490bad9b0d11b276e2ef97ccfc1ed5e3ef4","322a2ab07c4f179e168072d54c25f8a8f0e1e","f0eee0f06012cb2c32da76d25594aff9fb7e0","8888888080000808080800808880000088088"]
					);
					displayMessage(dc, WatchUi.loadResource(Rez.Strings.errorNoToken));
					return false;
				case :ERROR:
					displayMessage(dc, WatchUi.loadResource(Rez.Strings.error) + " " + Settings.responseCode);
					return true;
				default:
					System.println("Unknown state");
					displayMessage(dc, WatchUi.loadResource(Rez.Strings.errorUnknown));
					return true;
			}
		}
		if (Settings.codes.size() == 0) {
			displayMessage(dc, WatchUi.loadResource(Rez.Strings.errorNoBarcode));
			return true;
		}
		if(Settings.currentIndex < 0 || Settings.currentIndex >= Settings.codes.size()) {
			System.println("Wrong index");
			displayMessage(dc, WatchUi.loadResource(Rez.Strings.errorUnknown));
			return true;
		}
		return false;
	}

	function _drawQRCode(dc, code as Code, font, moduleSize, version) {
		var dy = version==1 ? 4 : 2;
		var fontHeight = moduleSize * dy;
		var data = code.data;
		if (!(data instanceof Toybox.Lang.Array)) {
			return;
		}
		var offsetY = (dc.getHeight() - code.height * moduleSize) / 2;
		var nbLines = data.size();
		if (code.height == 1) {
			var barcodeHeight = dc.getHeight()/10;
			nbLines = barcodeHeight / moduleSize;
			offsetY = (dc.getHeight() - nbLines * fontHeight) / 2;
		}

		if (Settings.displayLabel) {
			System.println("Display label");
			dc.setColor (Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
			dc.drawText(
				(dc.getWidth()) / 2,
				offsetY - dc.getFontHeight(Graphics.FONT_TINY),
				Graphics.FONT_TINY,
				code.label,
				Graphics.TEXT_JUSTIFY_CENTER
			);
		}
		if(Settings.state == :NO_TOKEN) {
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_RED);
		} else {
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
		}
		for(var i=0; i<nbLines; i++) {
			dc.drawText(
					(dc.getWidth()) / 2,
					offsetY + (i * fontHeight),
					font,
					data.size() == 1 ? data[0] : data[i], // For barcode, repeat the first raw
					Graphics.TEXT_JUSTIFY_CENTER
			);
		}

		if (Settings.displayValue) {
			System.println("Display Value");
			dc.setColor (Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
			dc.drawText(
				(dc.getWidth()) / 2,
				offsetY + ((data.size() == 1 ? nbLines * dy : data[0].length()) * moduleSize),
				Graphics.FONT_XTINY,
				code.value,
				Graphics.TEXT_JUSTIFY_CENTER
			);
		}
	}

	function displayMessage(dc, message) {
		System.println("Display message \"" + message + "\".");
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
