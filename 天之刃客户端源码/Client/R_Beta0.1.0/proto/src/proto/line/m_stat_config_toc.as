package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stat_config_toc extends Message
	{
		public var is_open:Boolean = false;
		public function m_stat_config_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_stat_config_toc", m_stat_config_toc);
		}
		public override function getMethodName():String {
			return 'stat_config';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.is_open);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.is_open = input.readBoolean();
		}
	}
}
