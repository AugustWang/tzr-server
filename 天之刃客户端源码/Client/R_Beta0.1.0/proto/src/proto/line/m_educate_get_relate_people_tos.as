package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_get_relate_people_tos extends Message
	{
		public function m_educate_get_relate_people_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_educate_get_relate_people_tos", m_educate_get_relate_people_tos);
		}
		public override function getMethodName():String {
			return 'educate_get_relate_people';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
