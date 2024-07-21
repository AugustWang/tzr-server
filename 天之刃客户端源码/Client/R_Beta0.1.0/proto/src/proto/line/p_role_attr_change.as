package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_role_attr_change extends Message
	{
		public var change_type:int = 0;
		public var new_value:Number = 0;
		public function p_role_attr_change() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_role_attr_change", p_role_attr_change);
		}
		public override function getMethodName():String {
			return 'role_attr_ch';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.change_type);
			output.writeDouble(this.new_value);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.change_type = input.readInt();
			this.new_value = input.readDouble();
		}
	}
}
