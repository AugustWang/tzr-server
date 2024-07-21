package proto.line {
	import proto.common.p_role_pet_rank;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_ranking_role_pet_rank_toc extends Message
	{
		public var pets:Array = new Array;
		public function m_ranking_role_pet_rank_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_ranking_role_pet_rank_toc", m_ranking_role_pet_rank_toc);
		}
		public override function getMethodName():String {
			return 'ranking_role_pet_rank';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_pets:int = this.pets.length;
			output.writeShort(size_pets);
			var temp_repeated_byte_pets:ByteArray= new ByteArray;
			for(i=0; i<size_pets; i++) {
				var t2_pets:ByteArray = new ByteArray;
				var tVo_pets:p_role_pet_rank = this.pets[i] as p_role_pet_rank;
				tVo_pets.writeToDataOutput(t2_pets);
				var len_tVo_pets:int = t2_pets.length;
				temp_repeated_byte_pets.writeInt(len_tVo_pets);
				temp_repeated_byte_pets.writeBytes(t2_pets);
			}
			output.writeInt(temp_repeated_byte_pets.length);
			output.writeBytes(temp_repeated_byte_pets);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_pets:int = input.readShort();
			var length_pets:int = input.readInt();
			if (length_pets > 0) {
				var byte_pets:ByteArray = new ByteArray; 
				input.readBytes(byte_pets, 0, length_pets);
				for(i=0; i<size_pets; i++) {
					var tmp_pets:p_role_pet_rank = new p_role_pet_rank;
					var tmp_pets_length:int = byte_pets.readInt();
					var tmp_pets_byte:ByteArray = new ByteArray;
					byte_pets.readBytes(tmp_pets_byte, 0, tmp_pets_length);
					tmp_pets.readFromDataOutput(tmp_pets_byte);
					this.pets.push(tmp_pets);
				}
			}
		}
	}
}
