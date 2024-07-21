package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_monster_talk extends Message
	{
		public var rate:int = 0;
		public var talk:String = "";
		public function p_monster_talk() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_monster_talk", p_monster_talk);
		}
		public override function getMethodName():String {
			return 'monster_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.rate);
			if (this.talk != null) {				output.writeUTF(this.talk.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.rate = input.readInt();
			this.talk = input.readUTF();
		}
	}
}
