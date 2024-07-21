package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_prestige_deal_tos extends Message
	{
		public var group_id:int = 0;
		public var class_id:int = 0;
		public var key:int = 0;
		public var number:int = 1;
		public function m_prestige_deal_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_prestige_deal_tos", m_prestige_deal_tos);
		}
		public override function getMethodName():String {
			return 'prestige_deal';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.group_id);
			output.writeInt(this.class_id);
			output.writeInt(this.key);
			output.writeInt(this.number);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.group_id = input.readInt();
			this.class_id = input.readInt();
			this.key = input.readInt();
			this.number = input.readInt();
		}
	}
}
