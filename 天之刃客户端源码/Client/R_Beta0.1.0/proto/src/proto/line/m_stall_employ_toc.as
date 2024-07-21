package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stall_employ_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public var role_id:int = 0;
		public var silver:int = 0;
		public var bind_silver:int = 0;
		public function m_stall_employ_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_stall_employ_toc", m_stall_employ_toc);
		}
		public override function getMethodName():String {
			return 'stall_employ';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
			output.writeInt(this.role_id);
			output.writeInt(this.silver);
			output.writeInt(this.bind_silver);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
			this.role_id = input.readInt();
			this.silver = input.readInt();
			this.bind_silver = input.readInt();
		}
	}
}
