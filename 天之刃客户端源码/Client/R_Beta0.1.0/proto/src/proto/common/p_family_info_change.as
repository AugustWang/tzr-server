package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_family_info_change extends Message
	{
		public var change_type:int = 0;
		public var new_value:int = 0;
		public function p_family_info_change() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_family_info_change", p_family_info_change);
		}
		public override function getMethodName():String {
			return 'family_info_ch';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.change_type);
			output.writeInt(this.new_value);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.change_type = input.readInt();
			this.new_value = input.readInt();
		}
	}
}
