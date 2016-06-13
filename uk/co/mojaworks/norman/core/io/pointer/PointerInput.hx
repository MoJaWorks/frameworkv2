package uk.co.mojaworks.norman.core.io.pointer;
import geoff.event.PointerButton;
import geoff.math.Vector2;
import msignal.Signal.Signal2;
import uk.co.mojaworks.norman.core.io.pointer.Pointer;

/**
 * ...
 * @author Simon
 */
 
class PointerInput
{
	
	public static inline var MAX_TOUCH_POINTS : Int = 5;
	public static inline var MAX_BUTTONS : Int = 5;
	
	public var scroll : Signal2<Int,Vector2>;
	public var down : Signal2<Int,PointerButton>;
	public var up : Signal2<Int,PointerButton>;
	
	var _pointers : Array<Pointer>;
	
	public function new() 
	{
		_pointers = [];
		for ( i in 0...MAX_TOUCH_POINTS ) 
		{
			_pointers.push( new Pointer( i ) );
		}
		
		down = new Signal2<Int,PointerButton>();
		up = new Signal2<Int,PointerButton>();
		scroll = new Signal2<Int,Vector2>();
		
	}
	
	public function get( id : Int ) : Pointer
	{
		if ( id >= 0 && id < PointerInput.MAX_TOUCH_POINTS ) {
			return _pointers[id];
		}
		
		return null;
	}
	
	public function anyPointerIsDown() 
	{
		for ( pointer in _pointers ) 
		{
			if ( pointer.buttonIsDown( PointerButton.Left ) )
			{
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Get mouse input from system events
	 */
	
	@:allow( uk.co.mojaworks.norman.NormanApp )
	private function onMouseDown( x : Float, y : Float, button : PointerButton ) : Void {
		_pointers[0].updateButtonState( button, true );
		_pointers[0].position.setTo( x, y );
		down.dispatch( 0, button );
	}
	
	@:allow( uk.co.mojaworks.norman.NormanApp )
	private function onMouseUp( x : Float, y : Float, button : PointerButton ) : Void {
		_pointers[0].updateButtonState( button, false );
		_pointers[0].position.setTo( x, y );
		up.dispatch( 0, button );
	}
	
	@:allow( uk.co.mojaworks.norman.NormanApp )
	private function onMouseMove( x : Float, y : Float ) : Void {
		_pointers[0].position.setTo( x, y );
	}
	
	@:allow( uk.co.mojaworks.norman.NormanApp )
	private function onMouseScroll( deltaX : Float, deltaY : Float ) : Void {	
		_pointers[0].scrollDelta.x += deltaX;
		_pointers[0].scrollDelta.y += deltaY;
		scroll.dispatch( 0, _pointers[0].scrollDelta );
	}
	
	@:allow( uk.co.mojaworks.norman.NormanApp )
	private function endFrame( ) : Void {
		for ( pointer in _pointers ) 
		{
			pointer.endFrame();
		}
	}
	
}