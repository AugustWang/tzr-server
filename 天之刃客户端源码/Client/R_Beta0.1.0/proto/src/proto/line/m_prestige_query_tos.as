package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_prestige_query_tos extends Message
	{
		public var op_type:int = 0;
		public var group_id:int = 0;
		public var class_id:int = 0;
		public function m_prestige_query_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_prestige_query_tos", m_prestige_query_tos);
		}
		public override function getMethodName():String {
			return 'prestige_query';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.op_type);
			output.writeInt(this.group_id);
			output.writeInt(this.class_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.op_type = input.readInt();
			this.group_id = input.readInt();
			this.class_id = input.readInt();
		}
	}
}
