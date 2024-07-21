<?php

class MissionStatusNPCVO implements ISerialize {
	
	public $npcID;
	public $dialogues;
	
	public function getAS3Data() {
		$dialogues = array ();
		foreach ( $this->dialogues as $dialog ) {
			$questions = $dialog->questions;
			$chooseNPCS = $dialog->choose_npcs;
			$content = trim ( $dialog ['content'] );
			$content = str_replace("&lt;br&gt;", "&13#;", $content);
			if ($questions) {
				$dialog = array ();
				$dialog [] = Mission::$MISSION_NPC_DIALOGUES_TYPE_QUESTION; //标识是答题数组
				$dialog [] = $content;
				$answer = false;
				$questionsArr = array ();
				$questionIndex = 0;
				foreach ( $questions->question as $question ) {
					$questionsArr [] = trim ( $question );
					if ($question ['answer'] == 'true') {
						$answer = $questionIndex;
					}
					$questionIndex ++;
				}
				
				if ($answer === false) {
					trigger_error ( "答题任务没有录入答案" );
				}
				$dialog [] = $answer;
				
				$dialog [] = $questionsArr;
				$dialogues [] = $dialog;
			} elseif ($chooseNPCS) {
				$dialog = array ();
				$dialog [] = Mission::$MISSION_NPC_DIALOGUES_TYPE_CHOOSE_NPC; //标识是选择NPC
				$dialog [] = $content;
				
				$chooseNPCList = array();
				foreach ( $chooseNPCS->choose_npc as $chooseNPC ) {
					$chooseNPCList [] = array((int)$chooseNPC ['npc_id'], (string)$chooseNPC);
				}
				
				$dialog[] = $chooseNPCList;
				$dialogues [] = $dialog;
			} else {
				$dialogues [] = $content;
			}
		}
		
		return array (intval ( $this->npcID ), $dialogues );
	}
	
	public function getErlangData() {
		return intval ( $this->npcID );
	}
}

?>