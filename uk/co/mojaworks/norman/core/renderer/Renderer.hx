package uk.co.mojaworks.norman.core.renderer;
import lime.graphics.Image;
import lime.graphics.RenderContext;
import uk.co.mojaworks.norman.components.renderer.BaseRenderer;
import uk.co.mojaworks.norman.components.Transform;
import uk.co.mojaworks.norman.core.renderer.Canvas;
import uk.co.mojaworks.norman.core.renderer.ShaderData;
import uk.co.mojaworks.norman.core.renderer.ShaderManager;
import uk.co.mojaworks.norman.core.renderer.TextureManager;
import uk.co.mojaworks.norman.utils.Color;

/**
 * ...
 * @author test
 */
class Renderer
{

	public var clearColor : Color = Color.BLACK;
	
	public var canvas( default, null ) : Canvas;
	public var shaderManager( null, null ) : ShaderManager;
	public var textureManager( null, null ) : TextureManager;
	
	//////////////
	///  INIT
	/////////////
	
	public function new() {
		textureManager = new TextureManager();
	}
	
	public function init( context : RenderContext ) 
	{
		
		trace("Initializing renderer", context.getName() );
		
		switch (context) 
		{
			case OPENGL(gl):
				
				trace("Checking for initial errors", gl.getError() );
				
				canvas = new Canvas();
				canvas.init( );
				canvas.onContextCreated( gl );
				
				shaderManager = new ShaderManager();
				shaderManager.init( );
				shaderManager.onContextCreated( gl );
				
				textureManager = new TextureManager();
				textureManager.init();
				textureManager.onContextCreated( gl );
				
			case FLASH(sprite):
				// TODO: Set up Stage3D  render system (eventually, maybe never)
			case CANVAS(context):
				// TODO: Set up canvas render system (never)
			case DOM(context):
				// TODO: Set up DOM render system (never)
			default:
		}
		
	}
	
	//////////////
	///  RENDER
	/////////////
	

	public function render( root : Transform ) : Void {
		
		//trace("Render begin");
		canvas.clear( clearColor );
		
		canvas.begin();
			renderLevel( root );
		canvas.end();
	}
	
	public function renderLevel( transform : Transform ) : Void {
		
		//trace("Rendering level starting at", sprite.transform.x, sprite.transform.y );
		
		if ( transform.gameObject.enabled ) {
		
			var sprite : BaseRenderer = transform.gameObject.renderer;
					
			if ( sprite != null ) 
			{
				sprite.preRender( canvas );
				if ( sprite.visible && sprite.getCompositeAlpha() > 0 ) {
					
					if ( sprite.color.a > 0 ) sprite.render( canvas );
					
					if ( sprite.shouldRenderChildren ) {
						for ( child in transform.children ) {
							renderLevel( child );
						}
					}
					
				}
				sprite.postRender( canvas );
			}
			else 
			{
				for ( child in transform.children ) {
					renderLevel( child );
				}
			}
		}
		
	}
	
	//////////////
	///  TEXTURES
	/////////////
	
	public function createTextureFromAsset( id : String ) : TextureData {
		return textureManager.createTextureFromAsset( id );
	}
	
	public function createTextureFromImage( id : String, image : Image, map : Dynamic = null ) : TextureData {
		return textureManager.createTextureFromImage( id, image, map );
	}
	
	public function createTexture( id : String, width : Int, height : Int, fill : Color ) : TextureData {
		return textureManager.createTexture( id, width, height, fill );
	}
	
	public function unloadTexture( id : String ) : Void {
		return textureManager.unloadTexture( id );
	}
	
	
	//////////////
	///  SHADERS
	/////////////
	
	/**
	 * Create a shader to use in drawer operations
	 * @param	vertexSource
	 * @param	fragmentSource
	 * @return
	 */
	
	public function createShader( vertexSource : String, fragmentSource : String, attributes : Array<ShaderAttributeData> ) : ShaderData {
		return shaderManager.createShader( vertexSource, fragmentSource, attributes );
	}
	
}