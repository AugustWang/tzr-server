package modules.friend.views.part
{
	public interface IChatWindow
	{
		function appendMessage(msg:String):void;
		function getFocus():void;
		function minResize():void;
		function maxReisze(newX:Number,newY:Number):void;
	}
}