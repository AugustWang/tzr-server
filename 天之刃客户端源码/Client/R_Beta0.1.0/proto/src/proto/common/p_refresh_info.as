package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_refresh_info extends Message
	{
		public var refresh_type:int = 0;
		public var refresh_interval:int = 0;
		public var refresh_start_year:int = 0;
		public var refresh_end_year:int = 0;
		public var refresh_start_month:int = 0;
		public var refresh_end_month:int = 0;
		public var refresh_start_day:int = 0;
		public var refresh_end_day:int = 0;
		public var refresh_start_weekday:int = 0;
		public var refresh_end_weekday:int = 0;
		public var refresh_start_hour:int = 0;
		public var refresh_end_hour:int = 0;
		public var refresh_start_minute:int = 0;
		public var refresh_end_minute:int = 0;
		public var active_time:int = 0;
		public var start_time:int = 0;
		public var end_time:int = 0;
		public function p_refresh_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_refresh_info", p_refresh_info);
		}
		public override function getMethodName():String {
			return 'refresh_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.refresh_type);
			output.writeInt(this.refresh_interval);
			output.writeInt(this.refresh_start_year);
			output.writeInt(this.refresh_end_year);
			output.writeInt(this.refresh_start_month);
			output.writeInt(this.refresh_end_month);
			output.writeInt(this.refresh_start_day);
			output.writeInt(this.refresh_end_day);
			output.writeInt(this.refresh_start_weekday);
			output.writeInt(this.refresh_end_weekday);
			output.writeInt(this.refresh_start_hour);
			output.writeInt(this.refresh_end_hour);
			output.writeInt(this.refresh_start_minute);
			output.writeInt(this.refresh_end_minute);
			output.writeInt(this.active_time);
			output.writeInt(this.start_time);
			output.writeInt(this.end_time);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.refresh_type = input.readInt();
			this.refresh_interval = input.readInt();
			this.refresh_start_year = input.readInt();
			this.refresh_end_year = input.readInt();
			this.refresh_start_month = input.readInt();
			this.refresh_end_month = input.readInt();
			this.refresh_start_day = input.readInt();
			this.refresh_end_day = input.readInt();
			this.refresh_start_weekday = input.readInt();
			this.refresh_end_weekday = input.readInt();
			this.refresh_start_hour = input.readInt();
			this.refresh_end_hour = input.readInt();
			this.refresh_start_minute = input.readInt();
			this.refresh_end_minute = input.readInt();
			this.active_time = input.readInt();
			this.start_time = input.readInt();
			this.end_time = input.readInt();
		}
	}
}
