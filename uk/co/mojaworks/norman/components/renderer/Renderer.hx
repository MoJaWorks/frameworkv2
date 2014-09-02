package uk.co.mojaworks.norman.components.renderer ;

import openfl.display.DisplayObject;
import openfl.display.OpenGLView;
import openfl.events.Event;
import openfl.geom.Rectangle;
import uk.co.mojaworks.norman.components.messenger.MessageData;
import uk.co.mojaworks.norman.core.Component;
import uk.co.mojaworks.norman.core.GameObject;

/**
 * ...
 * @author Simon
 */
class Renderer extends Component {

	var _canvas : ICanvas;
	public var textureManager( default, null ) : TextureManager;
	
	public function new() 
	{
		super();	
	}
	
	public function init( screenRect : Rectangle ) : Void {
		#if (!flash)
			_canvas = new uk.co.mojaworks.norman.components.renderer.gl.GLCanvas();
			textureManager = new uk.co.mojaworks.norman.components.renderer.gl.GLTextureManager();
			root.messenger.attachListener( OpenGLView.CONTEXT_RESTORED, onContextRestored );
			trace("Using GL renderer");
		#else
			_canvas = new uk.co.mojaworks.norman.components.renderer.stage3d.Stage3DCanvas();
			textureManager = new uk.co.mojaworks.norman.components.renderer.stage3d.Stage3DTextureManager();
			root.messenger.attachListener( Event.CONTEXT3D_CREATE, onContextRestored );
			trace("Using Stage3D renderer");
		#end
		
		_canvas.init( screenRect );
		resize( screenRect );
	}
	
	public function onContextRestored( param : MessageData ) : Void {
		#if ( flash ) 
			cast( textureManager, uk.co.mojaworks.norman.components.renderer.stage3d.Stage3DTextureManager ).setContext( cast( _canvas, uk.co.mojaworks.norman.components.renderer.stage3d.Stage3DCanvas ).getContext() );
		#end
		textureManager.restoreTextures();
	}
	
	public function render( root : GameObject ) 
	{
		_canvas.render( root );
	}
	
	public function resize( rect : Rectangle ) {
		_canvas.resize(rect);
	}
	
	public function getDisplayObject() : DisplayObject {
		return _canvas.getDisplayObject();
	}
	
}