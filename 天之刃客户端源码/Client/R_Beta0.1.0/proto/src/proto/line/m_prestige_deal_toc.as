package proto.line {
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_prestige_deal_toc extends Message
	{
		public var group_id:int = 0;
		public var class_id:int = 0;
		public var key:int = 0;
		public var number:int = 1;
		public var succ:Boolean = true;
		public var reason:String = "";
		public var reason_code:int = 0;
		public var consume_prestige:int = 0;
		public var award_list:Array = new Array;
		public var sum_prestige:Number = 0;
		public var cur_prestige:Number = 0;
		public function m_prestige_deal_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_prestige_deal_toc", m_prestige_deal_toc);
		}
		public override function getMethodName():String {
			return 'prestige_deal';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.group_id);
			output.writeInt(this.class_id);
			output.writeInt(this.key);
			output.writeInt(this.number);
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.reason_code);
			output.writeInt(this.consume_prestige);
			var size_award_list:int = this.award_list.length;
			output.writeShort(size_award_list);
			var temp_repeated_byte_award_list:ByteArray= new ByteArray;
			for(i=0; i<size_award_list; i++) {
				var t2_award_list:ByteArray = new ByteArray;
				var tVo_award_list:p_goods = this.award_list[i] as p_goods;
				tVo_award_list.writeToDataOutput(t2_award_list);
				var len_tVo_award_list:int = t2_award_list.length;
				temp_repeated_byte_award_list.writeInt(len_tVo_award_list);
				temp_repeated_byte_award_list.writeBytes(t2_award_list);
			}
			output.writeInt(temp_repeated_byte_award_list.length);
			output.writeBytes(temp_repeated_byte_award_list);
			output.writeDouble(this.sum_prestige);
			output.writeDouble(this.cur_prestige);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.group_id = input.readInt();
			this.class_id = input.readInt();
			this.key = input.readInt();
			this.number = input.readInt();
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.reason_code = input.readInt();
			this.consume_prestige = input.readInt();
			var size_award_list:int = input.readShort();
			var length_award_list:int = input.readInt();
			if (length_award_list > 0) {
				var byte_award_list:ByteArray = new ByteArray; 
				input.readBytes(byte_award_list, 0, length_award_list);
				for(i=0; i<size_award_list; i++) {
					var tmp_award_list:p_goods = new p_goods;
					var tmp_award_list_length:int = byte_award_list.readInt();
					var tmp_award_list_byte:ByteArray = new ByteArray;
					byte_award_list.readBytes(tmp_award_list_byte, 0, tmp_award_list_length);
					tmp_award_list.readFromDataOutput(tmp_award_list_byte);
					this.award_list.push(tmp_award_list);
				}
			}
			this.sum_prestige = input.readDouble();
			this.cur_prestige = input.readDouble();
		}
	}
}
