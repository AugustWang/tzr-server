package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_letter_simple_info extends Message
	{
		public var id:int = 0;
		public var sender:String = "";
		public var receiver:String = "";
		public var title:String = "";
		public var send_time:int = 0;
		public var type:int = 0;
		public var state:int = 0;
		public var is_have_goods:Boolean = false;
		public var table:int = 0;
		public function p_letter_simple_info() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_letter_simple_info", p_letter_simple_info);
		}
		public override function getMethodName():String {
			return 'letter_simple_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			if (this.sender != null) {				output.writeUTF(this.sender.toString());
			} else {
				output.writeUTF("");
			}
			if (this.receiver != null) {				output.writeUTF(this.receiver.toString());
			} else {
				output.writeUTF("");
			}
			if (this.title != null) {				output.writeUTF(this.title.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.send_time);
			output.writeInt(this.type);
			output.writeInt(this.state);
			output.writeBoolean(this.is_have_goods);
			output.writeInt(this.table);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.sender = input.readUTF();
			this.receiver = input.readUTF();
			this.title = input.readUTF();
			this.send_time = input.readInt();
			this.type = input.readInt();
			this.state = input.readInt();
			this.is_have_goods = input.readBoolean();
			this.table = input.readInt();
		}
	}
}
