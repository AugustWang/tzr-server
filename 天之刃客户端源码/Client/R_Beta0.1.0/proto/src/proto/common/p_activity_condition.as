package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_activity_condition extends Message
	{
		public var condition_id:int = 0;
		public var condition:String = "";
		public var multi:int = 0;
		public var simple_goods:Array = new Array;
		public var able:int = 0;
		public function p_activity_condition() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_activity_condition", p_activity_condition);
		}
		public override function getMethodName():String {
			return 'activity_condi';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.condition_id);
			if (this.condition != null) {				output.writeUTF(this.condition.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.multi);
			var size_simple_goods:int = this.simple_goods.length;
			output.writeShort(size_simple_goods);
			var temp_repeated_byte_simple_goods:ByteArray= new ByteArray;
			for(i=0; i<size_simple_goods; i++) {
				var t2_simple_goods:ByteArray = new ByteArray;
				var tVo_simple_goods:p_activity_prize_goods = this.simple_goods[i] as p_activity_prize_goods;
				tVo_simple_goods.writeToDataOutput(t2_simple_goods);
				var len_tVo_simple_goods:int = t2_simple_goods.length;
				temp_repeated_byte_simple_goods.writeInt(len_tVo_simple_goods);
				temp_repeated_byte_simple_goods.writeBytes(t2_simple_goods);
			}
			output.writeInt(temp_repeated_byte_simple_goods.length);
			output.writeBytes(temp_repeated_byte_simple_goods);
			output.writeInt(this.able);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.condition_id = input.readInt();
			this.condition = input.readUTF();
			this.multi = input.readInt();
			var size_simple_goods:int = input.readShort();
			var length_simple_goods:int = input.readInt();
			if (length_simple_goods > 0) {
				var byte_simple_goods:ByteArray = new ByteArray; 
				input.readBytes(byte_simple_goods, 0, length_simple_goods);
				for(i=0; i<size_simple_goods; i++) {
					var tmp_simple_goods:p_activity_prize_goods = new p_activity_prize_goods;
					var tmp_simple_goods_length:int = byte_simple_goods.readInt();
					var tmp_simple_goods_byte:ByteArray = new ByteArray;
					byte_simple_goods.readBytes(tmp_simple_goods_byte, 0, tmp_simple_goods_length);
					tmp_simple_goods.readFromDataOutput(tmp_simple_goods_byte);
					this.simple_goods.push(tmp_simple_goods);
				}
			}
			this.able = input.readInt();
		}
	}
}
