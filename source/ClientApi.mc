import Toybox.Communications;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;
import Toybox.Attention;

class ClientApi {

	public static var INSTANCE = new ClientApi();

	private static var settings = Settings.INSTANCE;
	private static var log = Logger.INSTANCE;

	public function loadUser(token as String, latlng as Dictionary?) {
		var strUrl = "https://data-manager-api.qrcode.macherel.fr/users/" + settings.token + "/qrcodes?v=" + settings.version;
		var hasQueryParam = true;
		if(latlng != null) {
			strUrl += "?lat=" + latlng[:lat];
			strUrl += "&lng=" + latlng[:lng];
			hasQueryParam = true;
		}
		if(settings.size > 0) {
			strUrl += (hasQueryParam?"&":"?") + "size=" + settings.size;
			hasQueryParam = true;
		}
		log.debug(">>> loadUser - {}", [strUrl]);
		if(settings.state != :READY) {
			settings.state = :LOADING;
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
		settings.responseCode = responseCode;
		if (responseCode == 200 && data instanceof Array) {
			log.debug("Loading user data", null);
			var codes = [];
			var responseCodes = (data as Array<Dictionary>);
			for(var i=0; i<responseCodes.size(); i++) {
				codes.add(Code.fromResponseData(i, responseCodes[i]));
				log.debug("code #{} \"{}\" received.", [i, responseCodes[i]["name"]]);
			}
			settings.storeCodes(codes);
			_vibrate();
			settings.state = :READY;
		} else {
			settings.state = :ERROR;
			log.debug("Error while loading user ({})", [responseCode]);
			// nothing to do, data will be loaded next time
		}
		log.debug("<<< loadUser", null);
		WatchUi.requestUpdate();
	}

	private function _vibrate() {
		if (settings.vibrate && Attention has :vibrate) {
			Attention.vibrate([new Attention.VibeProfile(50, 1000)]);
		}
	}
}