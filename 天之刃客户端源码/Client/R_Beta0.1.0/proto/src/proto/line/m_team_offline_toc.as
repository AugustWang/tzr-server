package proto.line {
	import proto.line.p_team_role;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_team_offline_toc extends Message
	{
		public var cache_offline:Boolean = false;
		public var role_list:Array = new Array;
		public var role_id:int = 0;
		public var role_name:String = "";
		public var team_id:int = 0;
		public function m_team_offline_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_team_offline_toc", m_team_offline_toc);
		}
		public override function getMethodName():String {
			return 'team_offline';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.cache_offline);
			var size_role_list:int = this.role_list.length;
			output.writeShort(size_role_list);
			var temp_repeated_byte_role_list:ByteArray= new ByteArray;
			for(i=0; i<size_role_list; i++) {
				var t2_role_list:ByteArray = new ByteArray;
				var tVo_role_list:p_team_role = this.role_list[i] as p_team_role;
				tVo_role_list.writeToDataOutput(t2_role_list);
				var len_tVo_role_list:int = t2_role_list.length;
				temp_repeated_byte_role_list.writeInt(len_tVo_role_list);
				temp_repeated_byte_role_list.writeBytes(t2_role_list);
			}
			output.writeInt(temp_repeated_byte_role_list.length);
			output.writeBytes(temp_repeated_byte_role_list);
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.team_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.cache_offline = input.readBoolean();
			var size_role_list:int = input.readShort();
			var length_role_list:int = input.readInt();
			if (length_role_list > 0) {
				var byte_role_list:ByteArray = new ByteArray; 
				input.readBytes(byte_role_list, 0, length_role_list);
				for(i=0; i<size_role_list; i++) {
					var tmp_role_list:p_team_role = new p_team_role;
					var tmp_role_list_length:int = byte_role_list.readInt();
					var tmp_role_list_byte:ByteArray = new ByteArray;
					byte_role_list.readBytes(tmp_role_list_byte, 0, tmp_role_list_length);
					tmp_role_list.readFromDataOutput(tmp_role_list_byte);
					this.role_list.push(tmp_role_list);
				}
			}
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.team_id = input.readInt();
		}
	}
}
