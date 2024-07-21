package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_map_role_killed_toc extends Message
	{
		public var role_name:String = "";
		public var killer_name:String = "";
		public var faction_id:int = 0;
		public var map_id:int = 0;
		public var tx:int = 0;
		public var ty:int = 0;
		public function m_map_role_killed_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_map_role_killed_toc", m_map_role_killed_toc);
		}
		public override function getMethodName():String {
			return 'map_role_killed';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			if (this.killer_name != null) {				output.writeUTF(this.killer_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.faction_id);
			output.writeInt(this.map_id);
			output.writeInt(this.tx);
			output.writeInt(this.ty);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_name = input.readUTF();
			this.killer_name = input.readUTF();
			this.faction_id = input.readInt();
			this.map_id = input.readInt();
			this.tx = input.readInt();
			this.ty = input.readInt();
		}
	}
}
