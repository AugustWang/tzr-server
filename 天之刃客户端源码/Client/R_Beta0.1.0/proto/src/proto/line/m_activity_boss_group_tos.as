package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_activity_boss_group_tos extends Message
	{
		public var op_type:int = 0;
		public var boss_id:int = 0;
		public function m_activity_boss_group_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_activity_boss_group_tos", m_activity_boss_group_tos);
		}
		public override function getMethodName():String {
			return 'activity_boss_group';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.op_type);
			output.writeInt(this.boss_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.op_type = input.readInt();
			this.boss_id = input.readInt();
		}
	}
}
