package proto.line {
	import proto.common.p_map_farm;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_plant_fertilize_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var farm_info:p_map_farm = null;
		public var remain_fertilize_times:int = 0;
		public function m_plant_fertilize_toc() {
			super();
			this.farm_info = new p_map_farm;

			flash.net.registerClassAlias("copy.proto.line.m_plant_fertilize_toc", m_plant_fertilize_toc);
		}
		public override function getMethodName():String {
			return 'plant_fertilize';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_farm_info:ByteArray = new ByteArray;
			this.farm_info.writeToDataOutput(tmp_farm_info);
			var size_tmp_farm_info:int = tmp_farm_info.length;
			output.writeInt(size_tmp_farm_info);
			output.writeBytes(tmp_farm_info);
			output.writeInt(this.remain_fertilize_times);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var byte_farm_info_size:int = input.readInt();
			if (byte_farm_info_size > 0) {				this.farm_info = new p_map_farm;
				var byte_farm_info:ByteArray = new ByteArray;
				input.readBytes(byte_farm_info, 0, byte_farm_info_size);
				this.farm_info.readFromDataOutput(byte_farm_info);
			}
			this.remain_fertilize_times = input.readInt();
		}
	}
}
