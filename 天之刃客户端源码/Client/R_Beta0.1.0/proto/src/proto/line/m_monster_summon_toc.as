package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_monster_summon_toc extends Message
	{
		public var monster_id:int = 0;
		public function m_monster_summon_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_monster_summon_toc", m_monster_summon_toc);
		}
		public override function getMethodName():String {
			return 'monster_summon';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.monster_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.monster_id = input.readInt();
		}
	}
}
