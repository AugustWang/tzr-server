package proto.line {
	import proto.common.p_map_farm;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_plant_family_farm_toc extends Message
	{
		public var farm_size:int = 0;
		public var farm_list:Array = new Array;
		public function m_plant_family_farm_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_plant_family_farm_toc", m_plant_family_farm_toc);
		}
		public override function getMethodName():String {
			return 'plant_family_farm';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.farm_size);
			var size_farm_list:int = this.farm_list.length;
			output.writeShort(size_farm_list);
			var temp_repeated_byte_farm_list:ByteArray= new ByteArray;
			for(i=0; i<size_farm_list; i++) {
				var t2_farm_list:ByteArray = new ByteArray;
				var tVo_farm_list:p_map_farm = this.farm_list[i] as p_map_farm;
				tVo_farm_list.writeToDataOutput(t2_farm_list);
				var len_tVo_farm_list:int = t2_farm_list.length;
				temp_repeated_byte_farm_list.writeInt(len_tVo_farm_list);
				temp_repeated_byte_farm_list.writeBytes(t2_farm_list);
			}
			output.writeInt(temp_repeated_byte_farm_list.length);
			output.writeBytes(temp_repeated_byte_farm_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.farm_size = input.readInt();
			var size_farm_list:int = input.readShort();
			var length_farm_list:int = input.readInt();
			if (length_farm_list > 0) {
				var byte_farm_list:ByteArray = new ByteArray; 
				input.readBytes(byte_farm_list, 0, length_farm_list);
				for(i=0; i<size_farm_list; i++) {
					var tmp_farm_list:p_map_farm = new p_map_farm;
					var tmp_farm_list_length:int = byte_farm_list.readInt();
					var tmp_farm_list_byte:ByteArray = new ByteArray;
					byte_farm_list.readBytes(tmp_farm_list_byte, 0, tmp_farm_list_length);
					tmp_farm_list.readFromDataOutput(tmp_farm_list_byte);
					this.farm_list.push(tmp_farm_list);
				}
			}
		}
	}
}
