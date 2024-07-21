package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_office extends Message
	{
		public var faction_id:int = 0;
		public var king_role_id:int = 0;
		public var king_role_name:String = "";
		public var king_head:int = 0;
		public var offices:Array = new Array;
		public function p_office() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_office", p_office);
		}
		public override function getMethodName():String {
			return 'of';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.faction_id);
			output.writeInt(this.king_role_id);
			if (this.king_role_name != null) {				output.writeUTF(this.king_role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.king_head);
			var size_offices:int = this.offices.length;
			output.writeShort(size_offices);
			var temp_repeated_byte_offices:ByteArray= new ByteArray;
			for(i=0; i<size_offices; i++) {
				var t2_offices:ByteArray = new ByteArray;
				var tVo_offices:p_office_position = this.offices[i] as p_office_position;
				tVo_offices.writeToDataOutput(t2_offices);
				var len_tVo_offices:int = t2_offices.length;
				temp_repeated_byte_offices.writeInt(len_tVo_offices);
				temp_repeated_byte_offices.writeBytes(t2_offices);
			}
			output.writeInt(temp_repeated_byte_offices.length);
			output.writeBytes(temp_repeated_byte_offices);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.faction_id = input.readInt();
			this.king_role_id = input.readInt();
			this.king_role_name = input.readUTF();
			this.king_head = input.readInt();
			var size_offices:int = input.readShort();
			var length_offices:int = input.readInt();
			if (length_offices > 0) {
				var byte_offices:ByteArray = new ByteArray; 
				input.readBytes(byte_offices, 0, length_offices);
				for(i=0; i<size_offices; i++) {
					var tmp_offices:p_office_position = new p_office_position;
					var tmp_offices_length:int = byte_offices.readInt();
					var tmp_offices_byte:ByteArray = new ByteArray;
					byte_offices.readBytes(tmp_offices_byte, 0, tmp_offices_length);
					tmp_offices.readFromDataOutput(tmp_offices_byte);
					this.offices.push(tmp_offices);
				}
			}
		}
	}
}
