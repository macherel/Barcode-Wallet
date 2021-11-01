using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class BarcodeWalletView extends Ui.View {

	var qrCodeFonts = [];

	function initialize() {
		View.initialize();
	}

	// Load your resources here
	function onLayout(dc) {
		System.println("> onLayout");	

		var qrCodeFont1 = [
			Ui.loadResource(Rez.Fonts.qrcode1_1),
			Ui.loadResource(Rez.Fonts.qrcode1_2),
			Ui.loadResource(Rez.Fonts.qrcode1_3),
			Ui.loadResource(Rez.Fonts.qrcode1_4),
			Ui.loadResource(Rez.Fonts.qrcode1_5),
			Ui.loadResource(Rez.Fonts.qrcode1_6),
			Ui.loadResource(Rez.Fonts.qrcode1_7),
			Ui.loadResource(Rez.Fonts.qrcode1_8),
			Ui.loadResource(Rez.Fonts.qrcode1_9),
			Ui.loadResource(Rez.Fonts.qrcode1_10),
			Ui.loadResource(Rez.Fonts.qrcode1_11),
			Ui.loadResource(Rez.Fonts.qrcode1_12),
			Ui.loadResource(Rez.Fonts.qrcode1_13),
			Ui.loadResource(Rez.Fonts.qrcode1_14),
			Ui.loadResource(Rez.Fonts.qrcode1_15),
			Ui.loadResource(Rez.Fonts.qrcode1_16)
		];
		var qrCodeFont2 = [
			Ui.loadResource(Rez.Fonts.qrcode2_2),
			Ui.loadResource(Rez.Fonts.qrcode2_3),
			Ui.loadResource(Rez.Fonts.qrcode2_4),
			Ui.loadResource(Rez.Fonts.qrcode2_5),
			Ui.loadResource(Rez.Fonts.qrcode2_6),
			Ui.loadResource(Rez.Fonts.qrcode2_7),
			Ui.loadResource(Rez.Fonts.qrcode2_8),
			Ui.loadResource(Rez.Fonts.qrcode2_9),
			Ui.loadResource(Rez.Fonts.qrcode2_10),
			Ui.loadResource(Rez.Fonts.qrcode2_11),
			Ui.loadResource(Rez.Fonts.qrcode2_12),
			Ui.loadResource(Rez.Fonts.qrcode2_13),
			Ui.loadResource(Rez.Fonts.qrcode2_14),
			Ui.loadResource(Rez.Fonts.qrcode2_15),
			Ui.loadResource(Rez.Fonts.qrcode2_16),
			Ui.loadResource(Rez.Fonts.qrcode2_17),
			Ui.loadResource(Rez.Fonts.qrcode2_18),
			Ui.loadResource(Rez.Fonts.qrcode2_19),
			Ui.loadResource(Rez.Fonts.qrcode2_20),
			Ui.loadResource(Rez.Fonts.qrcode2_21),
			Ui.loadResource(Rez.Fonts.qrcode2_22),
			Ui.loadResource(Rez.Fonts.qrcode2_23),
			Ui.loadResource(Rez.Fonts.qrcode2_24),
			Ui.loadResource(Rez.Fonts.qrcode2_25),
			Ui.loadResource(Rez.Fonts.qrcode2_26),
			Ui.loadResource(Rez.Fonts.qrcode2_27),
			Ui.loadResource(Rez.Fonts.qrcode2_28),
			Ui.loadResource(Rez.Fonts.qrcode2_29),
			Ui.loadResource(Rez.Fonts.qrcode2_30),
			Ui.loadResource(Rez.Fonts.qrcode2_31),
			Ui.loadResource(Rez.Fonts.qrcode2_32)
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
		var maxWidth = dcWidth  * 0.8;
		var maxHeight= dcHeight * 0.8;
		if (maxWidth == maxHeight) {
			// For round device... Otherwise image is hidden in corner
			maxWidth = maxWidth * 0.86;
			maxHeight = maxHeight * 0.86;
		}

		var size = maxWidth<maxHeight?maxWidth:maxHeight;

		if(_handleErrors(dc)) {
			System.println("< OnUpdate - error");
			return false;
		}

		System.println("Getting code #" + Settings.currentIndex + " of " + Settings.codes.size());
		var code = Settings.currentCode;
		if (code == null) {
			code = new Code(-1, 1, null, null, 0, 0, null);
		}
		var data = code.data;

		if (data == null) {
			displayMessage(dc, code.label + "\n" + Ui.loadResource(Rez.Strings.error));
			System.println("< OnUpdate - no data");
			return false;
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
			fontIndex < qrCodeFont.size() &&
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
		return true;
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
					displayMessage(dc, Ui.loadResource(Rez.Strings.waitingPosition));
					return true;
				case :LOADING:
					displayMessage(dc, Ui.loadResource(Rez.Strings.loading));
					return true;
				case :NO_TOKEN:
					displayMessage(dc, Ui.loadResource(Rez.Strings.errorNoToken));
					return true;
				case :ERROR:
					displayMessage(dc, Ui.loadResource(Rez.Strings.error) + " " + Settings.responseCode);
					return true;
				default:
					System.println("Unknown state");
					displayMessage(dc, Ui.loadResource(Rez.Strings.errorUnknown));
					return true;
			}
		}
		if (Settings.codes.size() == 0) {
			displayMessage(dc, Ui.loadResource(Rez.Strings.errorNoBarcode));
			return true;
		}
		if(Settings.currentIndex < 0 || Settings.currentIndex >= Settings.codes.size()) {
			System.println("Wrong index");
			displayMessage(dc, Ui.loadResource(Rez.Strings.errorUnknown));
			return true;
		}
		return false;
	}

	function _drawQRCode(dc, code, font, moduleSize, version) {
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
			dc.setColor (Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
			dc.drawText(
				(dc.getWidth()) / 2,
				offsetY - dc.getFontHeight(Gfx.FONT_MEDIUM),
				Gfx.FONT_MEDIUM,
				code.label,
				Gfx.TEXT_JUSTIFY_CENTER
			);
		}

		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
		for(var i=0; i<nbLines; i++) {
			dc.drawText(
					(dc.getWidth()) / 2,
					offsetY + (i * fontHeight),
					font,
					data.size() == 1 ? data[0] : data[i], // For barcode, repeat the first raw
					Gfx.TEXT_JUSTIFY_CENTER
			);
		}

		if (Settings.displayValue) {
			System.println("Display Value");
			dc.setColor (Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
			dc.drawText(
				(dc.getWidth()) / 2,
				offsetY + ((data.size() == 1 ? nbLines * dy : data[0].length()) * moduleSize),
				Gfx.FONT_XTINY,
				code.value,
				Gfx.TEXT_JUSTIFY_CENTER
			);
		}
	}

	function displayMessage(dc, message) {
		System.println("Display message \"" + message + "\".");
		dc.setColor (Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
		dc.clear();
		dc.drawText(
			(dc.getWidth()) / 2,
			(dc.getHeight()) / 2,
			Gfx.FONT_MEDIUM,
			message,
			Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
		);
	}

}
