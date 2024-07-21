package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_country_points extends Message
	{
		public var faction_id:int = 0;
		public var points:int = 0;
		public function p_country_points() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_country_points", p_country_points);
		}
		public override function getMethodName():String {
			return 'country_po';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.faction_id);
			output.writeInt(this.points);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.faction_id = input.readInt();
			this.points = input.readInt();
		}
	}
}
