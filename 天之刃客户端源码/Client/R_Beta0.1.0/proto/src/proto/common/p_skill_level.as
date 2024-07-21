package proto.common {
	import proto.common.p_skill_precondition;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_skill_level extends Message
	{
		public var skill_id:int = 0;
		public var level:int = 0;
		public var premise_point:int = 0;
		public var pre_condition:Array = new Array;
		public var cool_time:int = 0;
		public var category:int = 0;
		public var premise_role_level:int = 0;
		public var need_item:int = 0;
		public var need_silver:int = 0;
		public var consume_exp:int = 0;
		public var effects:Array = new Array;
		public var buffs:Array = new Array;
		public var consume_mp:int = 0;
		public var item_consume:Array = new Array;
		public function p_skill_level() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_skill_level", p_skill_level);
		}
		public override function getMethodName():String {
			return 'skill_l';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.skill_id);
			output.writeInt(this.level);
			output.writeInt(this.premise_point);
			var size_pre_condition:int = this.pre_condition.length;
			output.writeShort(size_pre_condition);
			var temp_repeated_byte_pre_condition:ByteArray= new ByteArray;
			for(i=0; i<size_pre_condition; i++) {
				var t2_pre_condition:ByteArray = new ByteArray;
				var tVo_pre_condition:p_skill_precondition = this.pre_condition[i] as p_skill_precondition;
				tVo_pre_condition.writeToDataOutput(t2_pre_condition);
				var len_tVo_pre_condition:int = t2_pre_condition.length;
				temp_repeated_byte_pre_condition.writeInt(len_tVo_pre_condition);
				temp_repeated_byte_pre_condition.writeBytes(t2_pre_condition);
			}
			output.writeInt(temp_repeated_byte_pre_condition.length);
			output.writeBytes(temp_repeated_byte_pre_condition);
			output.writeInt(this.cool_time);
			output.writeInt(this.category);
			output.writeInt(this.premise_role_level);
			output.writeInt(this.need_item);
			output.writeInt(this.need_silver);
			output.writeInt(this.consume_exp);
			var size_effects:int = this.effects.length;
			output.writeShort(size_effects);
			var temp_repeated_byte_effects:ByteArray= new ByteArray;
			for(i=0; i<size_effects; i++) {
				temp_repeated_byte_effects.writeInt(this.effects[i]);
			}
			output.writeInt(temp_repeated_byte_effects.length);
			output.writeBytes(temp_repeated_byte_effects);
			var size_buffs:int = this.buffs.length;
			output.writeShort(size_buffs);
			var temp_repeated_byte_buffs:ByteArray= new ByteArray;
			for(i=0; i<size_buffs; i++) {
				temp_repeated_byte_buffs.writeInt(this.buffs[i]);
			}
			output.writeInt(temp_repeated_byte_buffs.length);
			output.writeBytes(temp_repeated_byte_buffs);
			output.writeInt(this.consume_mp);
			var size_item_consume:int = this.item_consume.length;
			output.writeShort(size_item_consume);
			var temp_repeated_byte_item_consume:ByteArray= new ByteArray;
			for(i=0; i<size_item_consume; i++) {
				var t2_item_consume:ByteArray = new ByteArray;
				var tVo_item_consume:p_skill_item_consume = this.item_consume[i] as p_skill_item_consume;
				tVo_item_consume.writeToDataOutput(t2_item_consume);
				var len_tVo_item_consume:int = t2_item_consume.length;
				temp_repeated_byte_item_consume.writeInt(len_tVo_item_consume);
				temp_repeated_byte_item_consume.writeBytes(t2_item_consume);
			}
			output.writeInt(temp_repeated_byte_item_consume.length);
			output.writeBytes(temp_repeated_byte_item_consume);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.skill_id = input.readInt();
			this.level = input.readInt();
			this.premise_point = input.readInt();
			var size_pre_condition:int = input.readShort();
			var length_pre_condition:int = input.readInt();
			if (length_pre_condition > 0) {
				var byte_pre_condition:ByteArray = new ByteArray; 
				input.readBytes(byte_pre_condition, 0, length_pre_condition);
				for(i=0; i<size_pre_condition; i++) {
					var tmp_pre_condition:p_skill_precondition = new p_skill_precondition;
					var tmp_pre_condition_length:int = byte_pre_condition.readInt();
					var tmp_pre_condition_byte:ByteArray = new ByteArray;
					byte_pre_condition.readBytes(tmp_pre_condition_byte, 0, tmp_pre_condition_length);
					tmp_pre_condition.readFromDataOutput(tmp_pre_condition_byte);
					this.pre_condition.push(tmp_pre_condition);
				}
			}
			this.cool_time = input.readInt();
			this.category = input.readInt();
			this.premise_role_level = input.readInt();
			this.need_item = input.readInt();
			this.need_silver = input.readInt();
			this.consume_exp = input.readInt();
			var size_effects:int = input.readShort();
			var length_effects:int = input.readInt();
			var byte_effects:ByteArray = new ByteArray; 
			if (size_effects > 0) {
				input.readBytes(byte_effects, 0, size_effects * 4);
				for(i=0; i<size_effects; i++) {
					var tmp_effects:int = byte_effects.readInt();
					this.effects.push(tmp_effects);
				}
			}
			var size_buffs:int = input.readShort();
			var length_buffs:int = input.readInt();
			var byte_buffs:ByteArray = new ByteArray; 
			if (size_buffs > 0) {
				input.readBytes(byte_buffs, 0, size_buffs * 4);
				for(i=0; i<size_buffs; i++) {
					var tmp_buffs:int = byte_buffs.readInt();
					this.buffs.push(tmp_buffs);
				}
			}
			this.consume_mp = input.readInt();
			var size_item_consume:int = input.readShort();
			var length_item_consume:int = input.readInt();
			if (length_item_consume > 0) {
				var byte_item_consume:ByteArray = new ByteArray; 
				input.readBytes(byte_item_consume, 0, length_item_consume);
				for(i=0; i<size_item_consume; i++) {
					var tmp_item_consume:p_skill_item_consume = new p_skill_item_consume;
					var tmp_item_consume_length:int = byte_item_consume.readInt();
					var tmp_item_consume_byte:ByteArray = new ByteArray;
					byte_item_consume.readBytes(tmp_item_consume_byte, 0, tmp_item_consume_length);
					tmp_item_consume.readFromDataOutput(tmp_item_consume_byte);
					this.item_consume.push(tmp_item_consume);
				}
			}
		}
	}
}
