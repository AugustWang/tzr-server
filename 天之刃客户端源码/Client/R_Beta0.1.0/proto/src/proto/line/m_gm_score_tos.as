package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_gm_score_tos extends Message
	{
		public var id:int = 0;
		public var fraction:int = 0;
		public function m_gm_score_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_gm_score_tos", m_gm_score_tos);
		}
		public override function getMethodName():String {
			return 'gm_score';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.fraction);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.fraction = input.readInt();
		}
	}
}
