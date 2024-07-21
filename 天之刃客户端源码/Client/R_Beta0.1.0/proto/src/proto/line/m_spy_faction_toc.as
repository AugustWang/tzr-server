package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_spy_faction_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public var remain_time:int = 0;
		public var npc_id:int = 0;
		public var map_id:int = 0;
		public var tx:int = 0;
		public var ty:int = 0;
		public var office_id:int = 0;
		public var faction_id:int = 0;
		public var role_name:String = "";
		public function m_spy_faction_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_spy_faction_toc", m_spy_faction_toc);
		}
		public override function getMethodName():String {
			return 'spy_faction';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
			output.writeInt(this.remain_time);
			output.writeInt(this.npc_id);
			output.writeInt(this.map_id);
			output.writeInt(this.tx);
			output.writeInt(this.ty);
			output.writeInt(this.office_id);
			output.writeInt(this.faction_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
			this.remain_time = input.readInt();
			this.npc_id = input.readInt();
			this.map_id = input.readInt();
			this.tx = input.readInt();
			this.ty = input.readInt();
			this.office_id = input.readInt();
			this.faction_id = input.readInt();
			this.role_name = input.readUTF();
		}
	}
}
