package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_do_tos extends Message
	{
		public var id:int = 0;
		public var npc_id:int = 0;
		public var prop_choose:Array = new Array;
		public var int_list_1:Array = new Array;
		public var int_list_2:Array = new Array;
		public function m_mission_do_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_mission_do_tos", m_mission_do_tos);
		}
		public override function getMethodName():String {
			return 'mission_do';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.npc_id);
			var size_prop_choose:int = this.prop_choose.length;
			output.writeShort(size_prop_choose);
			var temp_repeated_byte_prop_choose:ByteArray= new ByteArray;
			for(i=0; i<size_prop_choose; i++) {
				temp_repeated_byte_prop_choose.writeInt(this.prop_choose[i]);
			}
			output.writeInt(temp_repeated_byte_prop_choose.length);
			output.writeBytes(temp_repeated_byte_prop_choose);
			var size_int_list_1:int = this.int_list_1.length;
			output.writeShort(size_int_list_1);
			var temp_repeated_byte_int_list_1:ByteArray= new ByteArray;
			for(i=0; i<size_int_list_1; i++) {
				temp_repeated_byte_int_list_1.writeInt(this.int_list_1[i]);
			}
			output.writeInt(temp_repeated_byte_int_list_1.length);
			output.writeBytes(temp_repeated_byte_int_list_1);
			var size_int_list_2:int = this.int_list_2.length;
			output.writeShort(size_int_list_2);
			var temp_repeated_byte_int_list_2:ByteArray= new ByteArray;
			for(i=0; i<size_int_list_2; i++) {
				temp_repeated_byte_int_list_2.writeInt(this.int_list_2[i]);
			}
			output.writeInt(temp_repeated_byte_int_list_2.length);
			output.writeBytes(temp_repeated_byte_int_list_2);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.npc_id = input.readInt();
			var size_prop_choose:int = input.readShort();
			var length_prop_choose:int = input.readInt();
			var byte_prop_choose:ByteArray = new ByteArray; 
			if (size_prop_choose > 0) {
				input.readBytes(byte_prop_choose, 0, size_prop_choose * 4);
				for(i=0; i<size_prop_choose; i++) {
					var tmp_prop_choose:int = byte_prop_choose.readInt();
					this.prop_choose.push(tmp_prop_choose);
				}
			}
			var size_int_list_1:int = input.readShort();
			var length_int_list_1:int = input.readInt();
			var byte_int_list_1:ByteArray = new ByteArray; 
			if (size_int_list_1 > 0) {
				input.readBytes(byte_int_list_1, 0, size_int_list_1 * 4);
				for(i=0; i<size_int_list_1; i++) {
					var tmp_int_list_1:int = byte_int_list_1.readInt();
					this.int_list_1.push(tmp_int_list_1);
				}
			}
			var size_int_list_2:int = input.readShort();
			var length_int_list_2:int = input.readInt();
			var byte_int_list_2:ByteArray = new ByteArray; 
			if (size_int_list_2 > 0) {
				input.readBytes(byte_int_list_2, 0, size_int_list_2 * 4);
				for(i=0; i<size_int_list_2; i++) {
					var tmp_int_list_2:int = byte_int_list_2.readInt();
					this.int_list_2.push(tmp_int_list_2);
				}
			}
		}
	}
}
