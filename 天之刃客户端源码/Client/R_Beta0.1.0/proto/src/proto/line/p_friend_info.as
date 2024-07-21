package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_friend_info extends Message
	{
		public var roleid:int = 0;
		public var rolename:String = "";
		public var type:int = 0;
		public var sex:int = 0;
		public var faction_id:int = 0;
		public var level:int = 0;
		public var friendly:int = 0;
		public var is_online:Boolean = true;
		public var sign:String = "";
		public var family_name:String = "";
		public var relative:Array = new Array;
		public var head:int = 0;
		public function p_friend_info() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_friend_info", p_friend_info);
		}
		public override function getMethodName():String {
			return 'friend_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.roleid);
			if (this.rolename != null) {				output.writeUTF(this.rolename.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.type);
			output.writeInt(this.sex);
			output.writeInt(this.faction_id);
			output.writeInt(this.level);
			output.writeInt(this.friendly);
			output.writeBoolean(this.is_online);
			if (this.sign != null) {				output.writeUTF(this.sign.toString());
			} else {
				output.writeUTF("");
			}
			if (this.family_name != null) {				output.writeUTF(this.family_name.toString());
			} else {
				output.writeUTF("");
			}
			var size_relative:int = this.relative.length;
			output.writeShort(size_relative);
			var temp_repeated_byte_relative:ByteArray= new ByteArray;
			for(i=0; i<size_relative; i++) {
				temp_repeated_byte_relative.writeInt(this.relative[i]);
			}
			output.writeInt(temp_repeated_byte_relative.length);
			output.writeBytes(temp_repeated_byte_relative);
			output.writeInt(this.head);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.roleid = input.readInt();
			this.rolename = input.readUTF();
			this.type = input.readInt();
			this.sex = input.readInt();
			this.faction_id = input.readInt();
			this.level = input.readInt();
			this.friendly = input.readInt();
			this.is_online = input.readBoolean();
			this.sign = input.readUTF();
			this.family_name = input.readUTF();
			var size_relative:int = input.readShort();
			var length_relative:int = input.readInt();
			var byte_relative:ByteArray = new ByteArray; 
			if (size_relative > 0) {
				input.readBytes(byte_relative, 0, size_relative * 4);
				for(i=0; i<size_relative; i++) {
					var tmp_relative:int = byte_relative.readInt();
					this.relative.push(tmp_relative);
				}
			}
			this.head = input.readInt();
		}
	}
}
