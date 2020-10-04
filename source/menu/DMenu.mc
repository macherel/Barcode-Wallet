using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

var SCALE = 100;

// Inherit from this if you want to store additional information in the menu entry and/or change how 
// the menu is drawn - for example adding in a status icon.
// Any overridden drawing should be constrained within the items boundaries, i.e. y .. y + height / 3.
class DMenuItem
{
	const LABEL_FONT = Gfx.FONT_SMALL;
	const SELECTED_LABEL_FONT = Gfx.FONT_LARGE;
	const VALUE_FONT = Gfx.FONT_MEDIUM;
	const PAD = 0;

	var	id, label, value, userData;
	var index;		// filled in with its index, if selected
	
	// _id 		  is typically a symbol but can be anything and is just used in menu delegate to identify 
	//            which item has been selected.
	// _label	  the text to show as the item name.  Can be any object responding to toString ().
	// _value     the text to show when the item is in the selectable position.  Use null for no text
	//			  otherwise any object responding to toString () can be used.
	// _userData  optional.
	function initialize (_id, _label, _value, _userData)
	{
		id = _id;
		label = _label;
		value = _value;
		userData = _userData;
	}

	function draw (dc, y, highlight)
	{

		if (highlight)
		{
			setHighlightColor (dc);
			drawHighlightedLabel (dc, y);
		}
		else
		{
			setColor (dc);
			drawLabel (dc, y);
		}
	}
	
	function setHighlightColor (dc)
	{
		dc.setColor (Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
	}
	
	function setColor (dc)
	{
		dc.setColor (Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
	}
	
	function drawLabel (dc, y)
	{
		var width = dc.getWidth ();
		var h3 = dc.getHeight () / 3;
		var lab = label.toString ();
		var labDims = dc.getTextDimensions (lab, LABEL_FONT);
		var yL = y + (h3 - labDims[1]) / 2;

		dc.drawText (width / 2, yL, LABEL_FONT, lab, Gfx.TEXT_JUSTIFY_CENTER);
	}

	function drawHighlightedLabel (dc, y)
	{
		var width = dc.getWidth ();
		var h3 = dc.getHeight () / 3;
		var lab = label.toString ();
		var labDims = dc.getTextDimensions (lab, SELECTED_LABEL_FONT);
		var yL, yV, h;

		if (value != null)
		{
			// Show label and value.
			var val = value.toString ();
			var index = val.find("\n");
			if(index != null) {
				val = val.substring(0, index);
			}
			var valDims = dc.getTextDimensions (val, VALUE_FONT);

			h = labDims[1] + valDims[1] + PAD;
			yL = y + (h3 - h) / 2;
			yV = yL + labDims[1] + PAD;
			dc.drawText (width / 2, yV, VALUE_FONT, val, Gfx.TEXT_JUSTIFY_CENTER);
		}
		else
		{
			yL = y + (h3 - labDims[1]) / 2;
		}
		dc.drawText (width / 2, yL, SELECTED_LABEL_FONT, lab, Gfx.TEXT_JUSTIFY_CENTER);
	}
}

class DMenu extends Ui.View
{
	var menuArray;
	var title;
	var index;

	var nextIndex;
	hidden var drawMenu;
	
	function initialize (_menuArray, _menuTitle)
	{
		menuArray = _menuArray;
		title = _menuTitle;
		index = 0;
		nextIndex = 0;
		
		View.initialize ();
	}
	
	function onShow ()
	{
		drawMenu = new DrawMenu ();
	}
	
	function onHide ()
	{
		drawMenu = null;
	}

	// Return the menuItem with the matching id.  The menu item has its index field updated
	// with the index it was found at.  Returns null if not found.
	function itemWithId (id)
	{
		for (var idx = 0; idx < menuArray.size (); idx++)
		{
			if (menuArray[idx].id == id)
			{
				menuArray[idx].index = idx;
				return menuArray[idx];
			}
		}
		return null;
	}
	
	const ANIM_TIME = 0.3;
	function updateIndex (offset)
	{
		if (menuArray.size () <= 1)
		{
			return;
		}
		
/*
		if (offset == 1)
		{
			// Scroll down. Use 1000 as end value as cannot use 1. Scale as necessary in draw call.
			Ui.animate (drawMenu, :t, Ui.ANIM_TYPE_LINEAR, SCALE, 0, ANIM_TIME, null);
		}
		else
		{
			// Scroll up.
			Ui.animate (drawMenu, :t, Ui.ANIM_TYPE_LINEAR, -SCALE, 0, ANIM_TIME, null);
		}
//*/		
		nextIndex = index + offset;
		
		// Cope with a 'feature' in modulo operator not handling -ve numbers as desired.
		nextIndex = nextIndex < 0 ? menuArray.size () + nextIndex : nextIndex;
		
		nextIndex = nextIndex % menuArray.size ();
		
		Ui.requestUpdate();
		index = nextIndex;
	}
	
	function selectedItem ()
	{
		menuArray[index].index = index;
		return menuArray[index];
	}
	
	function onUpdate (dc)
	{
		if(drawMenu == null) {
			return;
		}
		var width = dc.getWidth ();
		var height = dc.getHeight ();
		
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
		dc.fillRectangle(0, 0, width, height);

		// Draw the menu items.
		drawMenu.index = index;
		drawMenu.nextIndex = nextIndex;
		drawMenu.menu = self;
		
		drawMenu.draw (dc);
		
		// Draw the decorations.
		var h3 = height / 3;
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
		dc.setPenWidth (2);
		dc.drawLine (0, h3, width, h3);
		dc.drawLine (0, h3 * 2, width, h3 * 2);
		
		drawArrows (dc);
	}
	
	const GAP = 5;
	const TS = 5;
	
	// The arrows are drawn with lines as polygons don't give different sized triangles depending
	// on their orientation.
	function drawArrows (dc)
	{
		var x = dc.getWidth () / 2;
		var y;

		dc.setPenWidth (1);
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
		
		if (nextIndex != 0)
		{
			y = GAP;
			
			for (var i = 0; i < TS; i++)
			{
				dc.drawLine (x - i, y + i, x + i + 1, y + i);
			}
		}	

		if (nextIndex != menuArray.size () - 1)
		{
			y = dc.getHeight () - TS - GAP;
			
			var d;
			for (var i = 0; i < TS; i++)
			{
				d = TS - 1 - i;
				dc.drawLine (x - d, y + i, x + d + 1, y + i);
			}
		}	
	}	
}

// Done as a class so it can be animated.
class DrawMenu extends Ui.Drawable
{
	const TITLE_FONT = Gfx.FONT_SMALL;

	var t = 0;				// 'time' in the animation cycle 0...1000 or -1000...0.
	var index, nextIndex, menu;
			
	function initialize ()
	{
		Drawable.initialize ({});
	}
	
	function draw (dc)
	{
		var width = dc.getWidth ();
		var height = dc.getHeight ();
		var h3 = height / 3;
		var items = menu.menuArray.size ();
		
		nextIndex = menu.nextIndex;

		// y for the middle of the three items.  
		var y = h3 + (t / SCALE) * h3;
		
		// Depending on where we are in the menu and in the animation some of 
		// these will be unnecessary but it is easier to draw everything and
		// rely on clipping to avoid unnecessary drawing calls.
		drawTitle (dc, y - nextIndex * h3 - h3);
		for (var i = -2; i < 3; i++)
		{
			drawItem (dc, nextIndex + i, y + h3 * i, i == 0);
		}
	}
	
	function drawTitle (dc, y)
	{		
		var width = dc.getWidth ();
		var h3 = dc.getHeight () / 3;

		// Check if any of the title is visible., 
		if (y < -h3)
		{
			return;
		}

		dc.setColor (Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
		dc.fillRectangle (0, y, width, h3);

		if (menu.title != null)
		{
			var dims = dc.getTextDimensions (menu.title, TITLE_FONT);
			var h = (h3 - dims[1]) / 2;
			dc.setColor (Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
			dc.drawText (width / 2, y + h, TITLE_FONT, menu.title, Gfx.TEXT_JUSTIFY_CENTER);
		}
	}
	
	// highlight is the selected menu item that can optionally show a value.
	function drawItem (dc, idx, y, highlight)
	{
		var h3 = dc.getHeight () / 3;

		// Cannot see item if it doesn't exist or will not be visible.
		if (idx < 0 || idx >= menu.menuArray.size () || 
			menu.menuArray[idx] == null || y > dc.getHeight () || y < -h3)
		{
			return;
		}
		
		menu.menuArray[idx].draw (dc, y, highlight);
	}
}

class DMenuDelegate extends Ui.BehaviorDelegate 
{
	hidden var menu;
	hidden var userMenuDelegate;
	
	function initialize (_menu, _userMenuInputDelegate)
	{
		menu = _menu;
		userMenuDelegate = _userMenuInputDelegate;
		BehaviorDelegate.initialize ();
	}
	
	function onNextPage ()
	{
		menu.updateIndex (1);
		return true;
	}
	
	function onPreviousPage ()
	{
		menu.updateIndex (-1);
		return true;		
	}
	
	function onKey(e) {
		switch(e.getKey()) {
			case KEY_ENTER:
			case KEY_START:
			case KEY_MENU:
				return onNextPage();
			case KEY_LAP:
				return onPreviousPage();
		}
		return false;
	}

	function onSelect ()
	{
		userMenuDelegate.onMenuItem (menu.selectedItem ());
		Ui.requestUpdate();
		return true;
	}
	
	function onBack () 
	{
		Ui.popView (Ui.SLIDE_RIGHT);
		return true;
	}
}