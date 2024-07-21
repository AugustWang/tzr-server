package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_equip_rank extends Message
	{
		public var goods_id:int = 0;
		public var role_name:String = "";
		public var type_id:int = 0;
		public var colour:int = 0;
		public var quality:int = 0;
		public var ranking:int = 0;
		public var faction_id:int = 0;
		public var refining_score:int = 0;
		public var reinforce_score:int = 0;
		public var stone_score:int = 0;
		public var role_id:int = 0;
		public function p_equip_rank() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_equip_rank", p_equip_rank);
		}
		public override function getMethodName():String {
			return 'equip_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.goods_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.type_id);
			output.writeInt(this.colour);
			output.writeInt(this.quality);
			output.writeInt(this.ranking);
			output.writeInt(this.faction_id);
			output.writeInt(this.refining_score);
			output.writeInt(this.reinforce_score);
			output.writeInt(this.stone_score);
			output.writeInt(this.role_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.goods_id = input.readInt();
			this.role_name = input.readUTF();
			this.type_id = input.readInt();
			this.colour = input.readInt();
			this.quality = input.readInt();
			this.ranking = input.readInt();
			this.faction_id = input.readInt();
			this.refining_score = input.readInt();
			this.reinforce_score = input.readInt();
			this.stone_score = input.readInt();
			this.role_id = input.readInt();
		}
	}
}
