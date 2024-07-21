package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_pet_attr_change_toc extends Message
	{
		public var pet_id:int = 0;
		public var change_type:int = 0;
		public var value:int = 0;
		public function m_pet_attr_change_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_pet_attr_change_toc", m_pet_attr_change_toc);
		}
		public override function getMethodName():String {
			return 'pet_attr_change';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.pet_id);
			output.writeInt(this.change_type);
			output.writeInt(this.value);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.pet_id = input.readInt();
			this.change_type = input.readInt();
			this.value = input.readInt();
		}
	}
}
