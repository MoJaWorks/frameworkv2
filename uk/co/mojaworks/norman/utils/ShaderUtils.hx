package uk.co.mojaworks.norman.utils;

/**
 * ...
 * @author Simon
 */
class ShaderUtils
{

	public function new() 
	{
		
	}
	
	public static function getDefaultFillVertexSource() : String {
		
		var vertexSource : String = "";
		vertexSource += "attribute vec2 aVertexPosition;";
		vertexSource += "attribute vec4 aVertexColor;";
		vertexSource += "uniform mat4 uProjectionMatrix;";
		
		vertexSource += "varying vec4 vVertexColor;";
		
		vertexSource += "void main(void) {";
		vertexSource += "  vVertexColor = aVertexColor;";
		vertexSource += "  gl_Position = uProjectionMatrix * vec4(aVertexPosition, 0.0, 1.0);";
		vertexSource += "}";
		
		return vertexSource;
		
	}
	
	public static function getDefaultFillFragSource() : String 
	{
		var fragmentSource : String = "";
		#if !desktop
			fragmentSource += "precision mediump float;";
		#end
		
		fragmentSource += "varying vec4 vVertexColor;";
		fragmentSource += "void main(void) {";
		fragmentSource += "  gl_FragColor = vVertexColor;";
		fragmentSource += "}";
		
		return fragmentSource;
	}
	
	/**
	 * Image shader
	 * @return
	 */
	
	public static function getDefaultImageVertexSource():String 
	{
		var str : String = "";
		
		str += "attribute vec2 aVertexPosition;";
		str += "attribute vec4 aVertexColor;";
		str += "attribute vec2 aVertexUV;";
		str += "uniform mat4 uProjectionMatrix;";
		
		str += "varying vec4 vVertexColor;";
		str += "varying vec2 vVertexUV;";

		str += "void main(void) {";
		str += "	vVertexColor = aVertexColor;";
		str += "	vVertexUV = aVertexUV;";
		str += "	gl_Position = uProjectionMatrix * vec4(aVertexPosition, 0.0, 1.0);";
		str += "}";
		
		return str;
	}
	
	
	public static function getDefaultImageFragSource():String 
	{
		var str : String = "";
		
		#if !desktop
			str += "precision mediump float;";
		#end

		str += "varying vec4 vVertexColor;";
		str += "varying vec2 vVertexUV;";
		str += "uniform sampler2D uTexture0;";
		
		str += "void main(void) {";
		str += "	vec4 texColor = texture2D( uTexture0, vVertexUV );";
		str += "	texColor.rgb = texColor.rgb * texColor.a;";
		str += "	gl_FragColor = vVertexColor * texColor;";
		str += "}";
		
		return str;
	}
	
}