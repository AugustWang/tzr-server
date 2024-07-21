package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_simple_friend_info extends Message
	{
		public var rolename:String = "";
		public var faction_id:int = 0;
		public var is_online:Boolean = true;
		public var head:int = 0;
		public var level:int = 0;
		public function p_simple_friend_info() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_simple_friend_info", p_simple_friend_info);
		}
		public override function getMethodName():String {
			return 'simple_friend_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.rolename != null) {				output.writeUTF(this.rolename.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.faction_id);
			output.writeBoolean(this.is_online);
			output.writeInt(this.head);
			output.writeInt(this.level);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.rolename = input.readUTF();
			this.faction_id = input.readInt();
			this.is_online = input.readBoolean();
			this.head = input.readInt();
			this.level = input.readInt();
		}
	}
}
