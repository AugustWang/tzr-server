package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_active_points_toc extends Message
	{
		public var new_points:int = 0;
		public function m_family_active_points_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_active_points_toc", m_family_active_points_toc);
		}
		public override function getMethodName():String {
			return 'family_active_points';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.new_points);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.new_points = input.readInt();
		}
	}
}
