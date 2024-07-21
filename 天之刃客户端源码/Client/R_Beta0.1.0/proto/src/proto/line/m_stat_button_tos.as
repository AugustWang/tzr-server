package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stat_button_tos extends Message
	{
		public var use_type:int = 1;
		public var btn_key:int = 0;
		public function m_stat_button_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_stat_button_tos", m_stat_button_tos);
		}
		public override function getMethodName():String {
			return 'stat_button';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.use_type);
			output.writeInt(this.btn_key);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.use_type = input.readInt();
			this.btn_key = input.readInt();
		}
	}
}
