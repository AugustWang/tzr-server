package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_channel_info extends Message
	{
		public var channel_sign:String = "";
		public var channel_type:int = 0;
		public var channel_name:String = "";
		public var online_num:int = 1;
		public var total_num:int = 1;
		public function p_channel_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_channel_info", p_channel_info);
		}
		public override function getMethodName():String {
			return 'channel_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.channel_sign != null) {				output.writeUTF(this.channel_sign.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.channel_type);
			if (this.channel_name != null) {				output.writeUTF(this.channel_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.online_num);
			output.writeInt(this.total_num);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.channel_sign = input.readUTF();
			this.channel_type = input.readInt();
			this.channel_name = input.readUTF();
			this.online_num = input.readInt();
			this.total_num = input.readInt();
		}
	}
}
