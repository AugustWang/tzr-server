package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_flowers_get_recever_info_tos extends Message
	{
		public var role_name:String = "";
		public function m_flowers_get_recever_info_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_flowers_get_recever_info_tos", m_flowers_get_recever_info_tos);
		}
		public override function getMethodName():String {
			return 'flowers_get_recever_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_name = input.readUTF();
		}
	}
}
