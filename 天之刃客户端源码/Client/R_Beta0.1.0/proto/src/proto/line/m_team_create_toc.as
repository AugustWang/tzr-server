package proto.line {
	import proto.line.p_team_role;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_team_create_toc extends Message
	{
		public var role_id:int = 0;
		public var succ:Boolean = true;
		public var reason:String = "";
		public var reason_code:int = 0;
		public var role_list:Array = new Array;
		public var team_id:int = 0;
		public var pick_type:int = 1;
		public function m_team_create_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_team_create_toc", m_team_create_toc);
		}
		public override function getMethodName():String {
			return 'team_create';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.reason_code);
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
			output.writeInt(this.team_id);
			output.writeInt(this.pick_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.reason_code = input.readInt();
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
			this.team_id = input.readInt();
			this.pick_type = input.readInt();
		}
	}
}
