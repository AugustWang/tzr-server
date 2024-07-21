package modules.team.view
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.Dictionary;

	public class TeamListSprite extends Sprite
	{
		private var _hash:Dictionary;

		public function TeamListSprite()
		{
			super();
			_hash=new Dictionary;
		}

		override public function addChild(child:DisplayObject):DisplayObject
		{
			super.addChild(child);
			if (child is TeamRoleView)
			{
				if (_hash[TeamRoleView(child).pvo.role_id] == null)
				{
					_hash[TeamRoleView(child).pvo.role_id]=child;
				}
			}
			return child;
		}

		public function get hash():Dictionary
		{
			return _hash;
		}
	}
}