package uk.co.mojaworks.norman.components ;

import lime.math.Matrix3;
import lime.math.Vector2;
import uk.co.mojaworks.norman.components.display.Display;
import uk.co.mojaworks.norman.core.Component;

/**
 * ...
 * @author Simon
 */
class Transform extends Component
{

	public static inline var CHILD_ADDED : String = "CHILD_ADDED";
	public static inline var CHILD_REMOVED : String = "CHILD_REMOVED";
	static public inline var ADDED_AS_CHILD : String = "ADDED_AS_CHILD";
	static public inline var REMOVED_AS_CHILD : String = "REMOVED_AS_CHILD";
	
	public static inline var MATRIX_DIRTY : String = "MATRIX_DIRTY";
	
	public var parent( default, set ) : Transform;
	public var children( default, null ) : Array<Transform>;
	
	public var x( default, set ) : Float = 0;
	public var y( default, set ) : Float = 0;
	public var z( default, default ) : Float = 0; // This is not a 3d matrix component, only used for sorting
	
	public var pivotX( default, set ) : Float = 0;
	public var pivotY( default, set ) : Float = 0;
	
	public var paddingX( default, set ) : Float = 0;
	public var paddingY( default, set ) : Float = 0;
	
	public var scaleX( default, set ) : Float = 1;
	public var scaleY( default, set ) : Float = 1;
	
	public var rotation( default, set ) : Float = 0;
	
	public var worldTransform( get, never ) : Matrix3;
	public var inverseWorldTransform( get, never ) : Matrix3;
	public var localTransform( get, never ) : Matrix3;
	public var renderTransform( get, never ) : Matrix3;
	
	var _worldTransform : Matrix3;
	var _inverseWorldTransform : Matrix3;
	var _localTransform : Matrix3;
	var _renderTransform : Matrix3;
	
	var _isLocalDirty : Bool = true;
	var _isWorldDirty : Bool = true;
	
	public function new() 
	{
		super();
		
		_worldTransform = new Matrix3();
		_localTransform = new Matrix3();
		_inverseWorldTransform = new Matrix3();
		_renderTransform = new Matrix3();
		
		children = new Array<Transform>();
	}
	
	//override public function onAdded():Void 
	//{
		//super.onAdded();
		////trace("OnAdded", gameObject.messenger );
		//gameObject.messenger.attachListener( GameObject.ADDED_AS_CHILD, onParentChanged );
		//gameObject.messenger.attachListener( GameObject.REMOVED_AS_CHILD, onParentChanged );
	//}
	//
	//override public function onRemoved():Void 
	//{
		//super.onRemoved();
		////trace("OnAdded", gameObject.messenger );
		//gameObject.messenger.removeListener( GameObject.ADDED_AS_CHILD, onParentChanged );
		//gameObject.messenger.removeListener( GameObject.REMOVED_AS_CHILD, onParentChanged );
	//}
	//
	//private function onParentChanged( data : MessageData ) : Void {
		//invalidateMatrices();
	//}
	
	public function invalidateMatrices( local : Bool = true, world : Bool = true ) : Void {
		
		var update : Bool = !_isLocalDirty && !_isWorldDirty;
		_isLocalDirty = local;
		_isWorldDirty = world;
		
		if ( update ) {
			for ( child in gameObject.children ) {
				child.transform.invalidateMatrices( false, true );
			}
		}
		
		gameObject.messenger.sendMessage( MATRIX_DIRTY );
	}	
	
	private function recalculateLocalTransform() : Void {
		_localTransform.identity();
		_localTransform.translate( paddingX, paddingY );
		_localTransform.translate( -pivotX, -pivotY );
		_localTransform.scale( scaleX, scaleY );
		_localTransform.rotate( rotation );
		_localTransform.translate( x, y );
		_isLocalDirty = false;
	}
	
	private function recalculateWorldTransform() : Void {
		
		if ( _isLocalDirty ) recalculateLocalTransform();
		_worldTransform.copyFrom( _localTransform );
		_renderTransform.identity();
		
		// If an object is masked, global transforms will all be in this coordinate
		var isMasked : Bool = gameObject.display != null && gameObject.display.clipRect != null;
		
		if ( gameObject.parent != null ) {
			_worldTransform.concat( gameObject.parent.transform.worldTransform );
			if ( !isMasked ) {
				_renderTransform.copyFrom( _localTransform );
				_renderTransform.concat( gameObject.parent.transform.renderTransform );
			}else {
				_renderTransform.translate( -gameObject.display.clipRect.x, -gameObject.display.clipRect.y );
			}
		}else {
			_renderTransform.copyFrom( _worldTransform );
		}
			
		_inverseWorldTransform.copyFrom(_worldTransform);
		_inverseWorldTransform.invert();
		
		_isWorldDirty = false;
		
	}
	
	/**
	 * Centers the pivot based on the display
	 */
	public function centerPivot() : Transform {
		if ( gameObject.has(Display) ) {
			setPivot( gameObject.display.getNaturalWidth() * 0.5, gameObject.display.getNaturalHeight() * 0.5 );
		}else {
			setPivot(0, 0);
		}
		
		return this;
	}
	
	/**
	 * Convenience
	 */
	
	public function setPosition( x : Float, y : Float ) : Transform {
		this.x = x;
		this.y = y;
		return this;
	}
	
	public function setScale( scale : Float ) : Transform {
		this.scaleX = this.scaleY = scale;
		return this;
	}
	
	public function setScaleXY( scaleX : Float, scaleY : Float ) : Transform {
		this.scaleX = scaleX;
		this.scaleY = scaleY;
		return this;
	}
	
	public function setPivot( x : Float, y : Float ) : Transform {
		pivotX = x;
		pivotY = y;
		return this;
	}
	
	public function setPadding( x : Float, y : Float ) : Transform {
		paddingX = x;
		paddingY = y;
		return this;
	}
	
	/**
	 * Getters
	 */
	
	private function get_worldTransform( ) : Matrix3 {
		
		if ( _isWorldDirty || _isLocalDirty ) {
			recalculateWorldTransform();
		}
		return _worldTransform;
	}
	
	private function get_localTransform( ) : Matrix3 {
		
		if ( _isLocalDirty ) {
			recalculateLocalTransform();
		}
		return _localTransform;
	}
	
	private function get_inverseWorldTransform( ) : Matrix3 {
		
		if ( _isWorldDirty || _isLocalDirty ) {
			recalculateWorldTransform();
		}
		return _inverseWorldTransform;
	}
	
	private function get_renderTransform() : Matrix3 {
		
		if ( _isWorldDirty || _isLocalDirty ) {
			recalculateWorldTransform();
		}
		return _renderTransform;
	}
	
	public function localToGlobal( point : Vector2 ) : Vector2 {
		return worldTransform.transformPoint( point );
	}
	
	public function globalToLocal( point : Vector2 ) : Vector2 {
		return inverseWorldTransform.transformPoint( point );
	}
	
	/**
	 * Setters
	 */
		
	private function set_x( _x : Float ) : Float { x = _x; invalidateMatrices(); return x; }
	private function set_y( _y : Float ) : Float { y = _y; invalidateMatrices(); return y; }
	private function set_pivotX( _pivotX : Float ) : Float { pivotX = _pivotX; invalidateMatrices(); return pivotX; }
	private function set_pivotY( _pivotY : Float ) : Float { pivotY = _pivotY; invalidateMatrices(); return pivotY; }
	private function set_paddingX( _paddingX : Float ) : Float { paddingX = _paddingX; invalidateMatrices(); return paddingX; }
	private function set_paddingY( _paddingY : Float ) : Float { paddingY = _paddingY; invalidateMatrices(); return paddingY; }
	private function set_scaleX( _scaleX : Float ) : Float { scaleX = _scaleX; invalidateMatrices(); return scaleX; }
	private function set_scaleY( _scaleY : Float ) : Float { scaleY = _scaleY; invalidateMatrices(); return scaleY; }
	private function set_rotation( _rotation : Float ) : Float { rotation = _rotation; invalidateMatrices(); return rotation; }
	
	
	/**
	 * CHILDREN
	 */
	
	public function addChild( child : Transform ) : Void {
		
		if ( child.parent != null ) {
			child.parent.removeChild( child );
		}
		child.parent = this;
		children.push( child );
		gameObject.messenger.sendMessage( CHILD_ADDED, child.gameObject );
		child.gameObject.messenger.sendMessage( ADDED_AS_CHILD );
		
	}
	
	public function removeChild( child : Transform ) : Void {
		
		children.remove( child );
		gameObject.messenger.sendMessage(CHILD_REMOVED, child.gameObject);
		child.gameObject.messenger.sendMessage(REMOVED_AS_CHILD);
		child.parent = null;
		
	}
	
	public function set_parent( parent : Transform ) : Transform {
		
		parent.addChild( this );
		
	}
	
}