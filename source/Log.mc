import Toybox.Lang;

class Logger {

    public static var INSTANCE = new Logger();

    private static var isDebugEnabled = false;

    private function stringReplace(string as String, pattern as String, value as Object) as String {
        var index = string.find(pattern);
        if (index != null) {
            var index2 = index + pattern.length();
            var repl = "[...]";
            try {
                repl = value.toString();
            } catch(e) {
                // Do nothing
            }
            return string.substring(0, index) + repl + string.substring(index2, string.length());
        }
        return string;
    }

    public function debug(message as String, parameters as Array<Object>?) as Void {
        if(!isDebugEnabled) { return; }

        var formattedMessage = message;
        if(parameters != null) {
            for(var i=0; i<parameters.size(); i++) {
                formattedMessage = stringReplace(formattedMessage, "{}", parameters[i]);
            }
        }
        System.println(formattedMessage);
    }
}