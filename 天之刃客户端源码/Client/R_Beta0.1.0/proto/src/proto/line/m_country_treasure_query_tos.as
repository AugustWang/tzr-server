package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_country_treasure_query_tos extends Message
	{
		public var op_type:int = 0;
		public function m_country_treasure_query_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_country_treasure_query_tos", m_country_treasure_query_tos);
		}
		public override function getMethodName():String {
			return 'country_treasure_query';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.op_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.op_type = input.readInt();
		}
	}
}
