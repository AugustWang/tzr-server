package com.scene.sceneData {
	import com.globals.GameConfig;
	import com.scene.tile.Pt;
	
	import flash.net.registerClassAlias;
	
	import modules.npc.NPCDataManager;

	public class NPCVo {
		public var pt:Pt; //位置
		public var id:int; //npcid
		public var skinId:String; //身体形象
		public var name:String; //npc名字
		public var headImage:String; //头像
		public var job:String; //职位
		public var jobId:int; //职位ID
		public var link:String;
		public var baseContent:String;
		public var type:int;
		public var color:String;
		
		public function NPCVo() {
			registerClassAlias("copy.com.scene.sceneData.NPCVo", NPCVo);
		}

		public function setUP(birthPt:Pt, npcID:int):void {
			this.pt = birthPt;
			this.id = npcID;
			var _npcInfo:Object=NPCDataManager.getInstance().getNpcInfo(npcID);
			this.pt=birthPt;
			this.id=_npcInfo.id;
			this.skinId=_npcInfo.skin;
			this.name=_npcInfo.name;
			this.headImage=GameConfig.ROOT_URL + _npcInfo.avatar;
			this.job=_npcInfo.jobName;
			this.jobId=_npcInfo.jobID;
			this.baseContent=_npcInfo.content;
			this.type=_npcInfo.type;
			this.color=_npcInfo.color;
		}
		
	}
}