package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_personybc_faction_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var public_role_id:int = 0;
		public var public_role_name:String = "";
		public var public_office:int = 0;
		public var new_start_h:int = 0;
		public var new_start_m:int = 0;
		public var new_start_time:int = 0;
		public var today_start_time:int = 0;
		public var time_limit:int = 0;
		public var npc_id:int = 0;
		public var map_id:int = 0;
		public function m_personybc_faction_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_personybc_faction_toc", m_personybc_faction_toc);
		}
		public override function getMethodName():String {
			return 'personybc_faction';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.public_role_id);
			if (this.public_role_name != null) {				output.writeUTF(this.public_role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.public_office);
			output.writeInt(this.new_start_h);
			output.writeInt(this.new_start_m);
			output.writeInt(this.new_start_time);
			output.writeInt(this.today_start_time);
			output.writeInt(this.time_limit);
			output.writeInt(this.npc_id);
			output.writeInt(this.map_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.public_role_id = input.readInt();
			this.public_role_name = input.readUTF();
			this.public_office = input.readInt();
			this.new_start_h = input.readInt();
			this.new_start_m = input.readInt();
			this.new_start_time = input.readInt();
			this.today_start_time = input.readInt();
			this.time_limit = input.readInt();
			this.npc_id = input.readInt();
			this.map_id = input.readInt();
		}
	}
}
