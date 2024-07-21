<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Compile extends CI_Controller {

	function __construct()
	{
		parent::__construct();
	}
	
	function _getSVNDir() {
		$this->config->load('versions', true);
		return $this->config->item('svn_dir', 'versions');
	}
	function _getVersions(){
		$this->config->load('versions', true);
		return $this->config->item('versions', 'versions');
	}
	function _getVersion($id){
		$versions = $this->_getVersions();
		return $versions[$id];
	}
	
	function start_compile(){
		$vid = $this->input->post('vid');
		$svn = $this->input->post('svn');
		$svnPass = $this->input->post('svnPass');
		$rebuild = $this->input->post('rebuild');
		
		$versionName = $this->_getVersion($vid);
		if(!$versionName || $vid==0){
			show_error('没有找到相应版本');
		}
		
		$svnDir = $this->_getSVNDir();
		if($svnDir != 'trunk'){
			$svnDir = 'branch/'.$versionName;
		}
		//./daily_public IP(auto则自动获取本机) svn前端子目录 svn后端子目录 版本标识(标明是beta或者其他) 是否整个rebuild(true默认)
		$f=fopen('/data/tmp/compile_args.txt', 'w');
		fwrite($f, "auto $svnDir $svnDir $versionName $rebuild $svn $svnPass");
		fclose($f);
		echo 'ok';
	}
	
	function public_version(){
		$f=fopen('/data/tmp/public_version.start', 'w');
		fclose($f);
		echo 'ok';
	}
	
	function index($fid=false)
	{
		$this->load->model('Svnflog_model');
		$flogs = $this->Svnflog_model->get_log();
	
		$dataHeader = array();
		$dataHeader['flogs'] = $flogs;
		$dataHeader['flog'] = null;
		
		$dataBody = array();
		$dataBody['versions'] = $this->_getVersions();
		$this->load->view('header', $dataHeader);
		$this->load->view('compile/index', $dataBody);
		$this->load->view('footer');
	}
	
	function get_log_trace($log=false){
		$logString = '请耐心等待...';
		if(file_exists('/data/logs/daily_public/daily_all.log')){
			$logString = file_get_contents('/data/logs/daily_public/daily_all.log');
		}
		$this->load->view('compile/log_trace', array('log_string'=>$logString));
	}
}