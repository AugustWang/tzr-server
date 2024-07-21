<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Link extends CI_Controller {

	function __construct()
	{
		parent::__construct();
	}

	function index($fid=false)
	{
		$this->load->model('Svnflog_model');
		$flogs = $this->Svnflog_model->get_log();
	
		$dataHeader = array();
		$dataHeader['flogs'] = $flogs;
		$dataHeader['flog'] = null;
		$this->load->view('header', $dataHeader);
		$this->load->view('link/index');
		$this->load->view('footer');
	}
}