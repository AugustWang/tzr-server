package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_broadcast_admin_tos extends Message
	{
		public var id:int = 0;
		public var foreign_id:int = 0;
		public var type:int = 0;
		public var content:String = "";
		public var send_strategy:int = 0;
		public var start_date:String = "";
		public var end_date:String = "";
		public var start_time:String = "";
		public var end_time:String = "";
		public var interval:int = 0;
		public function m_broadcast_admin_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_broadcast_admin_tos", m_broadcast_admin_tos);
		}
		public override function getMethodName():String {
			return 'broadcast_admin';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.foreign_id);
			output.writeInt(this.type);
			if (this.content != null) {				output.writeUTF(this.content.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.send_strategy);
			if (this.start_date != null) {				output.writeUTF(this.start_date.toString());
			} else {
				output.writeUTF("");
			}
			if (this.end_date != null) {				output.writeUTF(this.end_date.toString());
			} else {
				output.writeUTF("");
			}
			if (this.start_time != null) {				output.writeUTF(this.start_time.toString());
			} else {
				output.writeUTF("");
			}
			if (this.end_time != null) {				output.writeUTF(this.end_time.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.interval);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.foreign_id = input.readInt();
			this.type = input.readInt();
			this.content = input.readUTF();
			this.send_strategy = input.readInt();
			this.start_date = input.readUTF();
			this.end_date = input.readUTF();
			this.start_time = input.readUTF();
			this.end_time = input.readUTF();
			this.interval = input.readInt();
		}
	}
}
