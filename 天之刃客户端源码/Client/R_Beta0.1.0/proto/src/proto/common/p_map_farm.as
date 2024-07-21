package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_map_farm extends Message
	{
		public var farm_id:int = 0;
		public var status:int = 0;
		public var planter_id:int = 0;
		public var seed_id:int = 0;
		public var seed_name:String = "";
		public var seed_type:int = 0;
		public var sow_time:int = 0;
		public var harvest_time:int = 0;
		public var harvest_segment:int = 0;
		public function p_map_farm() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_map_farm", p_map_farm);
		}
		public override function getMethodName():String {
			return 'map_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.farm_id);
			output.writeInt(this.status);
			output.writeInt(this.planter_id);
			output.writeInt(this.seed_id);
			if (this.seed_name != null) {				output.writeUTF(this.seed_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.seed_type);
			output.writeInt(this.sow_time);
			output.writeInt(this.harvest_time);
			output.writeInt(this.harvest_segment);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.farm_id = input.readInt();
			this.status = input.readInt();
			this.planter_id = input.readInt();
			this.seed_id = input.readInt();
			this.seed_name = input.readUTF();
			this.seed_type = input.readInt();
			this.sow_time = input.readInt();
			this.harvest_time = input.readInt();
			this.harvest_segment = input.readInt();
		}
	}
}
