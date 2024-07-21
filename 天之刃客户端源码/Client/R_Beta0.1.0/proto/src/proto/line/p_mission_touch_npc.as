package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_mission_touch_npc extends Message
	{
		public var id:int = 0;
		public var map:int = 0;
		public var sign:int = 0;
		public var talk:String = "";
		public function p_mission_touch_npc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_mission_touch_npc", p_mission_touch_npc);
		}
		public override function getMethodName():String {
			return 'mission_touch';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.map);
			output.writeInt(this.sign);
			if (this.talk != null) {				output.writeUTF(this.talk.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.map = input.readInt();
			this.sign = input.readInt();
			this.talk = input.readUTF();
		}
	}
}
