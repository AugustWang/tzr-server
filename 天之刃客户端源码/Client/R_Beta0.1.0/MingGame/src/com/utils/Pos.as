package com.utils
{
	import com.scene.sceneUnit.configs.MonsterConfig;
	
	import flash.utils.ByteArray;
	
	import modules.npc.NPCDataManager;

	public class Pos
	{
		public function Pos()
		{
		}
		
		static public const NPC_TYPE:int = 4;
		static public const MONSTER_TYPE:int = 5;
		
		static public function dealPos(bytes:ByteArray):void{
			while(bytes.bytesAvailable > 0){
				//<<Type:32, MapID:32, ID:32, IndexTX:32, IndexTY:32>>
				var item:ByteArray = new ByteArray();
				bytes.readBytes(item, 0, 20);
				var type:int = item.readUnsignedInt();
				var mapID:int = item.readUnsignedInt();
				var id:int = item.readUnsignedInt();
				var tx:int = item.readUnsignedInt();
				var ty:int = item.readUnsignedInt();
				switch(type){
					case Pos.NPC_TYPE:
						NPCDataManager.getInstance().setPos(id, mapID, tx, ty);
						break
					case Pos.MONSTER_TYPE:
						MonsterConfig.setPos(id, mapID, tx, ty);
						break;
					default:
						break;
				}
			}
		}
	}
}