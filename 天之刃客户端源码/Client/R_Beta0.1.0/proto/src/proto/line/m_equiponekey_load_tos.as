package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equiponekey_load_tos extends Message
	{
		public var equips_id:int = 0;
		public function m_equiponekey_load_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_equiponekey_load_tos", m_equiponekey_load_tos);
		}
		public override function getMethodName():String {
			return 'equiponekey_load';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.equips_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.equips_id = input.readInt();
		}
	}
}
