package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_mission_listener extends Message
	{
		public var type:int = 0;
		public var value:int = 0;
		public var int_list:Array = new Array;
		public var need_num:int = 0;
		public var current_num:int = 0;
		public function p_mission_listener() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_mission_listener", p_mission_listener);
		}
		public override function getMethodName():String {
			return 'mission_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
			output.writeInt(this.value);
			var size_int_list:int = this.int_list.length;
			output.writeShort(size_int_list);
			var temp_repeated_byte_int_list:ByteArray= new ByteArray;
			for(i=0; i<size_int_list; i++) {
				temp_repeated_byte_int_list.writeInt(this.int_list[i]);
			}
			output.writeInt(temp_repeated_byte_int_list.length);
			output.writeBytes(temp_repeated_byte_int_list);
			output.writeInt(this.need_num);
			output.writeInt(this.current_num);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
			this.value = input.readInt();
			var size_int_list:int = input.readShort();
			var length_int_list:int = input.readInt();
			var byte_int_list:ByteArray = new ByteArray; 
			if (size_int_list > 0) {
				input.readBytes(byte_int_list, 0, size_int_list * 4);
				for(i=0; i<size_int_list; i++) {
					var tmp_int_list:int = byte_int_list.readInt();
					this.int_list.push(tmp_int_list);
				}
			}
			this.need_num = input.readInt();
			this.current_num = input.readInt();
		}
	}
}
