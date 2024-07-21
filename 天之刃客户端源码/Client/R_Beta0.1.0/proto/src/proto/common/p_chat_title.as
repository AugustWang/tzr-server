package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_chat_title extends Message
	{
		public var id:int = 0;
		public var name:String = "";
		public var color:String = "#ffffff";
		public function p_chat_title() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_chat_title", p_chat_title);
		}
		public override function getMethodName():String {
			return 'chat_t';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
			if (this.color != null) {				output.writeUTF(this.color.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.name = input.readUTF();
			this.color = input.readUTF();
		}
	}
}
