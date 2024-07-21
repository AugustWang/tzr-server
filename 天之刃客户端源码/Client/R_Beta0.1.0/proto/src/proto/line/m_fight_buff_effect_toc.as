package proto.line {
	import proto.line.p_buff_effect;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_fight_buff_effect_toc extends Message
	{
		public var actor_id:int = 0;
		public var actor_type:int = 0;
		public var buff_effect:Array = new Array;
		public var src_id:int = 0;
		public var src_type:int = 0;
		public function m_fight_buff_effect_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_fight_buff_effect_toc", m_fight_buff_effect_toc);
		}
		public override function getMethodName():String {
			return 'fight_buff_effect';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.actor_id);
			output.writeInt(this.actor_type);
			var size_buff_effect:int = this.buff_effect.length;
			output.writeShort(size_buff_effect);
			var temp_repeated_byte_buff_effect:ByteArray= new ByteArray;
			for(i=0; i<size_buff_effect; i++) {
				var t2_buff_effect:ByteArray = new ByteArray;
				var tVo_buff_effect:p_buff_effect = this.buff_effect[i] as p_buff_effect;
				tVo_buff_effect.writeToDataOutput(t2_buff_effect);
				var len_tVo_buff_effect:int = t2_buff_effect.length;
				temp_repeated_byte_buff_effect.writeInt(len_tVo_buff_effect);
				temp_repeated_byte_buff_effect.writeBytes(t2_buff_effect);
			}
			output.writeInt(temp_repeated_byte_buff_effect.length);
			output.writeBytes(temp_repeated_byte_buff_effect);
			output.writeInt(this.src_id);
			output.writeInt(this.src_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.actor_id = input.readInt();
			this.actor_type = input.readInt();
			var size_buff_effect:int = input.readShort();
			var length_buff_effect:int = input.readInt();
			if (length_buff_effect > 0) {
				var byte_buff_effect:ByteArray = new ByteArray; 
				input.readBytes(byte_buff_effect, 0, length_buff_effect);
				for(i=0; i<size_buff_effect; i++) {
					var tmp_buff_effect:p_buff_effect = new p_buff_effect;
					var tmp_buff_effect_length:int = byte_buff_effect.readInt();
					var tmp_buff_effect_byte:ByteArray = new ByteArray;
					byte_buff_effect.readBytes(tmp_buff_effect_byte, 0, tmp_buff_effect_length);
					tmp_buff_effect.readFromDataOutput(tmp_buff_effect_byte);
					this.buff_effect.push(tmp_buff_effect);
				}
			}
			this.src_id = input.readInt();
			this.src_type = input.readInt();
		}
	}
}
