package modules.rank.view
{
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import com.components.BasePanel;
	import com.components.DataGrid;
	import com.utils.ComponentUtil;
	import modules.rank.view.items.MyselfItemRender;
	
	import proto.common.p_role_all_rank;
	
	public class PlayerRankView extends BasePanel
	{
		private var playerGrid:DataGrid;
		private var skin:Skin = new Skin();
		private var playerName:TextField;
		private var playerLvl:TextField;
		private var familyName:TextField;
		private static var _instance:PlayerRankView;
		public function PlayerRankView()
		{
			super("PlayerRankView");
			this.width = 453;
			this.height = 335;
			this.x = 280;
			this.y = 130;
		}
		
		public static function getInstance():PlayerRankView{
			if(!_instance){
				_instance = new PlayerRankView();
			}
			
			return _instance;
		}
		
		override protected function init():void{
			this.title = "玩家排行榜";
			this.titleAlign = 2;
			
			var backUI:Sprite = Style.getBlackSprite(440,275,2);
			this.addChild(backUI);
			backUI.mouseChildren = backUI.mouseEnabled = false;
			backUI.x = 5;
			backUI.y = 25;
			
			var textFormat:TextFormat = new TextFormat("Tahoma",12,0xffffff);
			var playerNameDesc:TextField = ComponentUtil.createTextField("玩家名:",10,0,textFormat,50,26,this);
			playerName = ComponentUtil.createTextField("",playerNameDesc.x + playerNameDesc.textWidth,playerNameDesc.y,textFormat,100,26,this);
			playerName.textColor = 0xe0a750;
			playerName.selectable = true;
			playerName.mouseEnabled = true;
			
			var playerLvlDesc:TextField = ComponentUtil.createTextField("等级:",playerName.x + playerName.width,playerName.y,textFormat,50,26,this);
			playerLvl = ComponentUtil.createTextField("",playerLvlDesc.x + playerLvlDesc.textWidth,playerLvlDesc.y,textFormat,50,26,this);
			playerLvl.textColor = 0xe0a750;
			playerLvl.selectable = true;
			playerLvl.mouseEnabled = true;
			
			var familyNameDesc:TextField = ComponentUtil.createTextField("门派名：",playerLvl.x + playerLvl.width,playerLvl.y,textFormat,50,26,this);
			familyName = ComponentUtil.createTextField("",familyNameDesc.x + familyNameDesc.textWidth,familyNameDesc.y,textFormat,100,26,this);
			familyName.textColor = 0xe0a750;
			familyName.selectable = true;
			familyName.mouseEnabled = true;
			
			playerGrid = new DataGrid();
			this.addChild(playerGrid);
			playerGrid.x = backUI.x +3;
			playerGrid.y = 22;
			playerGrid.width = 435;
			playerGrid.height = 270;
			playerGrid.mouseEnabled = false;
			playerGrid.addColumn("序号",50);
			playerGrid.addColumn("排行名称",80);
			playerGrid.addColumn("对应值",242);
			playerGrid.addColumn("排名",67);//-17
			playerGrid.itemHeight = 25;
			playerGrid.verticalScrollPolicy = ScrollPolicy.ON;
			playerGrid.list.setOverItemSkin(skin);
			playerGrid.list.setSelectItemSkin(skin);
		}
		
		public static var index:int = 0;
		public function changeData(playerArr:Array,name:String,lvl:int,fName:String):void{
			var arr:Array = [];
			playerArr.sortOn("ranking",Array.NUMERIC);
			for(var i:int=0;i<playerArr.length;i++){
				var obj:Object = {};
				obj.number = i+1;
				obj.key_name = playerArr[i].key_name;
				obj.key_value = playerArr[i].key_value;
				obj.rank_name = playerArr[i].rank_name;
				obj.ranking = playerArr[i].ranking;
				arr.push(obj);
			}
			playerGrid.dataProvider = arr;
			
			//update by 韩定 @2011.4.25 修改了但数据大于10时，datagrid下的list的横线会显示出来
			
			if(playerArr.length > 9)
			{
				playerGrid.pageCount = 10;
			}
			else
			{
				playerGrid.pageCount = playerArr.length + 1;
			}
			playerGrid.itemRenderer = MyselfItemRender;
			playerGrid.invalidateDisplayList();
			playerName.text = name;
			playerLvl.text = lvl.toString();
			if(fName == ""){
				familyName.text = "无";
			}else{
				familyName.text = fName;
			}
		}
	}
}