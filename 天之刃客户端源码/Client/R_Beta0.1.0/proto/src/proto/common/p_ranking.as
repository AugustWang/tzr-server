package proto.common {
	import proto.common.p_rank_element;
	import proto.common.p_title;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_ranking extends Message
	{
		public var rank_id:int = 0;
		public var rank_row:int = 0;
		public var rank_column:int = 0;
		public var rank_first_name:String = "";
		public var rank_second_name:String = "";
		public var capacity:int = 0;
		public var elements:Array = new Array;
		public var refresh_type:int = 0;
		public var refresh_interval:int = 0;
		public var rank_title:p_title = null;
		public function p_ranking() {
			super();
			this.rank_title = new p_title;

			flash.net.registerClassAlias("copy.proto.common.p_ranking", p_ranking);
		}
		public override function getMethodName():String {
			return 'ran';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.rank_id);
			output.writeInt(this.rank_row);
			output.writeInt(this.rank_column);
			if (this.rank_first_name != null) {				output.writeUTF(this.rank_first_name.toString());
			} else {
				output.writeUTF("");
			}
			if (this.rank_second_name != null) {				output.writeUTF(this.rank_second_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.capacity);
			var size_elements:int = this.elements.length;
			output.writeShort(size_elements);
			var temp_repeated_byte_elements:ByteArray= new ByteArray;
			for(i=0; i<size_elements; i++) {
				var t2_elements:ByteArray = new ByteArray;
				var tVo_elements:p_rank_element = this.elements[i] as p_rank_element;
				tVo_elements.writeToDataOutput(t2_elements);
				var len_tVo_elements:int = t2_elements.length;
				temp_repeated_byte_elements.writeInt(len_tVo_elements);
				temp_repeated_byte_elements.writeBytes(t2_elements);
			}
			output.writeInt(temp_repeated_byte_elements.length);
			output.writeBytes(temp_repeated_byte_elements);
			output.writeInt(this.refresh_type);
			output.writeInt(this.refresh_interval);
			var tmp_rank_title:ByteArray = new ByteArray;
			this.rank_title.writeToDataOutput(tmp_rank_title);
			var size_tmp_rank_title:int = tmp_rank_title.length;
			output.writeInt(size_tmp_rank_title);
			output.writeBytes(tmp_rank_title);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.rank_id = input.readInt();
			this.rank_row = input.readInt();
			this.rank_column = input.readInt();
			this.rank_first_name = input.readUTF();
			this.rank_second_name = input.readUTF();
			this.capacity = input.readInt();
			var size_elements:int = input.readShort();
			var length_elements:int = input.readInt();
			if (length_elements > 0) {
				var byte_elements:ByteArray = new ByteArray; 
				input.readBytes(byte_elements, 0, length_elements);
				for(i=0; i<size_elements; i++) {
					var tmp_elements:p_rank_element = new p_rank_element;
					var tmp_elements_length:int = byte_elements.readInt();
					var tmp_elements_byte:ByteArray = new ByteArray;
					byte_elements.readBytes(tmp_elements_byte, 0, tmp_elements_length);
					tmp_elements.readFromDataOutput(tmp_elements_byte);
					this.elements.push(tmp_elements);
				}
			}
			this.refresh_type = input.readInt();
			this.refresh_interval = input.readInt();
			var byte_rank_title_size:int = input.readInt();
			if (byte_rank_title_size > 0) {				this.rank_title = new p_title;
				var byte_rank_title:ByteArray = new ByteArray;
				input.readBytes(byte_rank_title, 0, byte_rank_title_size);
				this.rank_title.readFromDataOutput(byte_rank_title);
			}
		}
	}
}
