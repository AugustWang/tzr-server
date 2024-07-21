package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_collect_info_toc extends Message
	{
		public var score:int = 0;
		public var collect_num:int = 0;
		public var monster_kill_num:int = 0;
		public var left_tick:int = 0;
		public function m_family_collect_info_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_collect_info_toc", m_family_collect_info_toc);
		}
		public override function getMethodName():String {
			return 'family_collect_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.score);
			output.writeInt(this.collect_num);
			output.writeInt(this.monster_kill_num);
			output.writeInt(this.left_tick);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.score = input.readInt();
			this.collect_num = input.readInt();
			this.monster_kill_num = input.readInt();
			this.left_tick = input.readInt();
		}
	}
}
