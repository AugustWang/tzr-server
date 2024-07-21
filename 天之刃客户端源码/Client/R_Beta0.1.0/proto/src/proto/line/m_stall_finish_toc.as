package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stall_finish_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public var role_id:int = 0;
		public var tax:int = 0;
		public var get_silver:int = 0;
		public var silver:int = 0;
		public var bind_silver:int = 0;
		public var time_over:Boolean = false;
		public var get_gold:int = 0;
		public function m_stall_finish_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_stall_finish_toc", m_stall_finish_toc);
		}
		public override function getMethodName():String {
			return 'stall_finish';
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
			output.writeInt(this.tax);
			output.writeInt(this.get_silver);
			output.writeInt(this.silver);
			output.writeInt(this.bind_silver);
			output.writeBoolean(this.time_over);
			output.writeInt(this.get_gold);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
			this.role_id = input.readInt();
			this.tax = input.readInt();
			this.get_silver = input.readInt();
			this.silver = input.readInt();
			this.bind_silver = input.readInt();
			this.time_over = input.readBoolean();
			this.get_gold = input.readInt();
		}
	}
}
