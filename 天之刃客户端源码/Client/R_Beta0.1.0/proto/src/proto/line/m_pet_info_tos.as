package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_pet_info_tos extends Message
	{
		public var pet_id:int = 0;
		public var role_id:int = 0;
		public function m_pet_info_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_pet_info_tos", m_pet_info_tos);
		}
		public override function getMethodName():String {
			return 'pet_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.pet_id);
			output.writeInt(this.role_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.pet_id = input.readInt();
			this.role_id = input.readInt();
		}
	}
}
