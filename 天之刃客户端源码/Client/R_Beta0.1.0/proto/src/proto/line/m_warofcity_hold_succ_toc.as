package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_warofcity_hold_succ_toc extends Message
	{
		public var family_id:int = 0;
		public var family_name:String = "";
		public var role_name:String = "";
		public function m_warofcity_hold_succ_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_warofcity_hold_succ_toc", m_warofcity_hold_succ_toc);
		}
		public override function getMethodName():String {
			return 'warofcity_hold_succ';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.family_id);
			if (this.family_name != null) {				output.writeUTF(this.family_name.toString());
			} else {
				output.writeUTF("");
			}
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.family_id = input.readInt();
			this.family_name = input.readUTF();
			this.role_name = input.readUTF();
		}
	}
}
