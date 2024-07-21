package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_hero_fb_record extends Message
	{
		public var role_id:int = 0;
		public var role_name:String = "";
		public var faction_id:int = 0;
		public var time_used:int = 0;
		public var score:int = 0;
		public var star_level:int = 0;
		public var order:int = 0;
		public function p_hero_fb_record() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_hero_fb_record", p_hero_fb_record);
		}
		public override function getMethodName():String {
			return 'hero_fb_re';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.faction_id);
			output.writeInt(this.time_used);
			output.writeInt(this.score);
			output.writeInt(this.star_level);
			output.writeInt(this.order);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.faction_id = input.readInt();
			this.time_used = input.readInt();
			this.score = input.readInt();
			this.star_level = input.readInt();
			this.order = input.readInt();
		}
	}
}
