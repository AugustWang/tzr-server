package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_monster_talk_toc extends Message
	{
		public var monster_id:int = 0;
		public var content:String = "";
		public function m_monster_talk_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_monster_talk_toc", m_monster_talk_toc);
		}
		public override function getMethodName():String {
			return 'monster_talk';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.monster_id);
			if (this.content != null) {				output.writeUTF(this.content.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.monster_id = input.readInt();
			this.content = input.readUTF();
		}
	}
}
