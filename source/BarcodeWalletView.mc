using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class BarcodeWalletView extends Ui.View {

	var qrCodeFont = [];

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
		System.println("> onLayout");	

		qrCodeFont = [
			Ui.loadResource(Rez.Fonts.qrcode1),
			Ui.loadResource(Rez.Fonts.qrcode2),
			Ui.loadResource(Rez.Fonts.qrcode3),
			Ui.loadResource(Rez.Fonts.qrcode4),
			Ui.loadResource(Rez.Fonts.qrcode5),
			Ui.loadResource(Rez.Fonts.qrcode6),
			Ui.loadResource(Rez.Fonts.qrcode7),
			Ui.loadResource(Rez.Fonts.qrcode8),
			Ui.loadResource(Rez.Fonts.qrcode9),
			Ui.loadResource(Rez.Fonts.qrcode10),
			Ui.loadResource(Rez.Fonts.qrcode11),
			Ui.loadResource(Rez.Fonts.qrcode12),
			Ui.loadResource(Rez.Fonts.qrcode13),
			Ui.loadResource(Rez.Fonts.qrcode14),
			Ui.loadResource(Rez.Fonts.qrcode15),
			Ui.loadResource(Rez.Fonts.qrcode16)
		];
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
			maxWidth = maxWidth * 0.8;
			maxHeight = maxHeight * 0.8;
		}

		var size = maxWidth<maxHeight?maxWidth:maxHeight;

		if(_handleErrors(dc)) {
		    System.println("< OnUpdate - error");
			return false;
		}

		System.println("Getting code #" + Settings.currentIndex + " of " + Settings.codes.size());
		var code = Settings.currentCode;
		if (code == null) {
			code = new Code(-1, null, null);
		}
		var data = code.data;

		if (data == null) {
			displayMessage(dc, code.label + "\n" + Ui.loadResource(Rez.Strings.error));
		    System.println("< OnUpdate - no data");
			return false;
		}

		////////////////////////////////////////////////////////////////
		// Find font size
		////////////////////////////////////////////////////////////////
		var imageFontSize = 1;
		// On round watch barcode can be bigger
		var factor = (maxHeight==maxWidth && data.size()==1) ? 0.8 : 1;			
		for(imageFontSize = 1;
		    imageFontSize < qrCodeFont.size() &&
		    (imageFontSize+1) * data[0].length() <= size/factor+0.001;
		    imageFontSize++
		) {
		}
		if(Settings.zoom) {
			imageFontSize++;
		}
		System.println("Code will be displayed using font size " + imageFontSize);

		////////////////////////////////////////////////////////////////
		// Display current code
		////////////////////////////////////////////////////////////////
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
		dc.clear();
		_drawQRCode(dc, code, imageFontSize);
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

	function _drawQRCode(dc, code, moduleSize) {
		var data = code.data;
		if (!(data instanceof Toybox.Lang.Array)) {
			return;
		}
		var nbLines = data.size();
		if (nbLines == 1) {
			var barcodeHeight = dc.getHeight()/10;
			nbLines = barcodeHeight / moduleSize;
		}
		var offsetY = (dc.getHeight() - (nbLines-1) * 4 * moduleSize) / 2;

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
		var tmp = "";
		for(var i=0; i<nbLines; i++) {
			dc.drawText(
					(dc.getWidth()) / 2,
					offsetY + (i * 4 * moduleSize),
					qrCodeFont[moduleSize-1],
					data.size() == 1 ? data[0] : data[i], // For barcode, repeat the first raw
					Gfx.TEXT_JUSTIFY_CENTER
			);
		}

		if (Settings.displayValue) {
			System.println("Display label");
			dc.setColor (Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
			var font = Gfx.FONT_MEDIUM;
			dc.drawText(
				(dc.getWidth()) / 2,
				offsetY + (nbLines * 4 * moduleSize),
				Gfx.FONT_MEDIUM,
				code.data,
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
