package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_fmldepot_getout_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var goods_id:int = 0;
		public var remain_num:int = 0;
		public function m_fmldepot_getout_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_fmldepot_getout_toc", m_fmldepot_getout_toc);
		}
		public override function getMethodName():String {
			return 'fmldepot_getout';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.goods_id);
			output.writeInt(this.remain_num);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.goods_id = input.readInt();
			this.remain_num = input.readInt();
		}
	}
}
