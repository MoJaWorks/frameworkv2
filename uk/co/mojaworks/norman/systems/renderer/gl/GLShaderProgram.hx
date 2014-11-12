package uk.co.mojaworks.norman.systems.renderer.gl ;
import lime.graphics.GLRenderContext;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.RenderContext;
import lime.utils.GLUtils;
import uk.co.mojaworks.norman.systems.renderer.shaders.IShaderProgram;
import uk.co.mojaworks.norman.systems.renderer.shaders.ShaderData;

/**
 * ...
 * @author Simon
 */
class GLShaderProgram implements IShaderProgram
{
	
	private var _fsData : ShaderData;
	private var _vsData : ShaderData;
	
	public var program( default, null ) : GLProgram;
	
	/**
	 *
	 */

	public function new( vertexShader:ShaderData, fragmentShader:ShaderData ) 
	{
		_fsData = fragmentShader;
		_vsData = vertexShader;
	}
	
	/**
	 * 
	 */
	
	public function compile( ctx : RenderContext ) : Void
	{
		
		var context : GLRenderContext = cast ctx;
		
		if ( program != null ) context.deleteProgram( program );
		
		var vs : GLShader = context.createShader( GL.VERTEX_SHADER );
		context.shaderSource( vs, _vsData.getGLSL() );
		context.compileShader( vs );
		
		#if gl_debug
			trace("Compiling vertex shader");
			trace( context.getShaderInfoLog( vs ) );
		#end
		
		var fs : GLShader = context.createShader( GL.FRAGMENT_SHADER );
		context.shaderSource( fs, _fsData.getGLSL() );
		context.compileShader( fs );
		
		#if gl_debug
			trace("Compiling fragment shader");
			trace( context.getShaderInfoLog( fs ) );
		#end
		
		program = context.createProgram();
		context.attachShader( program, vs );
		context.attachShader( program, fs );
		context.linkProgram( program );
		
		#if gl_debug
			trace("Linking shader");
			trace( context.getProgramInfoLog( program ) );
		#end
		
		context.deleteShader(vs);
		context.deleteShader(fs);
		
	}
	
	/**
	 * 
	 */
	
	public function getUsesColor():Bool 
	{
		return _vsData.usesColor;
	}
	
	/**
	 * 
	 * @return
	 */
	
	public function getNumTextures():Int 
	{
		return Std.int(Math.max( _vsData.numTextures, _fsData.numTextures));
	}
		
}