using Toybox.Communications as Comm;
using Toybox.WatchUi as Ui;
using Toybox.Lang as Lang;
using Toybox.System as System;
using Toybox.Attention as Attention;

module ClientApi {
	function _onUserLoaded(responseCode, data) {
		Settings.responseCode = responseCode;
		if (responseCode == 200 && data != null) {
			var codes = [];
			var responseCodes = data["qrcodes"];
			for(var i=0; i<responseCodes.size(); i++) {
				codes.add(Code.fromResponseData(i, responseCodes[i]));
				System.println("code #" + i + " \"" + responseCodes[i]["name"] + "\" received.");
			}
			Settings.storeCodes(codes);
			_vibrate();
			Settings.state = :READY;
		} else {
			Settings.state = :ERROR;
			System.println("Error while loading user (" + responseCode + ")");
			// nothing to do, data will be loaded next time
		}
		System.println("<<< loadUser");
		Ui.requestUpdate();
	}
	
	function loadUser(token, latlng) {
		var strUrl = "https://data-manager-api.qrcode.macherel.fr/users/" + Settings.token + "?v=" + Settings.version;
		var hasQueryParam = true;
		if(latlng != null) {
			strUrl += "?lat=" + latlng[:lat];
			strUrl += "&lng=" + latlng[:lng];
			hasQueryParam = true;
		}
		if(Settings.size > 0) {
			strUrl += (hasQueryParam?"&":"?") + "size=" + Settings.size;
			hasQueryParam = true;
		}
		System.println(">>> loadUser - " + strUrl);
		if(Settings.state != :READY) {
			Settings.state = :LOADING;
		}
		Comm.makeWebRequest(
			strUrl,
			null,
			{
				:methods => Comm.HTTP_REQUEST_METHOD_GET,
				:headers => {
					"Content-Type" => Comm.REQUEST_CONTENT_TYPE_JSON
				},
				:responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
			},
			new Lang.Method(ClientApi, :_onUserLoaded)
		);
	}
	
	function _vibrate() {
		if (Settings.vibrate && Attention has :vibrate) {
			Attention.vibrate([new Attention.VibeProfile(50, 1000)]);
		}
	}
}