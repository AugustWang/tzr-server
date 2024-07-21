package proto.line {
	import proto.common.p_boss_group;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_activity_boss_group_toc extends Message
	{
		public var op_type:int = 0;
		public var boss_group_list:Array = new Array;
		public var boss_id:int = 0;
		public var map_id:int = 0;
		public var tx:int = 0;
		public var ty:int = 0;
		public var succ:Boolean = true;
		public var reason:String = "";
		public function m_activity_boss_group_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_activity_boss_group_toc", m_activity_boss_group_toc);
		}
		public override function getMethodName():String {
			return 'activity_boss_group';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.op_type);
			var size_boss_group_list:int = this.boss_group_list.length;
			output.writeShort(size_boss_group_list);
			var temp_repeated_byte_boss_group_list:ByteArray= new ByteArray;
			for(i=0; i<size_boss_group_list; i++) {
				var t2_boss_group_list:ByteArray = new ByteArray;
				var tVo_boss_group_list:p_boss_group = this.boss_group_list[i] as p_boss_group;
				tVo_boss_group_list.writeToDataOutput(t2_boss_group_list);
				var len_tVo_boss_group_list:int = t2_boss_group_list.length;
				temp_repeated_byte_boss_group_list.writeInt(len_tVo_boss_group_list);
				temp_repeated_byte_boss_group_list.writeBytes(t2_boss_group_list);
			}
			output.writeInt(temp_repeated_byte_boss_group_list.length);
			output.writeBytes(temp_repeated_byte_boss_group_list);
			output.writeInt(this.boss_id);
			output.writeInt(this.map_id);
			output.writeInt(this.tx);
			output.writeInt(this.ty);
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.op_type = input.readInt();
			var size_boss_group_list:int = input.readShort();
			var length_boss_group_list:int = input.readInt();
			if (length_boss_group_list > 0) {
				var byte_boss_group_list:ByteArray = new ByteArray; 
				input.readBytes(byte_boss_group_list, 0, length_boss_group_list);
				for(i=0; i<size_boss_group_list; i++) {
					var tmp_boss_group_list:p_boss_group = new p_boss_group;
					var tmp_boss_group_list_length:int = byte_boss_group_list.readInt();
					var tmp_boss_group_list_byte:ByteArray = new ByteArray;
					byte_boss_group_list.readBytes(tmp_boss_group_list_byte, 0, tmp_boss_group_list_length);
					tmp_boss_group_list.readFromDataOutput(tmp_boss_group_list_byte);
					this.boss_group_list.push(tmp_boss_group_list);
				}
			}
			this.boss_id = input.readInt();
			this.map_id = input.readInt();
			this.tx = input.readInt();
			this.ty = input.readInt();
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
		}
	}
}
