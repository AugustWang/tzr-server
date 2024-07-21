package modules.team
{
	import com.common.GlobalObjectManager;
	
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.utils.Dictionary;
	
	import modules.team.view.FiveElements;
	import modules.team.view.TeamIcon;
	import modules.team.view.TeamListSprite;
	import modules.team.view.TeamRoleView;
	
	import proto.line.m_team_offline_toc;
	import proto.line.p_team_role;

	public class TeamView extends Sprite
	{
		/*暂时屏蔽*/
		//public var five:FiveElements;
		public var icon:TeamIcon;
		public var list:TeamListSprite;
		public var isCaptain:Boolean;

		public function TeamView()
		{
			super();
			this.x=3;
			this.y=112;
		}

		public function setup():void
		{
			/*暂时屏蔽*/
//			five=new FiveElements;
//			five.setup();
//			five.x=65;
//			five.y=-32;
			icon=new TeamIcon;
			icon.x=38;
			icon.y=-10;
			icon.visible=false;
			list=new TeamListSprite;
//			addChild(five);
			addChild(icon);
			addChild(list);
		}

		/**
		 * 刷新列表
		 * @param arr
		 *
		 */
		public function reFresh(arr:Array, hasTeam:Boolean=true):void
		{
			var hash:Dictionary=list.hash;
			var num:int;
			for (var s:String in hash)
			{
				num=1;
				var t:TeamRoleView=hash[s] as TeamRoleView;
				for (var i:int=0; i < arr.length; i++)
				{
					if (t.pvo.role_id == arr[i].role_id)
					{
						num=0;
						break;
					}
					num+=1;
				}
				//原来的TeamRoleView不在arr里面时，删掉
				if (num == arr.length + 1)
				{
					delete list.hash[t.pvo.role_id]
					t.unload();
				}
			}
			var index:int=0;
			isCaptain=checkIsCaptain(arr);
			for (i=0; i < arr.length; i++)
			{
				var team:p_team_role=arr[i] as p_team_role;
				if (GlobalObjectManager.getInstance().user.base.role_id != team.role_id)
				{
					var tiao:TeamRoleView=list.hash[team.role_id] as TeamRoleView;
					if (tiao == null)
					{
						tiao=new TeamRoleView(team, isCaptain);
						tiao.setupUI();
						this.list.addChild(tiao);
					}
					else
					{
						tiao.upDate(team, isCaptain);
					}
					tiao.y=index * 40;
					index++;
				}
				else
				{
					icon.reFresh(isCaptain);
					/*暂时屏蔽*/
					//five.reFresh(team.add_hp, team.add_mp, team.add_phy_attack, team.add_magic_attack);
				}
			}
			//没队时清除五行加成属性
			if (arr.length == 0)
			{
				/*暂时屏蔽*/
				//five.reFresh(0, 0, 0, 0);
			}
			if (arr.length > 0)
			{
				icon.visible=true;
			}
			else
			{
				icon.visible=false;
			}
			TeamDataManager.teamMembers=arr;
		}

		/**
		 * 队员可见性
		 * @param arr 可见队员列表
		 *
		 */
		public function reMemberVisible(arr:Array):void
		{
			var t:TeamRoleView;
			for (var i:int=0; i < this.list.numChildren; i++)
			{
				t=this.list.getChildAt(i) as TeamRoleView;
				if (t != null)
				{
					t.alpha=0.4;
				}
			}
			for (i=0; i < this.list.numChildren; i++)
			{
				t=this.list.getChildAt(i) as TeamRoleView;
				for (var j:int=0; j < arr.length; j++)
				{
					if (t != null)
					{
						if (t.pvo.role_id == arr[j])
						{
							t.alpha=1;
							t.tip="";
							break;
						}
					}
				}

			}
		}

		/**
		 * 离线
		 * @param vo
		 *
		 */
		public function offlineSet(vo:m_team_offline_toc):void
		{
			if (vo.cache_offline == true)
			{ //暂时离线
				for (var i:int=0; i < this.list.numChildren; i++)
				{
					var t:TeamRoleView=this.list.getChildAt(i) as TeamRoleView;
					if (t != null && t.pvo.role_id == vo.role_id)
					{
						var mat:Array=[0.5, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0, 0, 0, 1, 0];
						var cm:ColorMatrixFilter=new ColorMatrixFilter(mat);
						t.filters=[cm];
					}
				}
			}
		}

		private function checkIsCaptain(arr:Array):Boolean
		{
			for (var i:int=0; i < arr.length; i++)
			{
				var p:p_team_role=arr[i];
				if (p.role_id == GlobalObjectManager.getInstance().user.base.role_id && p.is_leader == true)
				{
					return true;
				}
			}
			return false;
		}
	}
}