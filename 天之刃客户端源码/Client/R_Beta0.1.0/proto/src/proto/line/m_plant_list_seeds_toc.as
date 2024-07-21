package proto.line {
	import proto.common.p_seed_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_plant_list_seeds_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var seeds:Array = new Array;
		public function m_plant_list_seeds_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_plant_list_seeds_toc", m_plant_list_seeds_toc);
		}
		public override function getMethodName():String {
			return 'plant_list_seeds';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var size_seeds:int = this.seeds.length;
			output.writeShort(size_seeds);
			var temp_repeated_byte_seeds:ByteArray= new ByteArray;
			for(i=0; i<size_seeds; i++) {
				var t2_seeds:ByteArray = new ByteArray;
				var tVo_seeds:p_seed_info = this.seeds[i] as p_seed_info;
				tVo_seeds.writeToDataOutput(t2_seeds);
				var len_tVo_seeds:int = t2_seeds.length;
				temp_repeated_byte_seeds.writeInt(len_tVo_seeds);
				temp_repeated_byte_seeds.writeBytes(t2_seeds);
			}
			output.writeInt(temp_repeated_byte_seeds.length);
			output.writeBytes(temp_repeated_byte_seeds);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var size_seeds:int = input.readShort();
			var length_seeds:int = input.readInt();
			if (length_seeds > 0) {
				var byte_seeds:ByteArray = new ByteArray; 
				input.readBytes(byte_seeds, 0, length_seeds);
				for(i=0; i<size_seeds; i++) {
					var tmp_seeds:p_seed_info = new p_seed_info;
					var tmp_seeds_length:int = byte_seeds.readInt();
					var tmp_seeds_byte:ByteArray = new ByteArray;
					byte_seeds.readBytes(tmp_seeds_byte, 0, tmp_seeds_length);
					tmp_seeds.readFromDataOutput(tmp_seeds_byte);
					this.seeds.push(tmp_seeds);
				}
			}
		}
	}
}
