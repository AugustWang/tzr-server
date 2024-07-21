package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_waroffaction_tower_destroyed_toc extends Message
	{
		public var attack_faction_id:int = 0;
		public var defence_faction_id:int = 0;
		public var attack_role_name:String = "";
		public function m_waroffaction_tower_destroyed_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_waroffaction_tower_destroyed_toc", m_waroffaction_tower_destroyed_toc);
		}
		public override function getMethodName():String {
			return 'waroffaction_tower_destroyed';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.attack_faction_id);
			output.writeInt(this.defence_faction_id);
			if (this.attack_role_name != null) {				output.writeUTF(this.attack_role_name.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.attack_faction_id = input.readInt();
			this.defence_faction_id = input.readInt();
			this.attack_role_name = input.readUTF();
		}
	}
}
