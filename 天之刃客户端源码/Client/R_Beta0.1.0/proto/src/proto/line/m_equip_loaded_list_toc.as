package proto.line {
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_loaded_list_toc extends Message
	{
		public var roleid:int = 0;
		public var equips:Array = new Array;
		public function m_equip_loaded_list_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_equip_loaded_list_toc", m_equip_loaded_list_toc);
		}
		public override function getMethodName():String {
			return 'equip_loaded_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.roleid);
			var size_equips:int = this.equips.length;
			output.writeShort(size_equips);
			var temp_repeated_byte_equips:ByteArray= new ByteArray;
			for(i=0; i<size_equips; i++) {
				var t2_equips:ByteArray = new ByteArray;
				var tVo_equips:p_goods = this.equips[i] as p_goods;
				tVo_equips.writeToDataOutput(t2_equips);
				var len_tVo_equips:int = t2_equips.length;
				temp_repeated_byte_equips.writeInt(len_tVo_equips);
				temp_repeated_byte_equips.writeBytes(t2_equips);
			}
			output.writeInt(temp_repeated_byte_equips.length);
			output.writeBytes(temp_repeated_byte_equips);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.roleid = input.readInt();
			var size_equips:int = input.readShort();
			var length_equips:int = input.readInt();
			if (length_equips > 0) {
				var byte_equips:ByteArray = new ByteArray; 
				input.readBytes(byte_equips, 0, length_equips);
				for(i=0; i<size_equips; i++) {
					var tmp_equips:p_goods = new p_goods;
					var tmp_equips_length:int = byte_equips.readInt();
					var tmp_equips_byte:ByteArray = new ByteArray;
					byte_equips.readBytes(tmp_equips_byte, 0, tmp_equips_length);
					tmp_equips.readFromDataOutput(tmp_equips_byte);
					this.equips.push(tmp_equips);
				}
			}
		}
	}
}
