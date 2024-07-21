package proto.common {
	import proto.common.p_pos;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_map_collect extends Message
	{
		public var id:int = 0;
		public var typeid:int = 0;
		public var name:String = "";
		public var degree:int = 0;
		public var demand:p_collect_demand = null;
		public var times:int = 0;
		public var goodslist:p_collect_goods = null;
		public var tool_typeid:int = 0;
		public var point_id:int = 0;
		public var pos:p_pos = null;
		public var roles:Array = new Array;
		public function p_map_collect() {
			super();
			this.demand = new p_collect_demand;
			this.goodslist = new p_collect_goods;
			this.pos = new p_pos;

			flash.net.registerClassAlias("copy.proto.common.p_map_collect", p_map_collect);
		}
		public override function getMethodName():String {
			return 'map_col';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.typeid);
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.degree);
			var tmp_demand:ByteArray = new ByteArray;
			this.demand.writeToDataOutput(tmp_demand);
			var size_tmp_demand:int = tmp_demand.length;
			output.writeInt(size_tmp_demand);
			output.writeBytes(tmp_demand);
			output.writeInt(this.times);
			var tmp_goodslist:ByteArray = new ByteArray;
			this.goodslist.writeToDataOutput(tmp_goodslist);
			var size_tmp_goodslist:int = tmp_goodslist.length;
			output.writeInt(size_tmp_goodslist);
			output.writeBytes(tmp_goodslist);
			output.writeInt(this.tool_typeid);
			output.writeInt(this.point_id);
			var tmp_pos:ByteArray = new ByteArray;
			this.pos.writeToDataOutput(tmp_pos);
			var size_tmp_pos:int = tmp_pos.length;
			output.writeInt(size_tmp_pos);
			output.writeBytes(tmp_pos);
			var size_roles:int = this.roles.length;
			output.writeShort(size_roles);
			var temp_repeated_byte_roles:ByteArray= new ByteArray;
			for(i=0; i<size_roles; i++) {
				var t2_roles:ByteArray = new ByteArray;
				var tVo_roles:p_collect_role = this.roles[i] as p_collect_role;
				tVo_roles.writeToDataOutput(t2_roles);
				var len_tVo_roles:int = t2_roles.length;
				temp_repeated_byte_roles.writeInt(len_tVo_roles);
				temp_repeated_byte_roles.writeBytes(t2_roles);
			}
			output.writeInt(temp_repeated_byte_roles.length);
			output.writeBytes(temp_repeated_byte_roles);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.typeid = input.readInt();
			this.name = input.readUTF();
			this.degree = input.readInt();
			var byte_demand_size:int = input.readInt();
			if (byte_demand_size > 0) {				this.demand = new p_collect_demand;
				var byte_demand:ByteArray = new ByteArray;
				input.readBytes(byte_demand, 0, byte_demand_size);
				this.demand.readFromDataOutput(byte_demand);
			}
			this.times = input.readInt();
			var byte_goodslist_size:int = input.readInt();
			if (byte_goodslist_size > 0) {				this.goodslist = new p_collect_goods;
				var byte_goodslist:ByteArray = new ByteArray;
				input.readBytes(byte_goodslist, 0, byte_goodslist_size);
				this.goodslist.readFromDataOutput(byte_goodslist);
			}
			this.tool_typeid = input.readInt();
			this.point_id = input.readInt();
			var byte_pos_size:int = input.readInt();
			if (byte_pos_size > 0) {				this.pos = new p_pos;
				var byte_pos:ByteArray = new ByteArray;
				input.readBytes(byte_pos, 0, byte_pos_size);
				this.pos.readFromDataOutput(byte_pos);
			}
			var size_roles:int = input.readShort();
			var length_roles:int = input.readInt();
			if (length_roles > 0) {
				var byte_roles:ByteArray = new ByteArray; 
				input.readBytes(byte_roles, 0, length_roles);
				for(i=0; i<size_roles; i++) {
					var tmp_roles:p_collect_role = new p_collect_role;
					var tmp_roles_length:int = byte_roles.readInt();
					var tmp_roles_byte:ByteArray = new ByteArray;
					byte_roles.readBytes(tmp_roles_byte, 0, tmp_roles_length);
					tmp_roles.readFromDataOutput(tmp_roles_byte);
					this.roles.push(tmp_roles);
				}
			}
		}
	}
}
