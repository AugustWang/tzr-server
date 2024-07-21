package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_warofking_end_toc extends Message
	{
		public var family_id:int = 0;
		public var role_id:int = 0;
		public function m_warofking_end_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_warofking_end_toc", m_warofking_end_toc);
		}
		public override function getMethodName():String {
			return 'warofking_end';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.family_id);
			output.writeInt(this.role_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.family_id = input.readInt();
			this.role_id = input.readInt();
		}
	}
}
