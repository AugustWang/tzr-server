package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_chat_role extends Message
	{
		public var roleid:int = 0;
		public var rolename:String = "";
		public var factionid:int = 0;
		public var faction_name:String = "";
		public var sex:int = 0;
		public var head:int = 0;
		public var sign:String = "";
		public var titles:Array = new Array;
		public function p_chat_role() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_chat_role", p_chat_role);
		}
		public override function getMethodName():String {
			return 'chat_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.roleid);
			if (this.rolename != null) {				output.writeUTF(this.rolename.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.factionid);
			if (this.faction_name != null) {				output.writeUTF(this.faction_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.sex);
			output.writeInt(this.head);
			if (this.sign != null) {				output.writeUTF(this.sign.toString());
			} else {
				output.writeUTF("");
			}
			var size_titles:int = this.titles.length;
			output.writeShort(size_titles);
			var temp_repeated_byte_titles:ByteArray= new ByteArray;
			for(i=0; i<size_titles; i++) {
				var t2_titles:ByteArray = new ByteArray;
				var tVo_titles:p_chat_title = this.titles[i] as p_chat_title;
				tVo_titles.writeToDataOutput(t2_titles);
				var len_tVo_titles:int = t2_titles.length;
				temp_repeated_byte_titles.writeInt(len_tVo_titles);
				temp_repeated_byte_titles.writeBytes(t2_titles);
			}
			output.writeInt(temp_repeated_byte_titles.length);
			output.writeBytes(temp_repeated_byte_titles);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.roleid = input.readInt();
			this.rolename = input.readUTF();
			this.factionid = input.readInt();
			this.faction_name = input.readUTF();
			this.sex = input.readInt();
			this.head = input.readInt();
			this.sign = input.readUTF();
			var size_titles:int = input.readShort();
			var length_titles:int = input.readInt();
			if (length_titles > 0) {
				var byte_titles:ByteArray = new ByteArray; 
				input.readBytes(byte_titles, 0, length_titles);
				for(i=0; i<size_titles; i++) {
					var tmp_titles:p_chat_title = new p_chat_title;
					var tmp_titles_length:int = byte_titles.readInt();
					var tmp_titles_byte:ByteArray = new ByteArray;
					byte_titles.readBytes(tmp_titles_byte, 0, tmp_titles_length);
					tmp_titles.readFromDataOutput(tmp_titles_byte);
					this.titles.push(tmp_titles);
				}
			}
		}
	}
}
