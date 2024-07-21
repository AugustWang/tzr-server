package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_pkpoint_left_toc extends Message
	{
		public var time_left:int = 0;
		public function m_role2_pkpoint_left_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_pkpoint_left_toc", m_role2_pkpoint_left_toc);
		}
		public override function getMethodName():String {
			return 'role2_pkpoint_left';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.time_left);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.time_left = input.readInt();
		}
	}
}
