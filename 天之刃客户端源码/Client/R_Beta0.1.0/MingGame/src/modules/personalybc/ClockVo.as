package modules.personalybc
{
	
	
	public class ClockVo extends BaseVo
	{
		
		public var acceptTimer:Number
		public var time:Number;
		private  var _showTime:Number
	
		public function ClockVo()
		{
			super();
		}
		public function setUp(id:String,des:String,scened:int,acceptTimer:Number):void
		{
			if(des!=null)this.des=des;
			this.id=id;
			this.time=scened*1000+acceptTimer
			this.acceptTimer=acceptTimer
		
			
		}
		
		public function set showTime(value:Number):void
		{
			_showTime=value
		}
		public function get showTime():Number
		{
			return _showTime
		}
		public function get  showTimerString():String
		{
			var time:int=int(this._showTime)
			var str:String=''
			var m:int=(time/60000)%60
			var s:int=(time/1000)%60
			
			m<10?str+='0'+m+':':str+=m+':';
			s<10?str+='0'+s:str+=s
			time<=60?str='<FONT COLOR="#FF0000">'+str+'</FONT>':'<FONT COLOR="#FFFFFF">'+str+'</FONT>'
			return str
			
		}
	}
}