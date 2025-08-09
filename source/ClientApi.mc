import Toybox.Attention;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class ClientApi {

	public static var INSTANCE = new ClientApi();

	private static var settings = Settings.INSTANCE;
	private static var log = Logger.INSTANCE;

	private function getServerUrl(latlng as Dictionary?) {
		var serverUrl = settings.serverUrl;
		if(isNullOrEmpty(serverUrl)) {
			serverUrl = "https://data-manager-api.qrcode.macherel.fr/users/{TOKEN}/qrcodes?v=" + settings.version;
		}
		serverUrl += (serverUrl.find("?") == null ? "?" : "&") + "v=" + settings.version;
		if(latlng != null) {
			serverUrl += "&lat=" + latlng[:lat];
			serverUrl += "&lng=" + latlng[:lng];
		}
		if(settings.size > 0) {
			serverUrl += "&size=" + settings.size;
		}

		return stringReplace(serverUrl, "{TOKEN}", settings.token);
	}

	public function loadUser(latlng as Dictionary?) {
		var strUrl = getServerUrl(latlng);
		log.debug(">>> loadUser - {}", [strUrl]);
		if(settings.state != State.READY) {
			settings.state = State.LOADING;
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
    public function onReceive(responseCode as Number, data as Dictionary<String, Object?> or String or Toybox.PersistedContent.Iterator or Null) as Void {
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
			settings.state = State.READY;
		} else {
			settings.state = State.ERROR;
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