package modules.personalybc.view
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.alert.Alert;
	import com.ming.ui.controls.Button;
	import com.utils.MoneyTransformUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	
	import modules.personalybc.PersonalYbcModule;
	
	import proto.line.m_personybc_info_toc;
	import proto.line.p_personybc_award_attr;
	
	public class BiaoView extends BasePanel
	{
		private var txt:TextField;
		private var btn:Button
		private var color:int
		public function BiaoView(key:String=null)
		{
			super(key);
			initView()
		}
		private function initView():void
		{
			
			var ui:Sprite = new Sprite();
			ui.x = 7;
			addChild(ui);
			ui.width=241;
			ui.height=280;
			this.addChild(ui)
				
			this.width = 255
			this.height =345;
				
			btn=new Button;
			
			txt=new TextField
			txt.mouseEnabled=false;
			
			txt.multiline=true;
			txt.wordWrap=true;
			txt.selectable=false;
			txt.width=220
			txt.height=345
			txt.x=21;
			txt.y=10;
			var _glow:GlowFilter = new GlowFilter(0x000000,1,2,2);
			txt.filters = [_glow];
			
			btn.width=70;
			btn.height=25;
			btn.label='取消护镖';
			btn.x=172;
			btn.y=279
			btn.addEventListener(MouseEvent.CLICK,_cancelFunc)	
			this.addChild(btn);
			this.addChild(txt)
		}
		private function getColorInfo(color:int):Object
		{
			var arrx:Array=[{jy:0,yz:0,bdyz:0},{jy:0,yz:0,bdyz:0},{jy:0,yz:0,bdyz:0},{jy:0,yz:0,bdyz:0},{jy:0,yz:0,bdyz:0}]
			var arr_info:Array=info_toc.info.attr_award
			for(var c:int=0;c<arr_info.length;c++)
			{
				var v: p_personybc_award_attr=arr_info[c] as p_personybc_award_attr
				switch(v.attr_type)
				{
					case 1:
						
						arrx[v.color-1].jy=v.attr_num;
						arrx[v.color-1].jy_num=v.attr_num
						break;
					case 2:
						
						arrx[v.color-1].yz=MoneyTransformUtil.silverToOtherString(v.attr_num);
						arrx[v.color-1].yz_num=v.attr_num
						break;
					case 3:
						
						arrx[v.color-1].bdyz=MoneyTransformUtil.silverToOtherString(v.attr_num)
						arrx[v.color-1].bdyz_num=v.attr_num
						break;
					
				}
			}
			return 	arrx[color-1]
		}
		private var info_toc:m_personybc_info_toc
		public function updata():void
		{
			this.info_toc=PersonalYbcModule.getInstance().view.info_toc
				if(this.info_toc==null)
				{
					return 
				}
			this.color=info_toc.info.color
			var baioche:String
			var str2:String=''
			try{
				
				if(info_toc.info.type == 1) {
					this.title = "国运拉镖";
				}else{
					this.title = "个人拉镖";
				}
				
				var bai:String='<FONT COLOR="#FFFFFF">白</FONT>'
				var lv:String='<FONT COLOR="#10ff04">绿</FONT>'
				var lan:String='<FONT COLOR="#00c6ff">蓝</FONT>'
				var zi:String='<FONT COLOR="#ff00c6">紫</FONT>'
				var cheng:String='<FONT COLOR="#FF6c00">橙</FONT>'
				var colors:Array=[bai,lv,lan,zi,cheng];
				var dun:String='<FONT COLOR="#F6F5CD">、</FONT>'
				var nowColor:String=colors[int(this.color-1)];
				baioche='<font color="#F6F5CD">护镖路线：</font><br>"' + getYbcRoute() + '<font color="#F6F5CD">（可</font><font color="#ff9900">M</font><font color="#F6F5CD">按打开地图查看路 线）</font><br><font color="#F6F5CD">提交镖车NPC：</font><br>' + getCommitNpc() + '<br><font color="#F6F5CD">注意： <br>1）镖车血为零，任务自动取消并扣除押金。<br>2）取消任务将扣除押金 ，不计算任务次数。</font><br><font color="#ffffff">3）</font><font color="#ff9900">超时</font><font  color="#ffffff">将扣除押金并只获得</font><font color="#ff9900">20%</font><font color="#ffffff">的奖励。 </font>'
				var obj:Object=getColorInfo(this.color)
				if(obj.jy_num>0)str2+='玩家经验： '+obj.jy+'\n';
				if(obj.yz_num>0)str2+='银    子： '+obj.yz+'\n';
				if(obj.bdyz_num>0)str2+='绑定银子： '+obj.bdyz+'\n';
				
				var str:String=baioche+'\n\n<FONT COLOR="#FFFF00">任务奖励：\n</FONT><FONT COLOR="#F6F5CD">'+str2+'\n</FONT>';
				
				txt.htmlText=str;
			}catch(e:Error){}	
		}
		
		private function getYbcRoute():String
		{
			var roleLevel:int = GlobalObjectManager.getInstance().user.attr.level;
			if (roleLevel < 40)
				return "<font color='#ff9900'>平江</font><font color='#F6F5CD'>←</font><font color='#ff9900'>京城 </font>";
			
			return "<font color='#ff9900'>边城</font><font color='#F6F5CD'>← </font><font color='#ff9900'>平江</font><font color='#F6F5CD'>←</font><font color='#ff9900'>京城 </font>";
		}
		
		private function getCommitNpc():String
		{
			var roleLevel:int = GlobalObjectManager.getInstance().user.attr.level;
			if (roleLevel < 40)
				return "<font color='#F6F5CD'>平江-</font><font color='#33ff99'>钱将军</font>";
			if (roleLevel < 60)
				return "<font color='#F6F5CD'>边城-</font><font color='#33ff99'>孙将军</font>";
			
			return "<font color='#F6F5CD'>边城-</font><font color='#33ff99'>蓝玉将军</font>";
		}
		
		private function _cancelFunc(e:MouseEvent):void
		{
			Alert.show("取消护镖不计算任务次数，不退回押金。你确定要取消吗？", "警告", _yesToCancel);
		}
		
		private function _yesToCancel():void{
			PersonalYbcModule.getInstance().cancel();
			this.closeWindow()
		}
	}
}