using Toybox.Communications as Comm;
using Toybox.WatchUi as Ui;
using Toybox.Lang as Lang;
using Toybox.System as System;

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
			Settings.codes = codes;
			Ui.requestUpdate();
		} else {
			System.println("Error while loading QR codes (" + responseCode + ")");
			// nothing to do, data will be loaded next time
		}
	}
	
	function loadUser(token) {
		var strUrl = "https://data-manager-api.qrcode.macherel.fr/users/" + Settings.token;
		System.println("Loading user from " + strUrl);
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
}