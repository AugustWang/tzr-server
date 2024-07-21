package proto.line {
	import proto.line.p_stall_list_item;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stall_list_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var type:int = 0;
		public var page:int = 0;
		public var typeid:Array = new Array;
		public var sort_type:int = 0;
		public var is_reverse:Boolean = true;
		public var is_gold_first:Boolean = true;
		public var min_level:int = 0;
		public var max_level:int = 0;
		public var color:int = 0;
		public var pro:int = 0;
		public var goods_list:Array = new Array;
		public var max_page:int = 0;
		public function m_stall_list_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_stall_list_toc", m_stall_list_toc);
		}
		public override function getMethodName():String {
			return 'stall_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.type);
			output.writeInt(this.page);
			var size_typeid:int = this.typeid.length;
			output.writeShort(size_typeid);
			var temp_repeated_byte_typeid:ByteArray= new ByteArray;
			for(i=0; i<size_typeid; i++) {
				temp_repeated_byte_typeid.writeInt(this.typeid[i]);
			}
			output.writeInt(temp_repeated_byte_typeid.length);
			output.writeBytes(temp_repeated_byte_typeid);
			output.writeInt(this.sort_type);
			output.writeBoolean(this.is_reverse);
			output.writeBoolean(this.is_gold_first);
			output.writeInt(this.min_level);
			output.writeInt(this.max_level);
			output.writeInt(this.color);
			output.writeInt(this.pro);
			var size_goods_list:int = this.goods_list.length;
			output.writeShort(size_goods_list);
			var temp_repeated_byte_goods_list:ByteArray= new ByteArray;
			for(i=0; i<size_goods_list; i++) {
				var t2_goods_list:ByteArray = new ByteArray;
				var tVo_goods_list:p_stall_list_item = this.goods_list[i] as p_stall_list_item;
				tVo_goods_list.writeToDataOutput(t2_goods_list);
				var len_tVo_goods_list:int = t2_goods_list.length;
				temp_repeated_byte_goods_list.writeInt(len_tVo_goods_list);
				temp_repeated_byte_goods_list.writeBytes(t2_goods_list);
			}
			output.writeInt(temp_repeated_byte_goods_list.length);
			output.writeBytes(temp_repeated_byte_goods_list);
			output.writeInt(this.max_page);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.type = input.readInt();
			this.page = input.readInt();
			var size_typeid:int = input.readShort();
			var length_typeid:int = input.readInt();
			var byte_typeid:ByteArray = new ByteArray; 
			if (size_typeid > 0) {
				input.readBytes(byte_typeid, 0, size_typeid * 4);
				for(i=0; i<size_typeid; i++) {
					var tmp_typeid:int = byte_typeid.readInt();
					this.typeid.push(tmp_typeid);
				}
			}
			this.sort_type = input.readInt();
			this.is_reverse = input.readBoolean();
			this.is_gold_first = input.readBoolean();
			this.min_level = input.readInt();
			this.max_level = input.readInt();
			this.color = input.readInt();
			this.pro = input.readInt();
			var size_goods_list:int = input.readShort();
			var length_goods_list:int = input.readInt();
			if (length_goods_list > 0) {
				var byte_goods_list:ByteArray = new ByteArray; 
				input.readBytes(byte_goods_list, 0, length_goods_list);
				for(i=0; i<size_goods_list; i++) {
					var tmp_goods_list:p_stall_list_item = new p_stall_list_item;
					var tmp_goods_list_length:int = byte_goods_list.readInt();
					var tmp_goods_list_byte:ByteArray = new ByteArray;
					byte_goods_list.readBytes(tmp_goods_list_byte, 0, tmp_goods_list_length);
					tmp_goods_list.readFromDataOutput(tmp_goods_list_byte);
					this.goods_list.push(tmp_goods_list);
				}
			}
			this.max_page = input.readInt();
		}
	}
}
