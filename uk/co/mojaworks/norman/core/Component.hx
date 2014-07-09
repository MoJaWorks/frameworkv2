package uk.co.mojaworks.norman.core;
import haxe.ds.StringMap;

/**
 * ...
 * @author Simon
 */
#if !macro @:autoBuild( uk.co.mojaworks.norman.core.ComponentBuilder.build() ) #end
class Component extends CoreObject
{
	
	public var gameObject : GameObject;
	
	private function new() 
	{
		super();
	}

	public function getComponentType() : String {
		return "";
	}
	
	public function onUpdate( seconds : Float ) : Void {
		
	}
	
	public function onAdded( ) : Void {
		
	}
	
	public function onRemoved( ) : Void {
		
	}
		
	public function destroy() : Void {
		
	}
	
}