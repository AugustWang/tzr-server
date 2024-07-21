package proto.line {
	import proto.line.p_warofcity;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_warofcity_panel_toc extends Message
	{
		public var cities:Array = new Array;
		public function m_warofcity_panel_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_warofcity_panel_toc", m_warofcity_panel_toc);
		}
		public override function getMethodName():String {
			return 'warofcity_panel';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_cities:int = this.cities.length;
			output.writeShort(size_cities);
			var temp_repeated_byte_cities:ByteArray= new ByteArray;
			for(i=0; i<size_cities; i++) {
				var t2_cities:ByteArray = new ByteArray;
				var tVo_cities:p_warofcity = this.cities[i] as p_warofcity;
				tVo_cities.writeToDataOutput(t2_cities);
				var len_tVo_cities:int = t2_cities.length;
				temp_repeated_byte_cities.writeInt(len_tVo_cities);
				temp_repeated_byte_cities.writeBytes(t2_cities);
			}
			output.writeInt(temp_repeated_byte_cities.length);
			output.writeBytes(temp_repeated_byte_cities);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_cities:int = input.readShort();
			var length_cities:int = input.readInt();
			if (length_cities > 0) {
				var byte_cities:ByteArray = new ByteArray; 
				input.readBytes(byte_cities, 0, length_cities);
				for(i=0; i<size_cities; i++) {
					var tmp_cities:p_warofcity = new p_warofcity;
					var tmp_cities_length:int = byte_cities.readInt();
					var tmp_cities_byte:ByteArray = new ByteArray;
					byte_cities.readBytes(tmp_cities_byte, 0, tmp_cities_length);
					tmp_cities.readFromDataOutput(tmp_cities_byte);
					this.cities.push(tmp_cities);
				}
			}
		}
	}
}
