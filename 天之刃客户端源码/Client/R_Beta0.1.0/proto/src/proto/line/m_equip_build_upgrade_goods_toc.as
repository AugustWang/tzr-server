package proto.line {
	import proto.line.p_equip_build_goods;
	import proto.line.p_equip_build_goods;
	import proto.line.p_equip_build_goods;
	import proto.line.p_equip_build_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_build_upgrade_goods_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var material:int = 0;
		public var base_list:Array = new Array;
		public var add_list:Array = new Array;
		public var quality_list:Array = new Array;
		public var reinforce:Array = new Array;
		public function m_equip_build_upgrade_goods_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_equip_build_upgrade_goods_toc", m_equip_build_upgrade_goods_toc);
		}
		public override function getMethodName():String {
			return 'equip_build_upgrade_goods';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.material);
			var size_base_list:int = this.base_list.length;
			output.writeShort(size_base_list);
			var temp_repeated_byte_base_list:ByteArray= new ByteArray;
			for(i=0; i<size_base_list; i++) {
				var t2_base_list:ByteArray = new ByteArray;
				var tVo_base_list:p_equip_build_goods = this.base_list[i] as p_equip_build_goods;
				tVo_base_list.writeToDataOutput(t2_base_list);
				var len_tVo_base_list:int = t2_base_list.length;
				temp_repeated_byte_base_list.writeInt(len_tVo_base_list);
				temp_repeated_byte_base_list.writeBytes(t2_base_list);
			}
			output.writeInt(temp_repeated_byte_base_list.length);
			output.writeBytes(temp_repeated_byte_base_list);
			var size_add_list:int = this.add_list.length;
			output.writeShort(size_add_list);
			var temp_repeated_byte_add_list:ByteArray= new ByteArray;
			for(i=0; i<size_add_list; i++) {
				var t2_add_list:ByteArray = new ByteArray;
				var tVo_add_list:p_equip_build_goods = this.add_list[i] as p_equip_build_goods;
				tVo_add_list.writeToDataOutput(t2_add_list);
				var len_tVo_add_list:int = t2_add_list.length;
				temp_repeated_byte_add_list.writeInt(len_tVo_add_list);
				temp_repeated_byte_add_list.writeBytes(t2_add_list);
			}
			output.writeInt(temp_repeated_byte_add_list.length);
			output.writeBytes(temp_repeated_byte_add_list);
			var size_quality_list:int = this.quality_list.length;
			output.writeShort(size_quality_list);
			var temp_repeated_byte_quality_list:ByteArray= new ByteArray;
			for(i=0; i<size_quality_list; i++) {
				var t2_quality_list:ByteArray = new ByteArray;
				var tVo_quality_list:p_equip_build_goods = this.quality_list[i] as p_equip_build_goods;
				tVo_quality_list.writeToDataOutput(t2_quality_list);
				var len_tVo_quality_list:int = t2_quality_list.length;
				temp_repeated_byte_quality_list.writeInt(len_tVo_quality_list);
				temp_repeated_byte_quality_list.writeBytes(t2_quality_list);
			}
			output.writeInt(temp_repeated_byte_quality_list.length);
			output.writeBytes(temp_repeated_byte_quality_list);
			var size_reinforce:int = this.reinforce.length;
			output.writeShort(size_reinforce);
			var temp_repeated_byte_reinforce:ByteArray= new ByteArray;
			for(i=0; i<size_reinforce; i++) {
				var t2_reinforce:ByteArray = new ByteArray;
				var tVo_reinforce:p_equip_build_goods = this.reinforce[i] as p_equip_build_goods;
				tVo_reinforce.writeToDataOutput(t2_reinforce);
				var len_tVo_reinforce:int = t2_reinforce.length;
				temp_repeated_byte_reinforce.writeInt(len_tVo_reinforce);
				temp_repeated_byte_reinforce.writeBytes(t2_reinforce);
			}
			output.writeInt(temp_repeated_byte_reinforce.length);
			output.writeBytes(temp_repeated_byte_reinforce);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.material = input.readInt();
			var size_base_list:int = input.readShort();
			var length_base_list:int = input.readInt();
			if (length_base_list > 0) {
				var byte_base_list:ByteArray = new ByteArray; 
				input.readBytes(byte_base_list, 0, length_base_list);
				for(i=0; i<size_base_list; i++) {
					var tmp_base_list:p_equip_build_goods = new p_equip_build_goods;
					var tmp_base_list_length:int = byte_base_list.readInt();
					var tmp_base_list_byte:ByteArray = new ByteArray;
					byte_base_list.readBytes(tmp_base_list_byte, 0, tmp_base_list_length);
					tmp_base_list.readFromDataOutput(tmp_base_list_byte);
					this.base_list.push(tmp_base_list);
				}
			}
			var size_add_list:int = input.readShort();
			var length_add_list:int = input.readInt();
			if (length_add_list > 0) {
				var byte_add_list:ByteArray = new ByteArray; 
				input.readBytes(byte_add_list, 0, length_add_list);
				for(i=0; i<size_add_list; i++) {
					var tmp_add_list:p_equip_build_goods = new p_equip_build_goods;
					var tmp_add_list_length:int = byte_add_list.readInt();
					var tmp_add_list_byte:ByteArray = new ByteArray;
					byte_add_list.readBytes(tmp_add_list_byte, 0, tmp_add_list_length);
					tmp_add_list.readFromDataOutput(tmp_add_list_byte);
					this.add_list.push(tmp_add_list);
				}
			}
			var size_quality_list:int = input.readShort();
			var length_quality_list:int = input.readInt();
			if (length_quality_list > 0) {
				var byte_quality_list:ByteArray = new ByteArray; 
				input.readBytes(byte_quality_list, 0, length_quality_list);
				for(i=0; i<size_quality_list; i++) {
					var tmp_quality_list:p_equip_build_goods = new p_equip_build_goods;
					var tmp_quality_list_length:int = byte_quality_list.readInt();
					var tmp_quality_list_byte:ByteArray = new ByteArray;
					byte_quality_list.readBytes(tmp_quality_list_byte, 0, tmp_quality_list_length);
					tmp_quality_list.readFromDataOutput(tmp_quality_list_byte);
					this.quality_list.push(tmp_quality_list);
				}
			}
			var size_reinforce:int = input.readShort();
			var length_reinforce:int = input.readInt();
			if (length_reinforce > 0) {
				var byte_reinforce:ByteArray = new ByteArray; 
				input.readBytes(byte_reinforce, 0, length_reinforce);
				for(i=0; i<size_reinforce; i++) {
					var tmp_reinforce:p_equip_build_goods = new p_equip_build_goods;
					var tmp_reinforce_length:int = byte_reinforce.readInt();
					var tmp_reinforce_byte:ByteArray = new ByteArray;
					byte_reinforce.readBytes(tmp_reinforce_byte, 0, tmp_reinforce_length);
					tmp_reinforce.readFromDataOutput(tmp_reinforce_byte);
					this.reinforce.push(tmp_reinforce);
				}
			}
		}
	}
}
