package proto.line {
	import proto.common.p_activity_condition;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_special_activity_detail_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var activity_key:int = 0;
		public var title:String = "";
		public var text:String = "";
		public var activity_start_time:int = 0;
		public var activity_end_time:int = 0;
		public var reward_start_time:int = 0;
		public var reward_end_time:int = 0;
		public var condition_list:Array = new Array;
		public var limit:int = 0;
		public function m_special_activity_detail_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_special_activity_detail_toc", m_special_activity_detail_toc);
		}
		public override function getMethodName():String {
			return 'special_activity_detail';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.activity_key);
			if (this.title != null) {				output.writeUTF(this.title.toString());
			} else {
				output.writeUTF("");
			}
			if (this.text != null) {				output.writeUTF(this.text.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.activity_start_time);
			output.writeInt(this.activity_end_time);
			output.writeInt(this.reward_start_time);
			output.writeInt(this.reward_end_time);
			var size_condition_list:int = this.condition_list.length;
			output.writeShort(size_condition_list);
			var temp_repeated_byte_condition_list:ByteArray= new ByteArray;
			for(i=0; i<size_condition_list; i++) {
				var t2_condition_list:ByteArray = new ByteArray;
				var tVo_condition_list:p_activity_condition = this.condition_list[i] as p_activity_condition;
				tVo_condition_list.writeToDataOutput(t2_condition_list);
				var len_tVo_condition_list:int = t2_condition_list.length;
				temp_repeated_byte_condition_list.writeInt(len_tVo_condition_list);
				temp_repeated_byte_condition_list.writeBytes(t2_condition_list);
			}
			output.writeInt(temp_repeated_byte_condition_list.length);
			output.writeBytes(temp_repeated_byte_condition_list);
			output.writeInt(this.limit);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.activity_key = input.readInt();
			this.title = input.readUTF();
			this.text = input.readUTF();
			this.activity_start_time = input.readInt();
			this.activity_end_time = input.readInt();
			this.reward_start_time = input.readInt();
			this.reward_end_time = input.readInt();
			var size_condition_list:int = input.readShort();
			var length_condition_list:int = input.readInt();
			if (length_condition_list > 0) {
				var byte_condition_list:ByteArray = new ByteArray; 
				input.readBytes(byte_condition_list, 0, length_condition_list);
				for(i=0; i<size_condition_list; i++) {
					var tmp_condition_list:p_activity_condition = new p_activity_condition;
					var tmp_condition_list_length:int = byte_condition_list.readInt();
					var tmp_condition_list_byte:ByteArray = new ByteArray;
					byte_condition_list.readBytes(tmp_condition_list_byte, 0, tmp_condition_list_length);
					tmp_condition_list.readFromDataOutput(tmp_condition_list_byte);
					this.condition_list.push(tmp_condition_list);
				}
			}
			this.limit = input.readInt();
		}
	}
}
