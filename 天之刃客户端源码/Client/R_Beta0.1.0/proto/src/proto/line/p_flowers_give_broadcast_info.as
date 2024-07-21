package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_flowers_give_broadcast_info extends Message
	{
		public var giver:String = "";
		public var receiver:String = "";
		public var flowers_type:int = 0;
		public var broadcasting:String = "";
		public function p_flowers_give_broadcast_info() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_flowers_give_broadcast_info", p_flowers_give_broadcast_info);
		}
		public override function getMethodName():String {
			return 'flowers_give_broadcast_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.giver != null) {				output.writeUTF(this.giver.toString());
			} else {
				output.writeUTF("");
			}
			if (this.receiver != null) {				output.writeUTF(this.receiver.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.flowers_type);
			if (this.broadcasting != null) {				output.writeUTF(this.broadcasting.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.giver = input.readUTF();
			this.receiver = input.readUTF();
			this.flowers_type = input.readInt();
			this.broadcasting = input.readUTF();
		}
	}
}
