package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_educate_fb_award extends Message
	{
		public var min_count:int = 0;
		public var max_count:int = 0;
		public var award_number:int = 0;
		public function p_educate_fb_award() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_educate_fb_award", p_educate_fb_award);
		}
		public override function getMethodName():String {
			return 'educate_fb_a';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.min_count);
			output.writeInt(this.max_count);
			output.writeInt(this.award_number);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.min_count = input.readInt();
			this.max_count = input.readInt();
			this.award_number = input.readInt();
		}
	}
}
