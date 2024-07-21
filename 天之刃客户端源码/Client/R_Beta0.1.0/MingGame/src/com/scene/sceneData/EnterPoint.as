package com.scene.sceneData {

	public class EnterPoint {

		public static const BLACKGROUND_ITEM:int=0
		public static const PLAYGROUND_ITEM:int=1
		public static const ENTER_POINT:int=2
		public static const LIVE_POINT:int=3
		public static const NPC:int=4
		public static const BOGEY:int=5;
		public static const COLLECTION:int=6;

		public var mapid:int
		public var x:int;
		public var y:int
		public var index_x:int
		public var index_y:int

		public var tar_x:int;
		public var tar_y:int;

		public var tar_index_x:int
		public var tar_index_y:int
		public var targetMapid:int
		public var type:int
		public var itemType:int
		public var id:int
		public var avatarId:String

		public function EnterPoint() {
		}
	}
}