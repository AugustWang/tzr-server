package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_refining_equip_bind_tos extends Message
	{
		public var type:int = 0;
		public var bag_id:int = 0;
		public var equip_id:int = 0;
		public function m_refining_equip_bind_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_refining_equip_bind_tos", m_refining_equip_bind_tos);
		}
		public override function getMethodName():String {
			return 'refining_equip_bind';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
			output.writeInt(this.bag_id);
			output.writeInt(this.equip_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
			this.bag_id = input.readInt();
			this.equip_id = input.readInt();
		}
	}
}
