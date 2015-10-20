package uk.co.mojaworks.norman.systems.director;
import uk.co.mojaworks.norman.components.delegates.BaseViewDelegate;
import uk.co.mojaworks.norman.components.Transform;
import uk.co.mojaworks.norman.factory.GameObject;
import uk.co.mojaworks.norman.factory.ObjectFactory;

/**
 * ...
 * @author Simon
 */

enum DisplayListAction {
	Added;
	Removed;
	Swapped;
	All;
}
 
class Director
{
	
	public static inline var SCREEN_LAYER : String = "DirectorScreensLayer";
	public static inline var MENU_LAYER : String = "DirectorMenuLayer";
	
	public var rootObject : GameObject;
	public var objects : Map<String,GameObject>;
	
	var _layers : Array<Transform>;
	var _displayStack : Array<BaseViewDelegate>;
	
	public function new() 
	{
		objects = new Map<String,GameObject>();
		_displayStack = [];
		_layers = [];
		
		rootObject = ObjectFactory.createGameObject( "Root" );
	}
	
	/**
	 * Screens
	 */
	
	public function moveToScreen( screen : GameObject, transition : Transition = null, delay : Float = 0 ) : Void {
		
		if ( transition == null ) transition = new Transition();
		transition.transition( screen, _displayStack, delay );
		
		_displayStack = [];
		_displayStack.push( cast screen.getComponent(BaseViewDelegate.TYPE) );
		
		getLayer(SCREEN_LAYER).addChild( screen.transform );
		
	}
	
	public function addScreen( screen : GameObject, transition : Transition = null, delay : Float = 0 ) : Void {
		
		if ( transition == null ) transition = new Transition();
		transition.transition( screen, null, delay );
		
		_displayStack.push( BaseViewDelegate.getFromObject(screen) );
		getLayer(SCREEN_LAYER).addChild( screen.transform );
	}
		
	
	/**
	 * Sprites
	 */
		
	public function registerObject( obj : GameObject ) : Void {
		objects.set( obj.id, obj );
	}
	
	public function getObjectWithID( id : String ) : GameObject {
		return objects.get( id );
	}
		
	public function removeObject( id : String ) : Void {
		objects.remove( id );
	}
	
	
	/**
	 * Layers
	 */
	
	public function createLayer( name : String, index = -1 ) : Transform {
		
		//var spr : Sprite = new Sprite();
		//spr.name = name;
		var layer : GameObject = ObjectFactory.createGameObject( "/@normanLayers/" + name );
		var trans : Transform = layer.transform;
		
		if ( index > -1 ) {
			_layers.insert( index, trans );
		}else {
			_layers.push( trans );
		}
		
		rootObject.transform.addChild( trans );
		return trans;
		
	}
	
	public function removeLayer( name : String ) : Void {
		
		var layer : Transform = getLayer( name );
		
		if ( layer != null ) {
			_layers.remove( layer );
			layer.destroy();
		}		
		
	}
	
	/**
	 * Gets a layer - creates a new one if it doesn't already exist
	 * @return
	 */
	public function getLayer( name : String ) : Transform {
		
		for ( l in _layers ) {
			if ( l.gameObject.id == "/@normanLayers/" + name ) {
				return l;
			}
		}
		
		return createLayer( name );
		
	}
		
	
	/**
	 * Ongoing
	 */
	
	
	public function update( seconds : Float ) : Void 
	{
		for ( screen in _displayStack ) {
			screen.update( seconds );
		}
	}
	
	public function resize() : Void {
				
		rootObject.transform.scaleX = Systems.viewport.scale;
		rootObject.transform.scaleY = Systems.viewport.scale;
		rootObject.transform.x = Systems.viewport.marginLeft * Systems.viewport.scale;
		rootObject.transform.y = Systems.viewport.marginTop * Systems.viewport.scale;
		
		for ( screen in _displayStack ) {
			screen.resize();
		}

	}
	
	public function displayListChanged() 
	{
		rootObject.transform.updateDisplayOrder(0);
	}
	
}