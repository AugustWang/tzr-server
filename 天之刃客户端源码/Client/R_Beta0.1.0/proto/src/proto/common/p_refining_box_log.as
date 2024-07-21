package proto.common {
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_refining_box_log extends Message
	{
		public var role_id:int = 0;
		public var role_sex:int = 0;
		public var role_name:String = "";
		public var faction_id:int = 0;
		public var award_time:int = 0;
		public var box_list:Array = new Array;
		public function p_refining_box_log() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_refining_box_log", p_refining_box_log);
		}
		public override function getMethodName():String {
			return 'refining_box';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			output.writeInt(this.role_sex);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.faction_id);
			output.writeInt(this.award_time);
			var size_box_list:int = this.box_list.length;
			output.writeShort(size_box_list);
			var temp_repeated_byte_box_list:ByteArray= new ByteArray;
			for(i=0; i<size_box_list; i++) {
				var t2_box_list:ByteArray = new ByteArray;
				var tVo_box_list:p_goods = this.box_list[i] as p_goods;
				tVo_box_list.writeToDataOutput(t2_box_list);
				var len_tVo_box_list:int = t2_box_list.length;
				temp_repeated_byte_box_list.writeInt(len_tVo_box_list);
				temp_repeated_byte_box_list.writeBytes(t2_box_list);
			}
			output.writeInt(temp_repeated_byte_box_list.length);
			output.writeBytes(temp_repeated_byte_box_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.role_sex = input.readInt();
			this.role_name = input.readUTF();
			this.faction_id = input.readInt();
			this.award_time = input.readInt();
			var size_box_list:int = input.readShort();
			var length_box_list:int = input.readInt();
			if (length_box_list > 0) {
				var byte_box_list:ByteArray = new ByteArray; 
				input.readBytes(byte_box_list, 0, length_box_list);
				for(i=0; i<size_box_list; i++) {
					var tmp_box_list:p_goods = new p_goods;
					var tmp_box_list_length:int = byte_box_list.readInt();
					var tmp_box_list_byte:ByteArray = new ByteArray;
					byte_box_list.readBytes(tmp_box_list_byte, 0, tmp_box_list_length);
					tmp_box_list.readFromDataOutput(tmp_box_list_byte);
					this.box_list.push(tmp_box_list);
				}
			}
		}
	}
}
