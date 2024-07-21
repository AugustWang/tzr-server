package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_combine_panel_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var family_id_1:int = 0;
		public var family_name_1:String = "";
		public var family_id_2:int = 0;
		public var family_name_2:String = "";
		public function m_family_combine_panel_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_combine_panel_toc", m_family_combine_panel_toc);
		}
		public override function getMethodName():String {
			return 'family_combine_panel';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.family_id_1);
			if (this.family_name_1 != null) {				output.writeUTF(this.family_name_1.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.family_id_2);
			if (this.family_name_2 != null) {				output.writeUTF(this.family_name_2.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.family_id_1 = input.readInt();
			this.family_name_1 = input.readUTF();
			this.family_id_2 = input.readInt();
			this.family_name_2 = input.readUTF();
		}
	}
}
