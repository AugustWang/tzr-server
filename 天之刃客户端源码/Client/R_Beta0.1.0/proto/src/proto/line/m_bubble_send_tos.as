package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_bubble_send_tos extends Message
	{
		public var action_type:int = 0;
		public var msg:String = "";
		public var to_role_id:int = 0;
		public function m_bubble_send_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_bubble_send_tos", m_bubble_send_tos);
		}
		public override function getMethodName():String {
			return 'bubble_send';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.action_type);
			if (this.msg != null) {				output.writeUTF(this.msg.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.to_role_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.action_type = input.readInt();
			this.msg = input.readUTF();
			this.to_role_id = input.readInt();
		}
	}
}
