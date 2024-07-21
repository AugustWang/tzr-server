package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equiponekey_save_toc extends Message
	{
		public var succ:Boolean = true;
		public var equips_id:int = 0;
		public var equips_name:String = "";
		public var reason:String = "";
		public function m_equiponekey_save_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_equiponekey_save_toc", m_equiponekey_save_toc);
		}
		public override function getMethodName():String {
			return 'equiponekey_save';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeInt(this.equips_id);
			if (this.equips_name != null) {				output.writeUTF(this.equips_name.toString());
			} else {
				output.writeUTF("");
			}
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.equips_id = input.readInt();
			this.equips_name = input.readUTF();
			this.reason = input.readUTF();
		}
	}
}
