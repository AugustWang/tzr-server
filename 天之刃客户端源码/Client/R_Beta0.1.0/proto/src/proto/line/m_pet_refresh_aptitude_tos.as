package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_pet_refresh_aptitude_tos extends Message
	{
		public var pet_id:int = 0;
		public var item_type:int = 0;
		public function m_pet_refresh_aptitude_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_pet_refresh_aptitude_tos", m_pet_refresh_aptitude_tos);
		}
		public override function getMethodName():String {
			return 'pet_refresh_aptitude';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.pet_id);
			output.writeInt(this.item_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.pet_id = input.readInt();
			this.item_type = input.readInt();
		}
	}
}
