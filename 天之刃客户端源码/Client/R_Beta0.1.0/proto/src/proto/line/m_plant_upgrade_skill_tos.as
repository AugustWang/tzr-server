package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_plant_upgrade_skill_tos extends Message
	{
		public function m_plant_upgrade_skill_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_plant_upgrade_skill_tos", m_plant_upgrade_skill_tos);
		}
		public override function getMethodName():String {
			return 'plant_upgrade_skill';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
