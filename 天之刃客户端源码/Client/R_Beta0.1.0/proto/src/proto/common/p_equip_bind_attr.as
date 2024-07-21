package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_equip_bind_attr extends Message
	{
		public var attr_code:int = 0;
		public var attr_level:int = 0;
		public var type:int = 0;
		public var value:int = 0;
		public function p_equip_bind_attr() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_equip_bind_attr", p_equip_bind_attr);
		}
		public override function getMethodName():String {
			return 'equip_bind_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.attr_code);
			output.writeInt(this.attr_level);
			output.writeInt(this.type);
			output.writeInt(this.value);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.attr_code = input.readInt();
			this.attr_level = input.readInt();
			this.type = input.readInt();
			this.value = input.readInt();
		}
	}
}
