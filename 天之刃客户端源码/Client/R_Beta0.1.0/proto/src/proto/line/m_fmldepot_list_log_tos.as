package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_fmldepot_list_log_tos extends Message
	{
		public var log_type:int = 0;
		public var page_num:int = 1;
		public function m_fmldepot_list_log_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_fmldepot_list_log_tos", m_fmldepot_list_log_tos);
		}
		public override function getMethodName():String {
			return 'fmldepot_list_log';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.log_type);
			output.writeInt(this.page_num);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.log_type = input.readInt();
			this.page_num = input.readInt();
		}
	}
}
