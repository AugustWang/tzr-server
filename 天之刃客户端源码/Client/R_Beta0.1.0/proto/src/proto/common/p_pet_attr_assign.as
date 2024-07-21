package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_pet_attr_assign extends Message
	{
		public var assign_type:int = 0;
		public var assign_value:int = 0;
		public function p_pet_attr_assign() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_pet_attr_assign", p_pet_attr_assign);
		}
		public override function getMethodName():String {
			return 'pet_attr_as';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.assign_type);
			output.writeInt(this.assign_value);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.assign_type = input.readInt();
			this.assign_value = input.readInt();
		}
	}
}
