package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_item_trace_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var goods_id:int = 0;
		public var goods_num:int = 0;
		public var target_name:String = "";
		public var target_mapid:int = 0;
		public var target_tx:int = 0;
		public var target_ty:int = 0;
		public function m_item_trace_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_item_trace_toc", m_item_trace_toc);
		}
		public override function getMethodName():String {
			return 'item_trace';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.goods_id);
			output.writeInt(this.goods_num);
			if (this.target_name != null) {				output.writeUTF(this.target_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.target_mapid);
			output.writeInt(this.target_tx);
			output.writeInt(this.target_ty);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.goods_id = input.readInt();
			this.goods_num = input.readInt();
			this.target_name = input.readUTF();
			this.target_mapid = input.readInt();
			this.target_tx = input.readInt();
			this.target_ty = input.readInt();
		}
	}
}
