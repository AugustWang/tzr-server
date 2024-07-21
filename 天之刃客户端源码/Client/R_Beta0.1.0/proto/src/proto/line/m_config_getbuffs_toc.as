package proto.line {
	import proto.common.p_buf;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_config_getbuffs_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var buffs:Array = new Array;
		public function m_config_getbuffs_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_config_getbuffs_toc", m_config_getbuffs_toc);
		}
		public override function getMethodName():String {
			return 'config_getbuffs';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var size_buffs:int = this.buffs.length;
			output.writeShort(size_buffs);
			var temp_repeated_byte_buffs:ByteArray= new ByteArray;
			for(i=0; i<size_buffs; i++) {
				var t2_buffs:ByteArray = new ByteArray;
				var tVo_buffs:p_buf = this.buffs[i] as p_buf;
				tVo_buffs.writeToDataOutput(t2_buffs);
				var len_tVo_buffs:int = t2_buffs.length;
				temp_repeated_byte_buffs.writeInt(len_tVo_buffs);
				temp_repeated_byte_buffs.writeBytes(t2_buffs);
			}
			output.writeInt(temp_repeated_byte_buffs.length);
			output.writeBytes(temp_repeated_byte_buffs);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var size_buffs:int = input.readShort();
			var length_buffs:int = input.readInt();
			if (length_buffs > 0) {
				var byte_buffs:ByteArray = new ByteArray; 
				input.readBytes(byte_buffs, 0, length_buffs);
				for(i=0; i<size_buffs; i++) {
					var tmp_buffs:p_buf = new p_buf;
					var tmp_buffs_length:int = byte_buffs.readInt();
					var tmp_buffs_byte:ByteArray = new ByteArray;
					byte_buffs.readBytes(tmp_buffs_byte, 0, tmp_buffs_length);
					tmp_buffs.readFromDataOutput(tmp_buffs_byte);
					this.buffs.push(tmp_buffs);
				}
			}
		}
	}
}
