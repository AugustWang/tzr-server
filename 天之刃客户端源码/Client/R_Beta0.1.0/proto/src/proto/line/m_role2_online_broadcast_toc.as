package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_online_broadcast_toc extends Message
	{
		public var role_type:int = 0;
		public var role_name:String = "";
		public var faction_id:int = 0;
		public function m_role2_online_broadcast_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_online_broadcast_toc", m_role2_online_broadcast_toc);
		}
		public override function getMethodName():String {
			return 'role2_online_broadcast';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_type);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.faction_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_type = input.readInt();
			this.role_name = input.readUTF();
			this.faction_id = input.readInt();
		}
	}
}
