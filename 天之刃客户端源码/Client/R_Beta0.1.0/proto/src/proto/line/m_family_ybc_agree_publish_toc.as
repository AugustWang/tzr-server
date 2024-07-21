package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_ybc_agree_publish_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public var role_id:int = 0;
		public var role_name:String = "";
		public var silver:int = 0;
		public var begin_time:int = 0;
		public var ybc_role_id_list:Array = new Array;
		public function m_family_ybc_agree_publish_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_ybc_agree_publish_toc", m_family_ybc_agree_publish_toc);
		}
		public override function getMethodName():String {
			return 'family_ybc_agree_publish';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.silver);
			output.writeInt(this.begin_time);
			var size_ybc_role_id_list:int = this.ybc_role_id_list.length;
			output.writeShort(size_ybc_role_id_list);
			var temp_repeated_byte_ybc_role_id_list:ByteArray= new ByteArray;
			for(i=0; i<size_ybc_role_id_list; i++) {
				temp_repeated_byte_ybc_role_id_list.writeInt(this.ybc_role_id_list[i]);
			}
			output.writeInt(temp_repeated_byte_ybc_role_id_list.length);
			output.writeBytes(temp_repeated_byte_ybc_role_id_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.silver = input.readInt();
			this.begin_time = input.readInt();
			var size_ybc_role_id_list:int = input.readShort();
			var length_ybc_role_id_list:int = input.readInt();
			var byte_ybc_role_id_list:ByteArray = new ByteArray; 
			if (size_ybc_role_id_list > 0) {
				input.readBytes(byte_ybc_role_id_list, 0, size_ybc_role_id_list * 4);
				for(i=0; i<size_ybc_role_id_list; i++) {
					var tmp_ybc_role_id_list:int = byte_ybc_role_id_list.readInt();
					this.ybc_role_id_list.push(tmp_ybc_role_id_list);
				}
			}
		}
	}
}
