package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_memberuplevel_toc extends Message
	{
		public var role_id:int = 0;
		public var new_level:int = 0;
		public function m_family_memberuplevel_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_memberuplevel_toc", m_family_memberuplevel_toc);
		}
		public override function getMethodName():String {
			return 'family_memberuplevel';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			output.writeInt(this.new_level);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.new_level = input.readInt();
		}
	}
}
