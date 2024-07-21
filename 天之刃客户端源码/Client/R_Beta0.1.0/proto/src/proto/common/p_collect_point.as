package proto.common {
	import proto.common.p_pos;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_collect_point extends Message
	{
		public var id:int = 0;
		public var typeid:int = 0;
		public var state:int = 0;
		public var pos:p_pos = null;
		public var start_time:int = 0;
		public var ripening_time:int = 0;
		public var end_time:int = 0;
		public var refresh:p_collect_refresh = null;
		public var id_list:Array = new Array;
		public var drop_type:int = 0;
		public var max_num:int = 0;
		public var grafts:Array = new Array;
		public function p_collect_point() {
			super();
			this.pos = new p_pos;
			this.refresh = new p_collect_refresh;

			flash.net.registerClassAlias("copy.proto.common.p_collect_point", p_collect_point);
		}
		public override function getMethodName():String {
			return 'collect_p';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.typeid);
			output.writeInt(this.state);
			var tmp_pos:ByteArray = new ByteArray;
			this.pos.writeToDataOutput(tmp_pos);
			var size_tmp_pos:int = tmp_pos.length;
			output.writeInt(size_tmp_pos);
			output.writeBytes(tmp_pos);
			output.writeInt(this.start_time);
			output.writeInt(this.ripening_time);
			output.writeInt(this.end_time);
			var tmp_refresh:ByteArray = new ByteArray;
			this.refresh.writeToDataOutput(tmp_refresh);
			var size_tmp_refresh:int = tmp_refresh.length;
			output.writeInt(size_tmp_refresh);
			output.writeBytes(tmp_refresh);
			var size_id_list:int = this.id_list.length;
			output.writeShort(size_id_list);
			var temp_repeated_byte_id_list:ByteArray= new ByteArray;
			for(i=0; i<size_id_list; i++) {
				temp_repeated_byte_id_list.writeInt(this.id_list[i]);
			}
			output.writeInt(temp_repeated_byte_id_list.length);
			output.writeBytes(temp_repeated_byte_id_list);
			output.writeInt(this.drop_type);
			output.writeInt(this.max_num);
			var size_grafts:int = this.grafts.length;
			output.writeShort(size_grafts);
			var temp_repeated_byte_grafts:ByteArray= new ByteArray;
			for(i=0; i<size_grafts; i++) {
				var t2_grafts:ByteArray = new ByteArray;
				var tVo_grafts:p_collect = this.grafts[i] as p_collect;
				tVo_grafts.writeToDataOutput(t2_grafts);
				var len_tVo_grafts:int = t2_grafts.length;
				temp_repeated_byte_grafts.writeInt(len_tVo_grafts);
				temp_repeated_byte_grafts.writeBytes(t2_grafts);
			}
			output.writeInt(temp_repeated_byte_grafts.length);
			output.writeBytes(temp_repeated_byte_grafts);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.typeid = input.readInt();
			this.state = input.readInt();
			var byte_pos_size:int = input.readInt();
			if (byte_pos_size > 0) {				this.pos = new p_pos;
				var byte_pos:ByteArray = new ByteArray;
				input.readBytes(byte_pos, 0, byte_pos_size);
				this.pos.readFromDataOutput(byte_pos);
			}
			this.start_time = input.readInt();
			this.ripening_time = input.readInt();
			this.end_time = input.readInt();
			var byte_refresh_size:int = input.readInt();
			if (byte_refresh_size > 0) {				this.refresh = new p_collect_refresh;
				var byte_refresh:ByteArray = new ByteArray;
				input.readBytes(byte_refresh, 0, byte_refresh_size);
				this.refresh.readFromDataOutput(byte_refresh);
			}
			var size_id_list:int = input.readShort();
			var length_id_list:int = input.readInt();
			var byte_id_list:ByteArray = new ByteArray; 
			if (size_id_list > 0) {
				input.readBytes(byte_id_list, 0, size_id_list * 4);
				for(i=0; i<size_id_list; i++) {
					var tmp_id_list:int = byte_id_list.readInt();
					this.id_list.push(tmp_id_list);
				}
			}
			this.drop_type = input.readInt();
			this.max_num = input.readInt();
			var size_grafts:int = input.readShort();
			var length_grafts:int = input.readInt();
			if (length_grafts > 0) {
				var byte_grafts:ByteArray = new ByteArray; 
				input.readBytes(byte_grafts, 0, length_grafts);
				for(i=0; i<size_grafts; i++) {
					var tmp_grafts:p_collect = new p_collect;
					var tmp_grafts_length:int = byte_grafts.readInt();
					var tmp_grafts_byte:ByteArray = new ByteArray;
					byte_grafts.readBytes(tmp_grafts_byte, 0, tmp_grafts_length);
					tmp_grafts.readFromDataOutput(tmp_grafts_byte);
					this.grafts.push(tmp_grafts);
				}
			}
		}
	}
}
