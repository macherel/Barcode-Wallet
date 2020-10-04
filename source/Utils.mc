function join(array, char) {
	var result = array[0];
	for(var i=1; i<array.size(); i++) {
		result += char + array[i];
	}
	return result;
}

function stringReplace(str, oldString, newString)
{
	var result = str;
	var start = result.find(oldString);

	while (start != null) {
		var end = start + oldString.length();
		result = result.substring(0, start) + newString + result.substring(end, result.length());

		start = result.find(oldString);
	}

	return result;
}

function isNullOrEmpty(str) {
	return str == null || str.length() == 0;
}
