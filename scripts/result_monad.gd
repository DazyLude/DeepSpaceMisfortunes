extends RefCounted
class_name Result
## small helper class to throw around additional info and error messages

var _ok : bool = true;
var _value : Variant = null;


func is_ok() -> bool:
	return _ok;


func unwrap() -> Variant:
	if not _ok:
		push_error("unwrapped \"Error\" Result. Error message was: %s" % _value);
	return _value;


func get_error() -> String:
	if _ok:
		push_error("tried to get error on \"Ok\" Result. Value was: %s" % _value);
		return "";
	
	return _value;


func is_ok_then(what: Callable) -> Result:
	if not _ok:
		return self;
	
	_value = what.call(_value);
	return self;


static func wrap_err(err_message: String) -> Result:
	var err_result := Result.new();
	
	err_result._ok = false;
	err_result._value = err_message;
	
	return err_result;


static func wrap_ok(ok_object: Variant) -> Result:
	if ok_object == null:
		push_error("tried creating a Result with a null value. For the love of god please don't");
	
	var ok_result := Result.new();
	
	ok_result._ok = true;
	ok_result._value = ok_object;
	
	return ok_result;
