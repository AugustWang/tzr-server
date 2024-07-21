package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_letter_send_condition extends Message
	{
		public var receiver:Array = new Array;
		public var time:Array = new Array;
		public var grade:Array = new Array;
		public var sex:int = 0;
		public var factionid:int = 0;
		public function p_letter_send_condition() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_letter_send_condition", p_letter_send_condition);
		}
		public override function getMethodName():String {
			return 'letter_send_condi';
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
			var size_time:int = this.time.length;
			output.writeShort(size_time);
			var temp_repeated_byte_time:ByteArray= new ByteArray;
			for(i=0; i<size_time; i++) {
				temp_repeated_byte_time.writeInt(this.time[i]);
			}
			output.writeInt(temp_repeated_byte_time.length);
			output.writeBytes(temp_repeated_byte_time);
			var size_grade:int = this.grade.length;
			output.writeShort(size_grade);
			var temp_repeated_byte_grade:ByteArray= new ByteArray;
			for(i=0; i<size_grade; i++) {
				temp_repeated_byte_grade.writeInt(this.grade[i]);
			}
			output.writeInt(temp_repeated_byte_grade.length);
			output.writeBytes(temp_repeated_byte_grade);
			output.writeInt(this.sex);
			output.writeInt(this.factionid);
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
			var size_time:int = input.readShort();
			var length_time:int = input.readInt();
			var byte_time:ByteArray = new ByteArray; 
			if (size_time > 0) {
				input.readBytes(byte_time, 0, size_time * 4);
				for(i=0; i<size_time; i++) {
					var tmp_time:int = byte_time.readInt();
					this.time.push(tmp_time);
				}
			}
			var size_grade:int = input.readShort();
			var length_grade:int = input.readInt();
			var byte_grade:ByteArray = new ByteArray; 
			if (size_grade > 0) {
				input.readBytes(byte_grade, 0, size_grade * 4);
				for(i=0; i<size_grade; i++) {
					var tmp_grade:int = byte_grade.readInt();
					this.grade.push(tmp_grade);
				}
			}
			this.sex = input.readInt();
			this.factionid = input.readInt();
		}
	}
}
