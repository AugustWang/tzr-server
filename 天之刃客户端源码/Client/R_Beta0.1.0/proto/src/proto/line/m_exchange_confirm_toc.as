package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_exchange_confirm_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public var goods_info:Array = new Array;
		public function m_exchange_confirm_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_exchange_confirm_toc", m_exchange_confirm_toc);
		}
		public override function getMethodName():String {
			return 'exchange_confirm';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
			var size_goods_info:int = this.goods_info.length;
			output.writeShort(size_goods_info);
			var temp_repeated_byte_goods_info:ByteArray= new ByteArray;
			for(i=0; i<size_goods_info; i++) {
				var t2_goods_info:ByteArray = new ByteArray;
				var tVo_goods_info:p_simple_goods = this.goods_info[i] as p_simple_goods;
				tVo_goods_info.writeToDataOutput(t2_goods_info);
				var len_tVo_goods_info:int = t2_goods_info.length;
				temp_repeated_byte_goods_info.writeInt(len_tVo_goods_info);
				temp_repeated_byte_goods_info.writeBytes(t2_goods_info);
			}
			output.writeInt(temp_repeated_byte_goods_info.length);
			output.writeBytes(temp_repeated_byte_goods_info);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
			var size_goods_info:int = input.readShort();
			var length_goods_info:int = input.readInt();
			if (length_goods_info > 0) {
				var byte_goods_info:ByteArray = new ByteArray; 
				input.readBytes(byte_goods_info, 0, length_goods_info);
				for(i=0; i<size_goods_info; i++) {
					var tmp_goods_info:p_simple_goods = new p_simple_goods;
					var tmp_goods_info_length:int = byte_goods_info.readInt();
					var tmp_goods_info_byte:ByteArray = new ByteArray;
					byte_goods_info.readBytes(tmp_goods_info_byte, 0, tmp_goods_info_length);
					tmp_goods_info.readFromDataOutput(tmp_goods_info_byte);
					this.goods_info.push(tmp_goods_info);
				}
			}
		}
	}
}
