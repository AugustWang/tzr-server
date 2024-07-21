package proto.line {
	import proto.common.p_refining;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_refining_firing_tos extends Message
	{
		public var op_type:int = 0;
		public var sub_op_type:int = 0;
		public var firing_list:Array = new Array;
		public function m_refining_firing_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_refining_firing_tos", m_refining_firing_tos);
		}
		public override function getMethodName():String {
			return 'refining_firing';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.op_type);
			output.writeInt(this.sub_op_type);
			var size_firing_list:int = this.firing_list.length;
			output.writeShort(size_firing_list);
			var temp_repeated_byte_firing_list:ByteArray= new ByteArray;
			for(i=0; i<size_firing_list; i++) {
				var t2_firing_list:ByteArray = new ByteArray;
				var tVo_firing_list:p_refining = this.firing_list[i] as p_refining;
				tVo_firing_list.writeToDataOutput(t2_firing_list);
				var len_tVo_firing_list:int = t2_firing_list.length;
				temp_repeated_byte_firing_list.writeInt(len_tVo_firing_list);
				temp_repeated_byte_firing_list.writeBytes(t2_firing_list);
			}
			output.writeInt(temp_repeated_byte_firing_list.length);
			output.writeBytes(temp_repeated_byte_firing_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.op_type = input.readInt();
			this.sub_op_type = input.readInt();
			var size_firing_list:int = input.readShort();
			var length_firing_list:int = input.readInt();
			if (length_firing_list > 0) {
				var byte_firing_list:ByteArray = new ByteArray; 
				input.readBytes(byte_firing_list, 0, length_firing_list);
				for(i=0; i<size_firing_list; i++) {
					var tmp_firing_list:p_refining = new p_refining;
					var tmp_firing_list_length:int = byte_firing_list.readInt();
					var tmp_firing_list_byte:ByteArray = new ByteArray;
					byte_firing_list.readBytes(tmp_firing_list_byte, 0, tmp_firing_list_length);
					tmp_firing_list.readFromDataOutput(tmp_firing_list_byte);
					this.firing_list.push(tmp_firing_list);
				}
			}
		}
	}
}
