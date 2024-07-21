package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_monster_dead_toc extends Message
	{
		public var monsterid:int = 0;
		public function m_monster_dead_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_monster_dead_toc", m_monster_dead_toc);
		}
		public override function getMethodName():String {
			return 'monster_dead';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.monsterid);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.monsterid = input.readInt();
		}
	}
}
