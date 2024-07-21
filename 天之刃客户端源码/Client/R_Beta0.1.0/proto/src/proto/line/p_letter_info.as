package proto.line {
	import proto.common.p_goods;
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_letter_info extends Message
	{
		public var id:int = 0;
		public var sender:String = "";
		public var receiver:String = "";
		public var title:String = "";
		public var send_time:int = 0;
		public var type:int = 0;
		public var goods_list:Array = new Array;
		public var goods_take:Array = new Array;
		public var state:int = 1;
		public var letter_content:String = "";
		public var table:int = 0;
		public function p_letter_info() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_letter_info", p_letter_info);
		}
		public override function getMethodName():String {
			return 'letter_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			if (this.sender != null) {				output.writeUTF(this.sender.toString());
			} else {
				output.writeUTF("");
			}
			if (this.receiver != null) {				output.writeUTF(this.receiver.toString());
			} else {
				output.writeUTF("");
			}
			if (this.title != null) {				output.writeUTF(this.title.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.send_time);
			output.writeInt(this.type);
			var size_goods_list:int = this.goods_list.length;
			output.writeShort(size_goods_list);
			var temp_repeated_byte_goods_list:ByteArray= new ByteArray;
			for(i=0; i<size_goods_list; i++) {
				var t2_goods_list:ByteArray = new ByteArray;
				var tVo_goods_list:p_goods = this.goods_list[i] as p_goods;
				tVo_goods_list.writeToDataOutput(t2_goods_list);
				var len_tVo_goods_list:int = t2_goods_list.length;
				temp_repeated_byte_goods_list.writeInt(len_tVo_goods_list);
				temp_repeated_byte_goods_list.writeBytes(t2_goods_list);
			}
			output.writeInt(temp_repeated_byte_goods_list.length);
			output.writeBytes(temp_repeated_byte_goods_list);
			var size_goods_take:int = this.goods_take.length;
			output.writeShort(size_goods_take);
			var temp_repeated_byte_goods_take:ByteArray= new ByteArray;
			for(i=0; i<size_goods_take; i++) {
				var t2_goods_take:ByteArray = new ByteArray;
				var tVo_goods_take:p_goods = this.goods_take[i] as p_goods;
				tVo_goods_take.writeToDataOutput(t2_goods_take);
				var len_tVo_goods_take:int = t2_goods_take.length;
				temp_repeated_byte_goods_take.writeInt(len_tVo_goods_take);
				temp_repeated_byte_goods_take.writeBytes(t2_goods_take);
			}
			output.writeInt(temp_repeated_byte_goods_take.length);
			output.writeBytes(temp_repeated_byte_goods_take);
			output.writeInt(this.state);
			if (this.letter_content != null) {				output.writeUTF(this.letter_content.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.table);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.sender = input.readUTF();
			this.receiver = input.readUTF();
			this.title = input.readUTF();
			this.send_time = input.readInt();
			this.type = input.readInt();
			var size_goods_list:int = input.readShort();
			var length_goods_list:int = input.readInt();
			if (length_goods_list > 0) {
				var byte_goods_list:ByteArray = new ByteArray; 
				input.readBytes(byte_goods_list, 0, length_goods_list);
				for(i=0; i<size_goods_list; i++) {
					var tmp_goods_list:p_goods = new p_goods;
					var tmp_goods_list_length:int = byte_goods_list.readInt();
					var tmp_goods_list_byte:ByteArray = new ByteArray;
					byte_goods_list.readBytes(tmp_goods_list_byte, 0, tmp_goods_list_length);
					tmp_goods_list.readFromDataOutput(tmp_goods_list_byte);
					this.goods_list.push(tmp_goods_list);
				}
			}
			var size_goods_take:int = input.readShort();
			var length_goods_take:int = input.readInt();
			if (length_goods_take > 0) {
				var byte_goods_take:ByteArray = new ByteArray; 
				input.readBytes(byte_goods_take, 0, length_goods_take);
				for(i=0; i<size_goods_take; i++) {
					var tmp_goods_take:p_goods = new p_goods;
					var tmp_goods_take_length:int = byte_goods_take.readInt();
					var tmp_goods_take_byte:ByteArray = new ByteArray;
					byte_goods_take.readBytes(tmp_goods_take_byte, 0, tmp_goods_take_length);
					tmp_goods_take.readFromDataOutput(tmp_goods_take_byte);
					this.goods_take.push(tmp_goods_take);
				}
			}
			this.state = input.readInt();
			this.letter_content = input.readUTF();
			this.table = input.readInt();
		}
	}
}
