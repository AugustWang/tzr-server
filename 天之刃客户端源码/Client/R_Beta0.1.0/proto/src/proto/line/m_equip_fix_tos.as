package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_fix_tos extends Message
	{
		public var fix_type:Boolean = true;
		public var equip_id:int = 0;
		public function m_equip_fix_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_equip_fix_tos", m_equip_fix_tos);
		}
		public override function getMethodName():String {
			return 'equip_fix';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.fix_type);
			output.writeInt(this.equip_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.fix_type = input.readBoolean();
			this.equip_id = input.readInt();
		}
	}
}
