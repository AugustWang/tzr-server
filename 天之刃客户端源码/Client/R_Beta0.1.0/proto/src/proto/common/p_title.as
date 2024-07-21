package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_title extends Message
	{
		public var id:int = 0;
		public var name:String = "";
		public var type:int = 0;
		public var auto_timeout:Boolean = true;
		public var timeout_time:int = 0;
		public var role_id:int = 0;
		public var show_in_chat:Boolean = true;
		public var show_in_sence:Boolean = true;
		public var color:String = "";
		public function p_title() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_title", p_title);
		}
		public override function getMethodName():String {
			return 't';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.type);
			output.writeBoolean(this.auto_timeout);
			output.writeInt(this.timeout_time);
			output.writeInt(this.role_id);
			output.writeBoolean(this.show_in_chat);
			output.writeBoolean(this.show_in_sence);
			if (this.color != null) {				output.writeUTF(this.color.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.name = input.readUTF();
			this.type = input.readInt();
			this.auto_timeout = input.readBoolean();
			this.timeout_time = input.readInt();
			this.role_id = input.readInt();
			this.show_in_chat = input.readBoolean();
			this.show_in_sence = input.readBoolean();
			this.color = input.readUTF();
		}
	}
}
