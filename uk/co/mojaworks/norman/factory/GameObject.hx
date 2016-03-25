package uk.co.mojaworks.norman.factory;
import uk.co.mojaworks.norman.components.Component;
import uk.co.mojaworks.norman.components.Transform;
import uk.co.mojaworks.norman.components.renderer.BaseRenderer;
import uk.co.mojaworks.norman.utils.LinkedList;

/**
 * GameObject is nothing more than a bag of components
 * ...
 * @author Simon
 */
class GameObject implements IDisposable
{
	private static var autoId : Int = 0;
	
	public var id( default, null ) : Int;
	public var name( default, default ) : String;
	public var destroyed : Bool = false;
	public var enabled( default, set ) : Bool = true;
	
	// Quick access
	public var transform( default, null ) : Transform = null;
	public var renderer( default, null ) : BaseRenderer = null;
		
	var components : LinkedList<Component>;
	
	@:allow( uk.co.mojaworks.norman.factory.ObjectFactory )
	private function new( name : String )
	{
		this.id = autoId++;
		this.name = name;
		components = new LinkedList<Component>();
	}
		
	public function getComponent( type : String ) : Component {
		for ( component in components ) {
			if ( component.getComponentType() == type || component.getBaseComponentType() == type ) return component;
		}
		return null;
	}
	
	#if !display @:generic #end public function getThing<T:Component>( type : Class<T> ) : T 
	{
		for ( component in components ) {
			if ( Std.is( component, type ) ) return cast component;
		}
		return null;
	}
	
	public function addComponent( component : Component ) : Component {
		component.gameObject = this;
		components.push( component );
		
		switch ( component.getBaseComponentType() ) {
			case BaseRenderer.TYPE:
				this.renderer = cast component;
			case Transform.TYPE:
				this.transform = cast component;
		}
		
		component.onAdded();
		return component;
	}
	
	public function removeComponent( component : Component ) : Void {
		component.onRemove();
		components.remove( component );
		component.gameObject = null;
		
		switch ( component.getBaseComponentType() ) {
			case BaseRenderer.TYPE:
				this.renderer = cast getComponent( BaseRenderer.TYPE );
			case Transform.TYPE:
				this.transform = cast getComponent( Transform.TYPE );
		}
	}
		
	public function removeAllComponentsOfType( type : String ) : Void {
		for ( component in components ) {
			if ( component.getComponentType() == type || component.getBaseComponentType() == type ) {
				removeComponent( component );
			}
		}
	}
	
	public function destroy( ) : Void {
						
		if ( !destroyed ) {
			
			for ( child in transform.children ) {
				child.gameObject.destroy();
			}
			
			destroyed = true;
			
			for ( component in components ) {
				removeComponent( component );
				component.destroy();
			}
			
			components = null;
			transform = null;
			renderer = null;
		}
		
	}
	
	public function getAllComponentsOfType( type : String ) : Array<Component> 
	{
		var result : Array<Component> = [];
		for ( component in components ) {
			if ( component.getComponentType() == type || component.getBaseComponentType() == type ) result.push( component );
		}
		return result;
	}
	
	public function getAllComponentsOfTypeFromChildren( type : String, includeThisObject : Bool = true, useArray : Array<Component> = null ) : Array<Component> 
	{
		var result : Array<Component>;
		
		if ( useArray != null ) {
			result = useArray;
		}else {
			result = [];
		}
		
		if ( includeThisObject ) {
			for ( component in components ) {
				if ( component.getComponentType() == type || component.getBaseComponentType() == type ) result.push( component );
			}
		}
		
		for ( child in transform.children ) {
			child.gameObject.getAllComponentsOfTypeFromChildren( type, true, result );
		}
		
		return result;
	}
	
	public function isEnabled() : Bool {
		
		if ( enabled && transform.parent != null ) {
			return transform.parent.gameObject.isEnabled();
		}else {
			return enabled;
		}
	}
	
	public function set_enabled( bool : Bool ) : Bool {
		return this.enabled = bool;
	}
	
}