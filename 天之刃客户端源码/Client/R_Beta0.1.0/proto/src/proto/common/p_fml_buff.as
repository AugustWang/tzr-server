package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_fml_buff extends Message
	{
		public var fml_buff_id:int = 0;
		public var level:int = 0;
		public function p_fml_buff() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_fml_buff", p_fml_buff);
		}
		public override function getMethodName():String {
			return 'fml_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.fml_buff_id);
			output.writeInt(this.level);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.fml_buff_id = input.readInt();
			this.level = input.readInt();
		}
	}
}
