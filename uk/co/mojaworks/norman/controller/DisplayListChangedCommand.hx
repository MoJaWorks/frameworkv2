package uk.co.mojaworks.norman.controller;

import uk.co.mojaworks.norman.components.Transform.DisplayListAction;
import uk.co.mojaworks.norman.core.switchboard.MessageData;
import uk.co.mojaworks.norman.core.switchboard.SimpleCommand;
import uk.co.mojaworks.norman.systems.Systems;

/**
 * ...
 * @author Simon
 */
class DisplayListChangedCommand extends SimpleCommand
{

	public function new() 
	{
		super();
		
	}
	
	override function action(messageData:MessageData):Void 
	{
		super.action(messageData);
		
		var action : DisplayListAction = cast messageData.data;
		
		if ( action != DisplayListAction.Removed ) {
			// For these it currently doesnt matter if items are removed - only added or moved
			Core.instance.view.displayListChanged();
			Systems.ui.displayListChanged();
		}
	}
	
}