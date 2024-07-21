package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stall_buy_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public var role_id:int = 0;
		public var role_name:String = "";
		public var goods_id:int = 0;
		public var num:int = 0;
		public var stall_finish:Boolean = false;
		public function m_stall_buy_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_stall_buy_toc", m_stall_buy_toc);
		}
		public override function getMethodName():String {
			return 'stall_buy';
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
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.goods_id);
			output.writeInt(this.num);
			output.writeBoolean(this.stall_finish);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.goods_id = input.readInt();
			this.num = input.readInt();
			this.stall_finish = input.readBoolean();
		}
	}
}
