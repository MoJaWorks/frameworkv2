package uk.co.mojaworks.norman.hardware;

/**
 * ...
 * @author Simon
 */

typedef AccelerometerEvent = msignal.Signal.Signal1<Array<Float>>;
 
class AccelerometerCallback {
	
	var _event : AccelerometerEvent;
	
	public function new( event : AccelerometerEvent ) {
		_event = event;
	}
	
	public function fire( x : Float, y : Float, z : Float ) {
		//trace("Callback from java ", x, y, z );
		_event.dispatch( [x,y,z] );
	}
}
 
class Accelerometer
{

	public var onAccelerometerChanged : AccelerometerEvent;
	
	var _callback : AccelerometerCallback;
	
	public function new() 
	{
		onAccelerometerChanged = new AccelerometerEvent();
		_callback = new AccelerometerCallback( onAccelerometerChanged );
	}
	
	public function init() : Void {
		// Connect to the native accelerometer
		
		#if android
			var init : Dynamic = lime.system.JNI.createStaticMethod( "uk/co/mojaworks/norman/Accelerometer", "init", "(Lorg/haxe/lime/HaxeObject;)V" );
			lime.system.JNI.callStatic( init, [_callback] );
		#end
		
	}
	
	public static function isSupported() : Bool {
		#if android
			return true;
		#else
			return false;
		#end
	}
	
}