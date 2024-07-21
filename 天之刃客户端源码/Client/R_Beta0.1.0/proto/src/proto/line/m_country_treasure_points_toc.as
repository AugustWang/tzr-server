package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_country_treasure_points_toc extends Message
	{
		public var points:Array = new Array;
		public function m_country_treasure_points_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_country_treasure_points_toc", m_country_treasure_points_toc);
		}
		public override function getMethodName():String {
			return 'country_treasure_points';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_points:int = this.points.length;
			output.writeShort(size_points);
			var temp_repeated_byte_points:ByteArray= new ByteArray;
			for(i=0; i<size_points; i++) {
				var t2_points:ByteArray = new ByteArray;
				var tVo_points:p_country_points = this.points[i] as p_country_points;
				tVo_points.writeToDataOutput(t2_points);
				var len_tVo_points:int = t2_points.length;
				temp_repeated_byte_points.writeInt(len_tVo_points);
				temp_repeated_byte_points.writeBytes(t2_points);
			}
			output.writeInt(temp_repeated_byte_points.length);
			output.writeBytes(temp_repeated_byte_points);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_points:int = input.readShort();
			var length_points:int = input.readInt();
			if (length_points > 0) {
				var byte_points:ByteArray = new ByteArray; 
				input.readBytes(byte_points, 0, length_points);
				for(i=0; i<size_points; i++) {
					var tmp_points:p_country_points = new p_country_points;
					var tmp_points_length:int = byte_points.readInt();
					var tmp_points_byte:ByteArray = new ByteArray;
					byte_points.readBytes(tmp_points_byte, 0, tmp_points_length);
					tmp_points.readFromDataOutput(tmp_points_byte);
					this.points.push(tmp_points);
				}
			}
		}
	}
}
