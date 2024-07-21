package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_plant_fertilize_tos extends Message
	{
		public var farm_id:int = 0;
		public function m_plant_fertilize_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_plant_fertilize_tos", m_plant_fertilize_tos);
		}
		public override function getMethodName():String {
			return 'plant_fertilize';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.farm_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.farm_id = input.readInt();
		}
	}
}
