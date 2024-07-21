package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_collect_get_role_info_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var type_id:int = 0;
		public var value:int = 0;
		public function m_family_collect_get_role_info_toc() {
			super();
			
			flash.net.registerClassAlias("copy.proto.line.m_family_collect_get_role_info_toc", m_family_collect_get_role_info_toc);
		}
		public override function getMethodName():String {
			return 'family_collect_get_role_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				
				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.type_id);
			output.writeInt(this.value);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.type_id = input.readInt();
			this.value = input.readInt();
		}
	}
}
