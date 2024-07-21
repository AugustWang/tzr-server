package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_tip_captain_toc extends Message
	{
		public var tip:String = "";
		public function m_educate_tip_captain_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_educate_tip_captain_toc", m_educate_tip_captain_toc);
		}
		public override function getMethodName():String {
			return 'educate_tip_captain';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.tip != null) {				output.writeUTF(this.tip.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.tip = input.readUTF();
		}
	}
}
