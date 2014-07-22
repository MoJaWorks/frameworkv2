package uk.co.mojaworks.norman.components.display ;

import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import uk.co.mojaworks.norman.core.Component;
import uk.co.mojaworks.norman.core.GameObject;
import uk.co.mojaworks.norman.renderer.ICanvas;
import uk.co.mojaworks.norman.utils.MathUtils;

/**
 * ...
 * @author Simon
 */
class Display extends Component
{

	public var alpha : Float = 1;
	public var visible : Bool = true;
	public var clipRect( default, set ) : Rectangle = null;
	
	private var _isBoundsDirty : Bool = true;
	
	public function new() 
	{
		super();
	}
				
	/**
	 * Gets the bounds of one object in the space of another. If no space is passed, it will get it's bounds in it's own space
	 * @param	space
	 * @return
	 */
	public function getBounds( space : GameObject = null ) : Rectangle {
		
		// Get the total bounds in this coordinate space with children and clippingRect applied
		var bounds : Rectangle = getTotalBounds( gameObject );
		
		// Transform to the target coordinate space
		if ( space != null && space != gameObject ) {
			MathUtils.transformRect( bounds, gameObject.transform.worldTransform );
			MathUtils.transformRect( bounds, space.transform.inverseWorldTransform );
		}

		return bounds;
		
	}
	
	private function getTotalBounds( space : GameObject ) : Rectangle {
		
		var bounds : Rectangle = new Rectangle( 0, 0, getNaturalWidth(), getNaturalHeight() );
				
		// Get own bounds in this space
		if ( space != gameObject ) {
			MathUtils.transformRect( bounds, gameObject.transform.worldTransform );
			MathUtils.transformRect( bounds, space.transform.inverseWorldTransform );
		}
				
		// Adjust min and max for children
		for ( child in gameObject.children ) {
			if ( child.display != null ) {
				bounds = bounds.union( child.display.getTotalBounds( space ) );
			}
		}
		
		// Clip if necessary
		if ( clipRect != null ) {
			return bounds.intersection( clipRect );
		}else {
			return bounds;
		}
		
	}
	
	public function getNaturalWidth() : Float {
		return 0;
	}
	
	public function getNaturalHeight() : Float {
		return 0;
	}
	
	public function getFinalAlpha() : Float {
		if ( gameObject.parent != null ) {
			return gameObject.parent.get(Display).getFinalAlpha() * alpha;
		}else {
			return alpha;
		}
	}
		
	public function preRender( canvas : ICanvas ) : Void {
		
		trace("Prerender", clipRect);
		
		if ( clipRect != null ) {
			
			trace("Adding mask", gameObject.parent );
			
			if ( gameObject.parent != null ) {
				var transform : Matrix = gameObject.parent.transform.renderTransform.clone();
				transform.concat( gameObject.transform.localTransform );
				canvas.pushMask( getBounds(), transform );
			}else {
				canvas.pushMask( getBounds(), gameObject.transform.renderTransform );
			}
		}
	}
	
	public function render( canvas : ICanvas ) : Void {
		// Override to render content
	}
	
	public function postRender( canvas : ICanvas ) : Void {
		if ( clipRect != null ) canvas.popMask();
	}
	
	private function set_clipRect( rect : Rectangle ) : Rectangle {
		gameObject.transform.invalidateMatrices();
		this.clipRect = rect;
		return rect;
	}
		
}