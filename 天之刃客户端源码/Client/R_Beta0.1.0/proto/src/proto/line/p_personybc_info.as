package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_personybc_info extends Message
	{
		public var color:int = 0;
		public var start_time:int = 0;
		public var time_limit:int = 0;
		public var status:int = 0;
		public var do_times:int = 0;
		public var public_npc_id:int = 0;
		public var commit_npc_id:int = 0;
		public var desc:String = "";
		public var attr_award:Array = new Array;
		public var prop_award:Array = new Array;
		public var type:int = 0;
		public var faction_new_start_time:int = 0;
		public var faction_start_time:int = 0;
		public var faction_time_limit:int = 0;
		public var cost_type:int = 1;
		public var cost_silver:int = 0;
		public var cost_silver_bind:int = 0;
		public var need_notice_when_auto:Boolean = false;
		public var auto_pay_gold:int = 0;
		public var auto:Boolean = true;
		public function p_personybc_info() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_personybc_info", p_personybc_info);
		}
		public override function getMethodName():String {
			return 'personybc_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.color);
			output.writeInt(this.start_time);
			output.writeInt(this.time_limit);
			output.writeInt(this.status);
			output.writeInt(this.do_times);
			output.writeInt(this.public_npc_id);
			output.writeInt(this.commit_npc_id);
			if (this.desc != null) {				output.writeUTF(this.desc.toString());
			} else {
				output.writeUTF("");
			}
			var size_attr_award:int = this.attr_award.length;
			output.writeShort(size_attr_award);
			var temp_repeated_byte_attr_award:ByteArray= new ByteArray;
			for(i=0; i<size_attr_award; i++) {
				var t2_attr_award:ByteArray = new ByteArray;
				var tVo_attr_award:p_personybc_award_attr = this.attr_award[i] as p_personybc_award_attr;
				tVo_attr_award.writeToDataOutput(t2_attr_award);
				var len_tVo_attr_award:int = t2_attr_award.length;
				temp_repeated_byte_attr_award.writeInt(len_tVo_attr_award);
				temp_repeated_byte_attr_award.writeBytes(t2_attr_award);
			}
			output.writeInt(temp_repeated_byte_attr_award.length);
			output.writeBytes(temp_repeated_byte_attr_award);
			var size_prop_award:int = this.prop_award.length;
			output.writeShort(size_prop_award);
			var temp_repeated_byte_prop_award:ByteArray= new ByteArray;
			for(i=0; i<size_prop_award; i++) {
				var t2_prop_award:ByteArray = new ByteArray;
				var tVo_prop_award:p_personybc_award_prop = this.prop_award[i] as p_personybc_award_prop;
				tVo_prop_award.writeToDataOutput(t2_prop_award);
				var len_tVo_prop_award:int = t2_prop_award.length;
				temp_repeated_byte_prop_award.writeInt(len_tVo_prop_award);
				temp_repeated_byte_prop_award.writeBytes(t2_prop_award);
			}
			output.writeInt(temp_repeated_byte_prop_award.length);
			output.writeBytes(temp_repeated_byte_prop_award);
			output.writeInt(this.type);
			output.writeInt(this.faction_new_start_time);
			output.writeInt(this.faction_start_time);
			output.writeInt(this.faction_time_limit);
			output.writeInt(this.cost_type);
			output.writeInt(this.cost_silver);
			output.writeInt(this.cost_silver_bind);
			output.writeBoolean(this.need_notice_when_auto);
			output.writeInt(this.auto_pay_gold);
			output.writeBoolean(this.auto);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.color = input.readInt();
			this.start_time = input.readInt();
			this.time_limit = input.readInt();
			this.status = input.readInt();
			this.do_times = input.readInt();
			this.public_npc_id = input.readInt();
			this.commit_npc_id = input.readInt();
			this.desc = input.readUTF();
			var size_attr_award:int = input.readShort();
			var length_attr_award:int = input.readInt();
			if (length_attr_award > 0) {
				var byte_attr_award:ByteArray = new ByteArray; 
				input.readBytes(byte_attr_award, 0, length_attr_award);
				for(i=0; i<size_attr_award; i++) {
					var tmp_attr_award:p_personybc_award_attr = new p_personybc_award_attr;
					var tmp_attr_award_length:int = byte_attr_award.readInt();
					var tmp_attr_award_byte:ByteArray = new ByteArray;
					byte_attr_award.readBytes(tmp_attr_award_byte, 0, tmp_attr_award_length);
					tmp_attr_award.readFromDataOutput(tmp_attr_award_byte);
					this.attr_award.push(tmp_attr_award);
				}
			}
			var size_prop_award:int = input.readShort();
			var length_prop_award:int = input.readInt();
			if (length_prop_award > 0) {
				var byte_prop_award:ByteArray = new ByteArray; 
				input.readBytes(byte_prop_award, 0, length_prop_award);
				for(i=0; i<size_prop_award; i++) {
					var tmp_prop_award:p_personybc_award_prop = new p_personybc_award_prop;
					var tmp_prop_award_length:int = byte_prop_award.readInt();
					var tmp_prop_award_byte:ByteArray = new ByteArray;
					byte_prop_award.readBytes(tmp_prop_award_byte, 0, tmp_prop_award_length);
					tmp_prop_award.readFromDataOutput(tmp_prop_award_byte);
					this.prop_award.push(tmp_prop_award);
				}
			}
			this.type = input.readInt();
			this.faction_new_start_time = input.readInt();
			this.faction_start_time = input.readInt();
			this.faction_time_limit = input.readInt();
			this.cost_type = input.readInt();
			this.cost_silver = input.readInt();
			this.cost_silver_bind = input.readInt();
			this.need_notice_when_auto = input.readBoolean();
			this.auto_pay_gold = input.readInt();
			this.auto = input.readBoolean();
		}
	}
}
