package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_broadcast_general_tos extends Message
	{
		public var type:int = 0;
		public var sub_type:int = 0;
		public var content:String = "";
		public var role_list:Array = new Array;
		public var is_world:Boolean = false;
		public var country_id:int = 0;
		public var famliy_id:int = 0;
		public var team_id:int = 0;
		public function m_broadcast_general_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_broadcast_general_tos", m_broadcast_general_tos);
		}
		public override function getMethodName():String {
			return 'broadcast_general';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
			output.writeInt(this.sub_type);
			if (this.content != null) {				output.writeUTF(this.content.toString());
			} else {
				output.writeUTF("");
			}
			var size_role_list:int = this.role_list.length;
			output.writeShort(size_role_list);
			var temp_repeated_byte_role_list:ByteArray= new ByteArray;
			for(i=0; i<size_role_list; i++) {
				temp_repeated_byte_role_list.writeInt(this.role_list[i]);
			}
			output.writeInt(temp_repeated_byte_role_list.length);
			output.writeBytes(temp_repeated_byte_role_list);
			output.writeBoolean(this.is_world);
			output.writeInt(this.country_id);
			output.writeInt(this.famliy_id);
			output.writeInt(this.team_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
			this.sub_type = input.readInt();
			this.content = input.readUTF();
			var size_role_list:int = input.readShort();
			var length_role_list:int = input.readInt();
			var byte_role_list:ByteArray = new ByteArray; 
			if (size_role_list > 0) {
				input.readBytes(byte_role_list, 0, size_role_list * 4);
				for(i=0; i<size_role_list; i++) {
					var tmp_role_list:int = byte_role_list.readInt();
					this.role_list.push(tmp_role_list);
				}
			}
			this.is_world = input.readBoolean();
			this.country_id = input.readInt();
			this.famliy_id = input.readInt();
			this.team_id = input.readInt();
		}
	}
}
