package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_letter_delete_tos extends Message
	{
		public var letters:Array = new Array;
		public function m_letter_delete_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_letter_delete_tos", m_letter_delete_tos);
		}
		public override function getMethodName():String {
			return 'letter_delete';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_letters:int = this.letters.length;
			output.writeShort(size_letters);
			var temp_repeated_byte_letters:ByteArray= new ByteArray;
			for(i=0; i<size_letters; i++) {
				var t2_letters:ByteArray = new ByteArray;
				var tVo_letters:p_letter_delete = this.letters[i] as p_letter_delete;
				tVo_letters.writeToDataOutput(t2_letters);
				var len_tVo_letters:int = t2_letters.length;
				temp_repeated_byte_letters.writeInt(len_tVo_letters);
				temp_repeated_byte_letters.writeBytes(t2_letters);
			}
			output.writeInt(temp_repeated_byte_letters.length);
			output.writeBytes(temp_repeated_byte_letters);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_letters:int = input.readShort();
			var length_letters:int = input.readInt();
			if (length_letters > 0) {
				var byte_letters:ByteArray = new ByteArray; 
				input.readBytes(byte_letters, 0, length_letters);
				for(i=0; i<size_letters; i++) {
					var tmp_letters:p_letter_delete = new p_letter_delete;
					var tmp_letters_length:int = byte_letters.readInt();
					var tmp_letters_byte:ByteArray = new ByteArray;
					byte_letters.readBytes(tmp_letters_byte, 0, tmp_letters_length);
					tmp_letters.readFromDataOutput(tmp_letters_byte);
					this.letters.push(tmp_letters);
				}
			}
		}
	}
}
