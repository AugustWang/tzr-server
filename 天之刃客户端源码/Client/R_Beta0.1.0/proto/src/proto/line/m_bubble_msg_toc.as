package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_bubble_msg_toc extends Message
	{
		public var actor_type:int = 0;
		public var actor_id:int = 0;
		public var actor_name:String = "";
		public var actor_sex:int = 0;
		public var actor_faction:int = 0;
		public var action_type:int = 0;
		public var msg:String = "";
		public var to_role_id:int = 0;
		public var actor_head:int = 1;
		public function m_bubble_msg_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_bubble_msg_toc", m_bubble_msg_toc);
		}
		public override function getMethodName():String {
			return 'bubble_msg';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.actor_type);
			output.writeInt(this.actor_id);
			if (this.actor_name != null) {				output.writeUTF(this.actor_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.actor_sex);
			output.writeInt(this.actor_faction);
			output.writeInt(this.action_type);
			if (this.msg != null) {				output.writeUTF(this.msg.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.to_role_id);
			output.writeInt(this.actor_head);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.actor_type = input.readInt();
			this.actor_id = input.readInt();
			this.actor_name = input.readUTF();
			this.actor_sex = input.readInt();
			this.actor_faction = input.readInt();
			this.action_type = input.readInt();
			this.msg = input.readUTF();
			this.to_role_id = input.readInt();
			this.actor_head = input.readInt();
		}
	}
}
