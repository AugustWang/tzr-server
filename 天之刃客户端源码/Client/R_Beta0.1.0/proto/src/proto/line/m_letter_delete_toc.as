package proto.line {
	import proto.line.p_letter_delete;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_letter_delete_toc extends Message
	{
		public var succ:Boolean = true;
		public var no_del:Array = new Array;
		public var reason:String = "";
		public function m_letter_delete_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_letter_delete_toc", m_letter_delete_toc);
		}
		public override function getMethodName():String {
			return 'letter_delete';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			var size_no_del:int = this.no_del.length;
			output.writeShort(size_no_del);
			var temp_repeated_byte_no_del:ByteArray= new ByteArray;
			for(i=0; i<size_no_del; i++) {
				var t2_no_del:ByteArray = new ByteArray;
				var tVo_no_del:p_letter_delete = this.no_del[i] as p_letter_delete;
				tVo_no_del.writeToDataOutput(t2_no_del);
				var len_tVo_no_del:int = t2_no_del.length;
				temp_repeated_byte_no_del.writeInt(len_tVo_no_del);
				temp_repeated_byte_no_del.writeBytes(t2_no_del);
			}
			output.writeInt(temp_repeated_byte_no_del.length);
			output.writeBytes(temp_repeated_byte_no_del);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			var size_no_del:int = input.readShort();
			var length_no_del:int = input.readInt();
			if (length_no_del > 0) {
				var byte_no_del:ByteArray = new ByteArray; 
				input.readBytes(byte_no_del, 0, length_no_del);
				for(i=0; i<size_no_del; i++) {
					var tmp_no_del:p_letter_delete = new p_letter_delete;
					var tmp_no_del_length:int = byte_no_del.readInt();
					var tmp_no_del_byte:ByteArray = new ByteArray;
					byte_no_del.readBytes(tmp_no_del_byte, 0, tmp_no_del_length);
					tmp_no_del.readFromDataOutput(tmp_no_del_byte);
					this.no_del.push(tmp_no_del);
				}
			}
			this.reason = input.readUTF();
		}
	}
}
