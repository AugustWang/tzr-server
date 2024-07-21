package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_fmldepot_log extends Message
	{
		public var log_time:int = 0;
		public var role_name:String = "";
		public var item_type_id:int = 0;
		public var item_color:int = 0;
		public var item_num:int = 0;
		public function p_fmldepot_log() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_fmldepot_log", p_fmldepot_log);
		}
		public override function getMethodName():String {
			return 'fmldepot';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.log_time);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.item_type_id);
			output.writeInt(this.item_color);
			output.writeInt(this.item_num);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.log_time = input.readInt();
			this.role_name = input.readUTF();
			this.item_type_id = input.readInt();
			this.item_color = input.readInt();
			this.item_num = input.readInt();
		}
	}
}
