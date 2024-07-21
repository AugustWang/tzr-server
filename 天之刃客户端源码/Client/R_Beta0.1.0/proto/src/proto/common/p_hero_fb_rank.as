package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_hero_fb_rank extends Message
	{
		public var ranking:int = 0;
		public var role_id:int = 0;
		public var role_name:String = "";
		public var faction_id:int = 0;
		public var time_used:int = 0;
		public var barrier_id:int = 0;
		public var score:int = 0;
		public function p_hero_fb_rank() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_hero_fb_rank", p_hero_fb_rank);
		}
		public override function getMethodName():String {
			return 'hero_fb_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.ranking);
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.faction_id);
			output.writeInt(this.time_used);
			output.writeInt(this.barrier_id);
			output.writeInt(this.score);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.ranking = input.readInt();
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.faction_id = input.readInt();
			this.time_used = input.readInt();
			this.barrier_id = input.readInt();
			this.score = input.readInt();
		}
	}
}
