package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_collect_base_info extends Message
	{
		public var id:int = 0;
		public var name:int = 0;
		public var degree:int = 0;
		public var demand:p_collect_demand = null;
		public var times:int = 0;
		public var goodslist:Array = new Array;
		public var tool_typeid:int = 0;
		public function p_collect_base_info() {
			super();
			this.demand = new p_collect_demand;

			flash.net.registerClassAlias("copy.proto.common.p_collect_base_info", p_collect_base_info);
		}
		public override function getMethodName():String {
			return 'collect_base_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.name);
			output.writeInt(this.degree);
			var tmp_demand:ByteArray = new ByteArray;
			this.demand.writeToDataOutput(tmp_demand);
			var size_tmp_demand:int = tmp_demand.length;
			output.writeInt(size_tmp_demand);
			output.writeBytes(tmp_demand);
			output.writeInt(this.times);
			var size_goodslist:int = this.goodslist.length;
			output.writeShort(size_goodslist);
			var temp_repeated_byte_goodslist:ByteArray= new ByteArray;
			for(i=0; i<size_goodslist; i++) {
				var t2_goodslist:ByteArray = new ByteArray;
				var tVo_goodslist:p_collect_goods = this.goodslist[i] as p_collect_goods;
				tVo_goodslist.writeToDataOutput(t2_goodslist);
				var len_tVo_goodslist:int = t2_goodslist.length;
				temp_repeated_byte_goodslist.writeInt(len_tVo_goodslist);
				temp_repeated_byte_goodslist.writeBytes(t2_goodslist);
			}
			output.writeInt(temp_repeated_byte_goodslist.length);
			output.writeBytes(temp_repeated_byte_goodslist);
			output.writeInt(this.tool_typeid);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.name = input.readInt();
			this.degree = input.readInt();
			var byte_demand_size:int = input.readInt();
			if (byte_demand_size > 0) {				this.demand = new p_collect_demand;
				var byte_demand:ByteArray = new ByteArray;
				input.readBytes(byte_demand, 0, byte_demand_size);
				this.demand.readFromDataOutput(byte_demand);
			}
			this.times = input.readInt();
			var size_goodslist:int = input.readShort();
			var length_goodslist:int = input.readInt();
			if (length_goodslist > 0) {
				var byte_goodslist:ByteArray = new ByteArray; 
				input.readBytes(byte_goodslist, 0, length_goodslist);
				for(i=0; i<size_goodslist; i++) {
					var tmp_goodslist:p_collect_goods = new p_collect_goods;
					var tmp_goodslist_length:int = byte_goodslist.readInt();
					var tmp_goodslist_byte:ByteArray = new ByteArray;
					byte_goodslist.readBytes(tmp_goodslist_byte, 0, tmp_goodslist_length);
					tmp_goodslist.readFromDataOutput(tmp_goodslist_byte);
					this.goodslist.push(tmp_goodslist);
				}
			}
			this.tool_typeid = input.readInt();
		}
	}
}
