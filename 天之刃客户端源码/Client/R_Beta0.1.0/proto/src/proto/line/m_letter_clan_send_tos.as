package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_letter_clan_send_tos extends Message
	{
		public var receiver:Array = new Array;
		public var text:String = "";
		public function m_letter_clan_send_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_letter_clan_send_tos", m_letter_clan_send_tos);
		}
		public override function getMethodName():String {
			return 'letter_clan_send';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_receiver:int = this.receiver.length;
			output.writeShort(size_receiver);
			var temp_repeated_byte_receiver:ByteArray= new ByteArray;
			for(i=0; i<size_receiver; i++) {
				if (this.receiver != null) {					temp_repeated_byte_receiver.writeUTF(this.receiver[i].toString());
				} else {
					temp_repeated_byte_receiver.writeUTF("");
				}
			}
			output.writeInt(temp_repeated_byte_receiver.length);
			output.writeBytes(temp_repeated_byte_receiver);
			if (this.text != null) {				output.writeUTF(this.text.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_receiver:int = input.readShort();
			var length_receiver:int = input.readInt();
			if (size_receiver>0) {
				var byte_receiver:ByteArray = new ByteArray; 
				input.readBytes(byte_receiver, 0, length_receiver);
				for(i=0; i<size_receiver; i++) {
					var tmp_receiver:String = byte_receiver.readUTF(); 
					this.receiver.push(tmp_receiver);
				}
			}
			this.text = input.readUTF();
		}
	}
}
