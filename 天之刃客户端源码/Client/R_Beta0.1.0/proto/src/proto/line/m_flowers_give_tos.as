package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_flowers_give_tos extends Message
	{
		public var rece_role_id:int = 0;
		public var goods_id:int = 0;
		public var flowers_type:int = 0;
		public var is_anonymous:Boolean = true;
		public function m_flowers_give_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_flowers_give_tos", m_flowers_give_tos);
		}
		public override function getMethodName():String {
			return 'flowers_give';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.rece_role_id);
			output.writeInt(this.goods_id);
			output.writeInt(this.flowers_type);
			output.writeBoolean(this.is_anonymous);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.rece_role_id = input.readInt();
			this.goods_id = input.readInt();
			this.flowers_type = input.readInt();
			this.is_anonymous = input.readBoolean();
		}
	}
}
