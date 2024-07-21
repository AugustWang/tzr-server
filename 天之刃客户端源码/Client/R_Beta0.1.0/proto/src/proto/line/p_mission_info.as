package proto.line {
	import proto.line.p_mission_listener;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_mission_info extends Message
	{
		public var id:int = 0;
		public var model:int = 0;
		public var type:int = 0;
		public var current_status:int = 0;
		public var pre_status:int = 0;
		public var current_model_status:int = 0;
		public var pre_model_status:int = 0;
		public var commit_times:int = 0;
		public var succ_times:int = 0;
		public var accept_time:int = 0;
		public var accept_level:int = 0;
		public var status_change_time:int = 0;
		public var listener_list:Array = new Array;
		public var int_list_1:Array = new Array;
		public var int_list_2:Array = new Array;
		public var int_list_3:Array = new Array;
		public var int_list_4:Array = new Array;
		public function p_mission_info() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_mission_info", p_mission_info);
		}
		public override function getMethodName():String {
			return 'mission_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.model);
			output.writeInt(this.type);
			output.writeInt(this.current_status);
			output.writeInt(this.pre_status);
			output.writeInt(this.current_model_status);
			output.writeInt(this.pre_model_status);
			output.writeInt(this.commit_times);
			output.writeInt(this.succ_times);
			output.writeInt(this.accept_time);
			output.writeInt(this.accept_level);
			output.writeInt(this.status_change_time);
			var size_listener_list:int = this.listener_list.length;
			output.writeShort(size_listener_list);
			var temp_repeated_byte_listener_list:ByteArray= new ByteArray;
			for(i=0; i<size_listener_list; i++) {
				var t2_listener_list:ByteArray = new ByteArray;
				var tVo_listener_list:p_mission_listener = this.listener_list[i] as p_mission_listener;
				tVo_listener_list.writeToDataOutput(t2_listener_list);
				var len_tVo_listener_list:int = t2_listener_list.length;
				temp_repeated_byte_listener_list.writeInt(len_tVo_listener_list);
				temp_repeated_byte_listener_list.writeBytes(t2_listener_list);
			}
			output.writeInt(temp_repeated_byte_listener_list.length);
			output.writeBytes(temp_repeated_byte_listener_list);
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
			var size_int_list_3:int = this.int_list_3.length;
			output.writeShort(size_int_list_3);
			var temp_repeated_byte_int_list_3:ByteArray= new ByteArray;
			for(i=0; i<size_int_list_3; i++) {
				temp_repeated_byte_int_list_3.writeInt(this.int_list_3[i]);
			}
			output.writeInt(temp_repeated_byte_int_list_3.length);
			output.writeBytes(temp_repeated_byte_int_list_3);
			var size_int_list_4:int = this.int_list_4.length;
			output.writeShort(size_int_list_4);
			var temp_repeated_byte_int_list_4:ByteArray= new ByteArray;
			for(i=0; i<size_int_list_4; i++) {
				temp_repeated_byte_int_list_4.writeInt(this.int_list_4[i]);
			}
			output.writeInt(temp_repeated_byte_int_list_4.length);
			output.writeBytes(temp_repeated_byte_int_list_4);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.model = input.readInt();
			this.type = input.readInt();
			this.current_status = input.readInt();
			this.pre_status = input.readInt();
			this.current_model_status = input.readInt();
			this.pre_model_status = input.readInt();
			this.commit_times = input.readInt();
			this.succ_times = input.readInt();
			this.accept_time = input.readInt();
			this.accept_level = input.readInt();
			this.status_change_time = input.readInt();
			var size_listener_list:int = input.readShort();
			var length_listener_list:int = input.readInt();
			if (length_listener_list > 0) {
				var byte_listener_list:ByteArray = new ByteArray; 
				input.readBytes(byte_listener_list, 0, length_listener_list);
				for(i=0; i<size_listener_list; i++) {
					var tmp_listener_list:p_mission_listener = new p_mission_listener;
					var tmp_listener_list_length:int = byte_listener_list.readInt();
					var tmp_listener_list_byte:ByteArray = new ByteArray;
					byte_listener_list.readBytes(tmp_listener_list_byte, 0, tmp_listener_list_length);
					tmp_listener_list.readFromDataOutput(tmp_listener_list_byte);
					this.listener_list.push(tmp_listener_list);
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
			var size_int_list_3:int = input.readShort();
			var length_int_list_3:int = input.readInt();
			var byte_int_list_3:ByteArray = new ByteArray; 
			if (size_int_list_3 > 0) {
				input.readBytes(byte_int_list_3, 0, size_int_list_3 * 4);
				for(i=0; i<size_int_list_3; i++) {
					var tmp_int_list_3:int = byte_int_list_3.readInt();
					this.int_list_3.push(tmp_int_list_3);
				}
			}
			var size_int_list_4:int = input.readShort();
			var length_int_list_4:int = input.readInt();
			var byte_int_list_4:ByteArray = new ByteArray; 
			if (size_int_list_4 > 0) {
				input.readBytes(byte_int_list_4, 0, size_int_list_4 * 4);
				for(i=0; i<size_int_list_4; i++) {
					var tmp_int_list_4:int = byte_int_list_4.readInt();
					this.int_list_4.push(tmp_int_list_4);
				}
			}
		}
	}
}
