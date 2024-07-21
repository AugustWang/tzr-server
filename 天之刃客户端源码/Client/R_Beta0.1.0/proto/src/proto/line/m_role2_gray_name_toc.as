package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_gray_name_toc extends Message
	{
		public var roleid:int = 0;
		public var if_gray_name:Boolean = true;
		public function m_role2_gray_name_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_gray_name_toc", m_role2_gray_name_toc);
		}
		public override function getMethodName():String {
			return 'role2_gray_name';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.roleid);
			output.writeBoolean(this.if_gray_name);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.roleid = input.readInt();
			this.if_gray_name = input.readBoolean();
		}
	}
}
