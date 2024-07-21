package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_map_quit_toc extends Message
	{
		public var roleid:int = 0;
		public function m_map_quit_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_map_quit_toc", m_map_quit_toc);
		}
		public override function getMethodName():String {
			return 'map_quit';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.roleid);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.roleid = input.readInt();
		}
	}
}
