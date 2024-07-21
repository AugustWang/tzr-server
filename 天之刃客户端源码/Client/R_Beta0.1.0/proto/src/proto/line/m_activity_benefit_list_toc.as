package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_activity_benefit_list_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var is_rewarded:Boolean = true;
		public var act_task_list:Array = new Array;
		public var base_exp:int = 0;
		public var extra_exp:int = 0;
		public function m_activity_benefit_list_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_activity_benefit_list_toc", m_activity_benefit_list_toc);
		}
		public override function getMethodName():String {
			return 'activity_benefit_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.is_rewarded);
			var size_act_task_list:int = this.act_task_list.length;
			output.writeShort(size_act_task_list);
			var temp_repeated_byte_act_task_list:ByteArray= new ByteArray;
			for(i=0; i<size_act_task_list; i++) {
				temp_repeated_byte_act_task_list.writeInt(this.act_task_list[i]);
			}
			output.writeInt(temp_repeated_byte_act_task_list.length);
			output.writeBytes(temp_repeated_byte_act_task_list);
			output.writeInt(this.base_exp);
			output.writeInt(this.extra_exp);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.is_rewarded = input.readBoolean();
			var size_act_task_list:int = input.readShort();
			var length_act_task_list:int = input.readInt();
			var byte_act_task_list:ByteArray = new ByteArray; 
			if (size_act_task_list > 0) {
				input.readBytes(byte_act_task_list, 0, size_act_task_list * 4);
				for(i=0; i<size_act_task_list; i++) {
					var tmp_act_task_list:int = byte_act_task_list.readInt();
					this.act_task_list.push(tmp_act_task_list);
				}
			}
			this.base_exp = input.readInt();
			this.extra_exp = input.readInt();
		}
	}
}
