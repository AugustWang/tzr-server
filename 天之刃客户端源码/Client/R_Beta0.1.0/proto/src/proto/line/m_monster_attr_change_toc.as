package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_monster_attr_change_toc extends Message
	{
		public var monsterid:int = 0;
		public var change_type:int = 0;
		public var value:int = 0;
		public function m_monster_attr_change_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_monster_attr_change_toc", m_monster_attr_change_toc);
		}
		public override function getMethodName():String {
			return 'monster_attr_change';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.monsterid);
			output.writeInt(this.change_type);
			output.writeInt(this.value);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.monsterid = input.readInt();
			this.change_type = input.readInt();
			this.value = input.readInt();
		}
	}
}
