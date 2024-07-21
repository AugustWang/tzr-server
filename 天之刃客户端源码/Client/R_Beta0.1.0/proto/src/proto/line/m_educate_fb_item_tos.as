package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_fb_item_tos extends Message
	{
		public var goods_id:int = 0;
		public var item_id:int = 0;
		public function m_educate_fb_item_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_educate_fb_item_tos", m_educate_fb_item_tos);
		}
		public override function getMethodName():String {
			return 'educate_fb_item';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.goods_id);
			output.writeInt(this.item_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.goods_id = input.readInt();
			this.item_id = input.readInt();
		}
	}
}
