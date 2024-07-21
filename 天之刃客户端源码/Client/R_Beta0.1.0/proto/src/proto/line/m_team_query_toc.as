package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_team_query_toc extends Message
	{
		public var op_type:int = 0;
		public var succ:Boolean = true;
		public var reason:String = "";
		public var reason_code:int = 0;
		public var nearby_list:Array = new Array;
		public function m_team_query_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_team_query_toc", m_team_query_toc);
		}
		public override function getMethodName():String {
			return 'team_query';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.op_type);
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.reason_code);
			var size_nearby_list:int = this.nearby_list.length;
			output.writeShort(size_nearby_list);
			var temp_repeated_byte_nearby_list:ByteArray= new ByteArray;
			for(i=0; i<size_nearby_list; i++) {
				var t2_nearby_list:ByteArray = new ByteArray;
				var tVo_nearby_list:p_team_nearby = this.nearby_list[i] as p_team_nearby;
				tVo_nearby_list.writeToDataOutput(t2_nearby_list);
				var len_tVo_nearby_list:int = t2_nearby_list.length;
				temp_repeated_byte_nearby_list.writeInt(len_tVo_nearby_list);
				temp_repeated_byte_nearby_list.writeBytes(t2_nearby_list);
			}
			output.writeInt(temp_repeated_byte_nearby_list.length);
			output.writeBytes(temp_repeated_byte_nearby_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.op_type = input.readInt();
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.reason_code = input.readInt();
			var size_nearby_list:int = input.readShort();
			var length_nearby_list:int = input.readInt();
			if (length_nearby_list > 0) {
				var byte_nearby_list:ByteArray = new ByteArray; 
				input.readBytes(byte_nearby_list, 0, length_nearby_list);
				for(i=0; i<size_nearby_list; i++) {
					var tmp_nearby_list:p_team_nearby = new p_team_nearby;
					var tmp_nearby_list_length:int = byte_nearby_list.readInt();
					var tmp_nearby_list_byte:ByteArray = new ByteArray;
					byte_nearby_list.readBytes(tmp_nearby_list_byte, 0, tmp_nearby_list_length);
					tmp_nearby_list.readFromDataOutput(tmp_nearby_list_byte);
					this.nearby_list.push(tmp_nearby_list);
				}
			}
		}
	}
}
