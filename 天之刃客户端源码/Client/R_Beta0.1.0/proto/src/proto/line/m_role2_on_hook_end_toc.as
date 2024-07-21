package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_on_hook_end_toc extends Message
	{
		public var succ:Boolean = true;
		public var return_self:Boolean = true;
		public var reason:String = "";
		public var start_time:int = 0;
		public var sum_exp:int = 0;
		public var end_time:int = 0;
		public var role_id:int = 0;
		public var status:Boolean = false;
		public function m_role2_on_hook_end_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_on_hook_end_toc", m_role2_on_hook_end_toc);
		}
		public override function getMethodName():String {
			return 'role2_on_hook_end';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeBoolean(this.return_self);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.start_time);
			output.writeInt(this.sum_exp);
			output.writeInt(this.end_time);
			output.writeInt(this.role_id);
			output.writeBoolean(this.status);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.return_self = input.readBoolean();
			this.reason = input.readUTF();
			this.start_time = input.readInt();
			this.sum_exp = input.readInt();
			this.end_time = input.readInt();
			this.role_id = input.readInt();
			this.status = input.readBoolean();
		}
	}
}
