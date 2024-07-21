package com.scene.sceneData {
	import com.scene.tile.Pt;

	import modules.scene.SceneDataManager;

	public class RunVo {
		public var pt:Pt;
		public var mapid:int;
		public var action:HandlerAction;
		public var cut:int; //走到距离PT点CUT个格子就停下
		/**
		 * atonce 立刻走 比如任务追踪 会立刻就移动
		 * normal 会有僵硬时间 比如打怪时
		 */
		public var type:String="RUN_TYPE_NORMAL";

		/**
		 * 会有僵硬时间 比如打怪时
		 */
		static public const RUN_TYPE_NORMAL:String='RUN_TYPE_NORMAL';

		/**
		 * 立刻走 比如任务追踪 会立刻就移动
		 */
		static public const RUN_TYPE_ADVANCED:String='RUN_TYPE_ADVANCED';

		public function RunVo() {
			mapid=SceneDataManager.mapID;
		}
	}
}