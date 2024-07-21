package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_pet_egg_adopt_tos extends Message
	{
		public var goods_id:int = 0;
		public var type_id:int = 0;
		public function m_pet_egg_adopt_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_pet_egg_adopt_tos", m_pet_egg_adopt_tos);
		}
		public override function getMethodName():String {
			return 'pet_egg_adopt';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.goods_id);
			output.writeInt(this.type_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.goods_id = input.readInt();
			this.type_id = input.readInt();
		}
	}
}
