package proto.line {
	import proto.common.p_role_ext;
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_friend_info_toc extends Message
	{
		public var succ:Boolean = true;
		public var friend_info:p_role_ext = null;
		public var reason:String = "";
		public var equips:Array = new Array;
		public function m_friend_info_toc() {
			super();
			this.friend_info = new p_role_ext;

			flash.net.registerClassAlias("copy.proto.line.m_friend_info_toc", m_friend_info_toc);
		}
		public override function getMethodName():String {
			return 'friend_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			var tmp_friend_info:ByteArray = new ByteArray;
			this.friend_info.writeToDataOutput(tmp_friend_info);
			var size_tmp_friend_info:int = tmp_friend_info.length;
			output.writeInt(size_tmp_friend_info);
			output.writeBytes(tmp_friend_info);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var size_equips:int = this.equips.length;
			output.writeShort(size_equips);
			var temp_repeated_byte_equips:ByteArray= new ByteArray;
			for(i=0; i<size_equips; i++) {
				var t2_equips:ByteArray = new ByteArray;
				var tVo_equips:p_goods = this.equips[i] as p_goods;
				tVo_equips.writeToDataOutput(t2_equips);
				var len_tVo_equips:int = t2_equips.length;
				temp_repeated_byte_equips.writeInt(len_tVo_equips);
				temp_repeated_byte_equips.writeBytes(t2_equips);
			}
			output.writeInt(temp_repeated_byte_equips.length);
			output.writeBytes(temp_repeated_byte_equips);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			var byte_friend_info_size:int = input.readInt();
			if (byte_friend_info_size > 0) {				this.friend_info = new p_role_ext;
				var byte_friend_info:ByteArray = new ByteArray;
				input.readBytes(byte_friend_info, 0, byte_friend_info_size);
				this.friend_info.readFromDataOutput(byte_friend_info);
			}
			this.reason = input.readUTF();
			var size_equips:int = input.readShort();
			var length_equips:int = input.readInt();
			if (length_equips > 0) {
				var byte_equips:ByteArray = new ByteArray; 
				input.readBytes(byte_equips, 0, length_equips);
				for(i=0; i<size_equips; i++) {
					var tmp_equips:p_goods = new p_goods;
					var tmp_equips_length:int = byte_equips.readInt();
					var tmp_equips_byte:ByteArray = new ByteArray;
					byte_equips.readBytes(tmp_equips_byte, 0, tmp_equips_length);
					tmp_equips.readFromDataOutput(tmp_equips_byte);
					this.equips.push(tmp_equips);
				}
			}
		}
	}
}
