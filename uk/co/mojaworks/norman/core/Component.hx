package uk.co.mojaworks.norman.core;

/**
 * ...
 * @author Simon
 */
#if !macro @:autoBuild( uk.co.mojaworks.norman.core.ComponentBuilder.build() ) #end
class Component extends CoreObject
{
	
	public var gameObject : GameObject;
	public var enabled : Bool = true;
	
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