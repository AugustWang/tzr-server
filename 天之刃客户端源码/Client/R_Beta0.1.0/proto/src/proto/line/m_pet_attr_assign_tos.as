package proto.line {
	import proto.common.p_pet_attr_assign;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_pet_attr_assign_tos extends Message
	{
		public var pet_id:int = 0;
		public var assign_info:Array = new Array;
		public function m_pet_attr_assign_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_pet_attr_assign_tos", m_pet_attr_assign_tos);
		}
		public override function getMethodName():String {
			return 'pet_attr_assign';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.pet_id);
			var size_assign_info:int = this.assign_info.length;
			output.writeShort(size_assign_info);
			var temp_repeated_byte_assign_info:ByteArray= new ByteArray;
			for(i=0; i<size_assign_info; i++) {
				var t2_assign_info:ByteArray = new ByteArray;
				var tVo_assign_info:p_pet_attr_assign = this.assign_info[i] as p_pet_attr_assign;
				tVo_assign_info.writeToDataOutput(t2_assign_info);
				var len_tVo_assign_info:int = t2_assign_info.length;
				temp_repeated_byte_assign_info.writeInt(len_tVo_assign_info);
				temp_repeated_byte_assign_info.writeBytes(t2_assign_info);
			}
			output.writeInt(temp_repeated_byte_assign_info.length);
			output.writeBytes(temp_repeated_byte_assign_info);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.pet_id = input.readInt();
			var size_assign_info:int = input.readShort();
			var length_assign_info:int = input.readInt();
			if (length_assign_info > 0) {
				var byte_assign_info:ByteArray = new ByteArray; 
				input.readBytes(byte_assign_info, 0, length_assign_info);
				for(i=0; i<size_assign_info; i++) {
					var tmp_assign_info:p_pet_attr_assign = new p_pet_attr_assign;
					var tmp_assign_info_length:int = byte_assign_info.readInt();
					var tmp_assign_info_byte:ByteArray = new ByteArray;
					byte_assign_info.readBytes(tmp_assign_info_byte, 0, tmp_assign_info_length);
					tmp_assign_info.readFromDataOutput(tmp_assign_info_byte);
					this.assign_info.push(tmp_assign_info);
				}
			}
		}
	}
}
