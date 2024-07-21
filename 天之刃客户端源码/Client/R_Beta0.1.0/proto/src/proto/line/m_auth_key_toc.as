package proto.line {
	import proto.common.p_role;
	import proto.common.p_family_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_auth_key_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var role_details:p_role = null;
		public var bags:Array = new Array;
		public var family:p_family_info = null;
		public var server_time:int = 0;
		public function m_auth_key_toc() {
			super();
			this.role_details = new p_role;
			this.family = new p_family_info;

			flash.net.registerClassAlias("copy.proto.line.m_auth_key_toc", m_auth_key_toc);
		}
		public override function getMethodName():String {
			return 'auth_key';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_role_details:ByteArray = new ByteArray;
			this.role_details.writeToDataOutput(tmp_role_details);
			var size_tmp_role_details:int = tmp_role_details.length;
			output.writeInt(size_tmp_role_details);
			output.writeBytes(tmp_role_details);
			var size_bags:int = this.bags.length;
			output.writeShort(size_bags);
			var temp_repeated_byte_bags:ByteArray= new ByteArray;
			for(i=0; i<size_bags; i++) {
				var t2_bags:ByteArray = new ByteArray;
				var tVo_bags:p_bag_content = this.bags[i] as p_bag_content;
				tVo_bags.writeToDataOutput(t2_bags);
				var len_tVo_bags:int = t2_bags.length;
				temp_repeated_byte_bags.writeInt(len_tVo_bags);
				temp_repeated_byte_bags.writeBytes(t2_bags);
			}
			output.writeInt(temp_repeated_byte_bags.length);
			output.writeBytes(temp_repeated_byte_bags);
			var tmp_family:ByteArray = new ByteArray;
			this.family.writeToDataOutput(tmp_family);
			var size_tmp_family:int = tmp_family.length;
			output.writeInt(size_tmp_family);
			output.writeBytes(tmp_family);
			output.writeInt(this.server_time);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var byte_role_details_size:int = input.readInt();
			if (byte_role_details_size > 0) {				this.role_details = new p_role;
				var byte_role_details:ByteArray = new ByteArray;
				input.readBytes(byte_role_details, 0, byte_role_details_size);
				this.role_details.readFromDataOutput(byte_role_details);
			}
			var size_bags:int = input.readShort();
			var length_bags:int = input.readInt();
			if (length_bags > 0) {
				var byte_bags:ByteArray = new ByteArray; 
				input.readBytes(byte_bags, 0, length_bags);
				for(i=0; i<size_bags; i++) {
					var tmp_bags:p_bag_content = new p_bag_content;
					var tmp_bags_length:int = byte_bags.readInt();
					var tmp_bags_byte:ByteArray = new ByteArray;
					byte_bags.readBytes(tmp_bags_byte, 0, tmp_bags_length);
					tmp_bags.readFromDataOutput(tmp_bags_byte);
					this.bags.push(tmp_bags);
				}
			}
			var byte_family_size:int = input.readInt();
			if (byte_family_size > 0) {				this.family = new p_family_info;
				var byte_family:ByteArray = new ByteArray;
				input.readBytes(byte_family, 0, byte_family_size);
				this.family.readFromDataOutput(byte_family);
			}
			this.server_time = input.readInt();
		}
	}
}
