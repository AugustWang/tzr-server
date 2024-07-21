package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_fmldepot_create_tos extends Message
	{
		public var bag_id:int = 0;
		public function m_fmldepot_create_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_fmldepot_create_tos", m_fmldepot_create_tos);
		}
		public override function getMethodName():String {
			return 'fmldepot_create';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.bag_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.bag_id = input.readInt();
		}
	}
}
