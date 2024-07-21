package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_plant_harvest_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var farm_id:int = 0;
		public function m_plant_harvest_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_plant_harvest_toc", m_plant_harvest_toc);
		}
		public override function getMethodName():String {
			return 'plant_harvest';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.farm_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.farm_id = input.readInt();
		}
	}
}
