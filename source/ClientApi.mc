import Toybox.Communications;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;
import Toybox.Attention;

class ClientApi {

	public function loadUser(token as String, latlng as Dictionary) {
		var strUrl = "https://data-manager-api.qrcode.macherel.fr/users/" + Settings.token + "/qrcodes?v=" + Settings.version;
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

 		Communications.makeWebRequest(
			strUrl,
			{},
			{
				:methods => Communications.HTTP_REQUEST_METHOD_GET,
				:headers => {
					"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
				},
				:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
			},
			method(:onReceive)
		);
	}

	//! Receive the data from the web request
    //! @param responseCode The server response code
    //! @param data Content from a successful request
    public function onReceive(responseCode as Number, data as Dictionary<String, Object?> or String or Null) as Void {
		Settings.responseCode = responseCode;
		System.println(data);
		if (responseCode == 200 && data instanceof Array) {
			var codes = [];
			var responseCodes = (data as Array<Dictionary>);
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
		WatchUi.requestUpdate();
	}

	private function _vibrate() {
		if (Settings.vibrate && Attention has :vibrate) {
			Attention.vibrate([new Attention.VibeProfile(50, 1000)]);
		}
	}
}