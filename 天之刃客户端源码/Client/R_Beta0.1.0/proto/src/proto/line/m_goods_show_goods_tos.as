package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_goods_show_goods_tos extends Message
	{
		public var channel_sign:String = "";
		public var to_role_name:String = "";
		public var show_type:int = 0;
		public var goods_id:int = 0;
		public function m_goods_show_goods_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_goods_show_goods_tos", m_goods_show_goods_tos);
		}
		public override function getMethodName():String {
			return 'goods_show_goods';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.channel_sign != null) {				output.writeUTF(this.channel_sign.toString());
			} else {
				output.writeUTF("");
			}
			if (this.to_role_name != null) {				output.writeUTF(this.to_role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.show_type);
			output.writeInt(this.goods_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.channel_sign = input.readUTF();
			this.to_role_name = input.readUTF();
			this.show_type = input.readInt();
			this.goods_id = input.readInt();
		}
	}
}
