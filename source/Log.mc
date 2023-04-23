import Toybox.Lang;

class Logger {

    public static var INSTANCE = new Logger();

    private function stringReplace(string as String, pattern as String, value as Object) as String {
        var index = string.find(pattern);
        if (index != null) {
            var index2 = index + pattern.length();
            return string.substring(0, index) + value + string.substring(index2, string.length());
        }
        return string;
    }

    public function debug(message as String, parameters as Array<Object>?) as Void {
        if(!Settings.INSTANCE.debug) { return; }

        var formattedMessage = message;
        if(parameters != null) {
            for(var i=0; i<parameters.size(); i++) {
                formattedMessage = stringReplace(formattedMessage, "{}", parameters[i]);
            }
        }
        System.println(formattedMessage);
    }
}