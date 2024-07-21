package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_warofking_holding_toc extends Message
	{
		public var role_id:int = 0;
		public var time:int = 0;
		public var total_time:int = 0;
		public function m_warofking_holding_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_warofking_holding_toc", m_warofking_holding_toc);
		}
		public override function getMethodName():String {
			return 'warofking_holding';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			output.writeInt(this.time);
			output.writeInt(this.total_time);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.time = input.readInt();
			this.total_time = input.readInt();
		}
	}
}
