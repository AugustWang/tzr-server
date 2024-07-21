package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_sys_buff_info extends Message
	{
		public var buff_type:int = 0;
		public var multiple:int = 0;
		public var remain_time:int = 0;
		public function p_sys_buff_info() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_sys_buff_info", p_sys_buff_info);
		}
		public override function getMethodName():String {
			return 'sys_buff_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.buff_type);
			output.writeInt(this.multiple);
			output.writeInt(this.remain_time);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.buff_type = input.readInt();
			this.multiple = input.readInt();
			this.remain_time = input.readInt();
		}
	}
}
