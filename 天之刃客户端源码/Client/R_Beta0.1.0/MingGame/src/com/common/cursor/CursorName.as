package com.common.cursor
{
	import com.common.cursor.cursors.AttrackCursor;
	import com.common.cursor.cursors.ButtonMoveCursor;
	import com.common.cursor.cursors.CollectCursor;
	import com.common.cursor.cursors.EnduranceCursor;
	import com.common.cursor.cursors.FollowCursor;
	import com.common.cursor.cursors.HammerCursor;
	import com.common.cursor.cursors.HandCursor;
	import com.common.cursor.cursors.MagicHandCursor;
	import com.common.cursor.cursors.MagnifierCursor;
	import com.common.cursor.cursors.PickCursor;
	import com.common.cursor.cursors.SelectTargetCursor;
	import com.common.cursor.cursors.TalkCursor;
	import com.common.cursor.cursors.TradeCursor;
	import com.common.cursor.cursors.TransmissionCursor;
	import com.common.cursor.cursors.TransmissionCursor1;

	public class CursorName
	{
		public static const HAMMER:String = "hammer"; //修理工具
		public static const TALK:String = "talk"; //NPC对话
		public static const ATTRACK:String = "attrack"; //NPC对话
		public static const PICK:String = "pick"; //拾取手型
		public static const ENDURANCE:String = "endurance"; //增强道具耐久度
		public static const FOLLOW:String = "follow"; //跟随
		public static const MAGNIFIER:String = "magnifier"; //放大镜
		public static const SELL:String = "SELL"; //出售
		public static const SELECT_TARGET:String = "selectTarget"
		public static const TRANSMISSION:String = "transmission"; //传送点
		public static const TRANSMISSION_1:String = "transmission1"; //传送
		public static const BUTTON_MODE:String = "buttonMode"; //传送
		public static const HAND:String = "hand"; //手型
		public static const COLLECT:String = "chutou"; //收集手势
		public static const MAGIC_HAND:String = "MAGIC_HAND"; //魔法手势(用来将对方变身)
		public static const SPLIT:String = "SPLIT"; //出售
		
		public static var inited:Boolean = init();
		
		public static function init():Boolean{
			var cursorManager:CursorManager = CursorManager.getInstance();
			cursorManager.registerCursor(HAMMER,HammerCursor);
			cursorManager.registerCursor(TALK,TalkCursor);
			cursorManager.registerCursor(ATTRACK,AttrackCursor);
			cursorManager.registerCursor(PICK,PickCursor);
			cursorManager.registerCursor(ENDURANCE,EnduranceCursor);
			cursorManager.registerCursor(FOLLOW,FollowCursor);
			cursorManager.registerCursor(MAGNIFIER,MagnifierCursor);
			cursorManager.registerCursor(SELL,TradeCursor);
			cursorManager.registerCursor(SELECT_TARGET,SelectTargetCursor);
			cursorManager.registerCursor(TRANSMISSION,TransmissionCursor);
			cursorManager.registerCursor(TRANSMISSION_1,TransmissionCursor1);
			cursorManager.registerCursor(BUTTON_MODE,ButtonMoveCursor);
			cursorManager.registerCursor(HAND,HandCursor);
			cursorManager.registerCursor(COLLECT,CollectCursor);
			cursorManager.registerCursor(MAGIC_HAND,MagicHandCursor);
			cursorManager.registerCursor(SPLIT,HandCursor);
			return true;
		}
	}
}