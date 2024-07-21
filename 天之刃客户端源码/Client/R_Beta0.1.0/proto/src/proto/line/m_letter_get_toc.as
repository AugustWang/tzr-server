package proto.line {
	import proto.line.p_letter_simple_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_letter_get_toc extends Message
	{
		public var letters:Array = new Array;
		public var request_mark:int = 0;
		public function m_letter_get_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_letter_get_toc", m_letter_get_toc);
		}
		public override function getMethodName():String {
			return 'letter_get';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_letters:int = this.letters.length;
			output.writeShort(size_letters);
			var temp_repeated_byte_letters:ByteArray= new ByteArray;
			for(i=0; i<size_letters; i++) {
				var t2_letters:ByteArray = new ByteArray;
				var tVo_letters:p_letter_simple_info = this.letters[i] as p_letter_simple_info;
				tVo_letters.writeToDataOutput(t2_letters);
				var len_tVo_letters:int = t2_letters.length;
				temp_repeated_byte_letters.writeInt(len_tVo_letters);
				temp_repeated_byte_letters.writeBytes(t2_letters);
			}
			output.writeInt(temp_repeated_byte_letters.length);
			output.writeBytes(temp_repeated_byte_letters);
			output.writeInt(this.request_mark);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_letters:int = input.readShort();
			var length_letters:int = input.readInt();
			if (length_letters > 0) {
				var byte_letters:ByteArray = new ByteArray; 
				input.readBytes(byte_letters, 0, length_letters);
				for(i=0; i<size_letters; i++) {
					var tmp_letters:p_letter_simple_info = new p_letter_simple_info;
					var tmp_letters_length:int = byte_letters.readInt();
					var tmp_letters_byte:ByteArray = new ByteArray;
					byte_letters.readBytes(tmp_letters_byte, 0, tmp_letters_length);
					tmp_letters.readFromDataOutput(tmp_letters_byte);
					this.letters.push(tmp_letters);
				}
			}
			this.request_mark = input.readInt();
		}
	}
}
