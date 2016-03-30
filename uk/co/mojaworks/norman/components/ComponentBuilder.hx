package uk.co.mojaworks.norman.components;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.TypeTools;

/**
 * ...
 * @author Simon
 */
class ComponentBuilder
{

	public static macro function build() : Array<Field>
	{
		//trace("Building", Context.getLocalClass() );
		
		var local : String = Context.getLocalClass().toString();
		var current = Context.getLocalClass();
		var subclasses : Array<String> = [ "^" + current.toString() + "$" ];
		var complex = TypeTools.toComplexType( Context.getLocalType() );
		
		while ( current.get().superClass != null && current.get().superClass.t.toString() != "uk.co.mojaworks.norman.components.Component" )
		{
			current = current.get().superClass.t;
			subclasses.push( "^" + current.toString() + "$" );
		}
		
		var fields : Array<Field> = Context.getBuildFields();
		
		fields.push( {
			name: "_IdentifiesAs",
			pos: Context.currentPos(),
			kind: FVar(macro: String, Context.makeExpr( subclasses.join("|"), Context.currentPos() )),
			access: [APublic, AStatic]
		} );
				
		//trace("Will return", local + "._IdentifiesAs.indexOf( type ) > -1" );
		
		fields.push( {
			name: "_identifiesAs",
			pos: Context.currentPos(),
			access: [APublic, AOverride],
			kind: FFun( {
				ret: macro: Bool,
				params: [],
				args: [ { name: "type", type: macro: String } ],
				expr: {
					expr: EReturn( {
						expr: Context.parse( "__identifiesAs( type, " + local + "._IdentifiesAs )", Context.currentPos() ).expr,
						pos: Context.currentPos()
					}),
					pos: Context.currentPos()
				}
			})
		});
		
		
		
		
		fields.push( {
			name: "getFromObject",
			pos: Context.currentPos(),
			access: [APublic, AStatic],
			kind: FFun( {
				ret: complex,
				params: [],
				args: [{name: "object", type: macro:uk.co.mojaworks.norman.factory.GameObject}],
				expr: {
					expr: EReturn( {
						expr: Context.parse( "cast object._getComponent( \"" + local + "\" )", Context.currentPos() ).expr,
						pos: Context.currentPos()
					}),
					pos: Context.currentPos()
				}
			})
		});
		
		return fields;
	}
	
}