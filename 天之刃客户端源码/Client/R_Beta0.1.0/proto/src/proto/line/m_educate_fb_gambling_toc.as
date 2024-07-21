package proto.line {
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_fb_gambling_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var lucky_count:int = 0;
		public var fee:int = 0;
		public var award_goods:Array = new Array;
		public function m_educate_fb_gambling_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_educate_fb_gambling_toc", m_educate_fb_gambling_toc);
		}
		public override function getMethodName():String {
			return 'educate_fb_gambling';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.lucky_count);
			output.writeInt(this.fee);
			var size_award_goods:int = this.award_goods.length;
			output.writeShort(size_award_goods);
			var temp_repeated_byte_award_goods:ByteArray= new ByteArray;
			for(i=0; i<size_award_goods; i++) {
				var t2_award_goods:ByteArray = new ByteArray;
				var tVo_award_goods:p_goods = this.award_goods[i] as p_goods;
				tVo_award_goods.writeToDataOutput(t2_award_goods);
				var len_tVo_award_goods:int = t2_award_goods.length;
				temp_repeated_byte_award_goods.writeInt(len_tVo_award_goods);
				temp_repeated_byte_award_goods.writeBytes(t2_award_goods);
			}
			output.writeInt(temp_repeated_byte_award_goods.length);
			output.writeBytes(temp_repeated_byte_award_goods);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.lucky_count = input.readInt();
			this.fee = input.readInt();
			var size_award_goods:int = input.readShort();
			var length_award_goods:int = input.readInt();
			if (length_award_goods > 0) {
				var byte_award_goods:ByteArray = new ByteArray; 
				input.readBytes(byte_award_goods, 0, length_award_goods);
				for(i=0; i<size_award_goods; i++) {
					var tmp_award_goods:p_goods = new p_goods;
					var tmp_award_goods_length:int = byte_award_goods.readInt();
					var tmp_award_goods_byte:ByteArray = new ByteArray;
					byte_award_goods.readBytes(tmp_award_goods_byte, 0, tmp_award_goods_length);
					tmp_award_goods.readFromDataOutput(tmp_award_goods_byte);
					this.award_goods.push(tmp_award_goods);
				}
			}
		}
	}
}
