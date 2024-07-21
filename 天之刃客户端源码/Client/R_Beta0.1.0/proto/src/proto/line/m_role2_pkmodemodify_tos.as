package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_pkmodemodify_tos extends Message
	{
		public var pk_mode:int = 0;
		public function m_role2_pkmodemodify_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_pkmodemodify_tos", m_role2_pkmodemodify_tos);
		}
		public override function getMethodName():String {
			return 'role2_pkmodemodify';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.pk_mode);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.pk_mode = input.readInt();
		}
	}
}
