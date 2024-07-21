package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_broadcast_countdown_toc extends Message
	{
		public var type:int = 0;
		public var sub_type:int = 0;
		public var id:int = 0;
		public var content:String = "";
		public var countdown_time:int = 0;
		public var current_countdown_time:int = 0;
		public function m_broadcast_countdown_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_broadcast_countdown_toc", m_broadcast_countdown_toc);
		}
		public override function getMethodName():String {
			return 'broadcast_countdown';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
			output.writeInt(this.sub_type);
			output.writeInt(this.id);
			if (this.content != null) {				output.writeUTF(this.content.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.countdown_time);
			output.writeInt(this.current_countdown_time);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
			this.sub_type = input.readInt();
			this.id = input.readInt();
			this.content = input.readUTF();
			this.countdown_time = input.readInt();
			this.current_countdown_time = input.readInt();
		}
	}
}
