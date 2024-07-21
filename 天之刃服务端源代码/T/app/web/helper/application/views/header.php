<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>T1-简单的事情重复做，重复的事情细心做</title>
    <link href="static/main.css?vs=<?php echo time();?>" rel="stylesheet" type="text/css">
    <script src="static/js/jquery-1.5.1.min.js"></script>
    <script src="static/js/swfobject.js" type="text/javascript"></script>
    <script src="static/js/jquery.timers.js" type="text/javascript"></script>
</head>
<body>

<div class="header">
<a href="#" class="logo">T1-内部帮助系统</a>
<!--
<div class="author_pannel">
帐号：<input type="text" />
密码：<input type="text" />
-->
</div>
</div>
<div class="main">
        <div class="main_left">
            <dl>
                <dt>链接</dt>
                <dd>
                    <ul>
                        <li><a href="?link/index">常用链接</a></li>
                    </ul>
                </dd>
                <dt>构建日志</dt>
                <dd>
                    <ul>
                        <?php if(!$flogs):?>
                        <li>暂无</li>
                        <?php else:?>
                        <?php foreach($flogs as $flogData):?>
                        <li>
                            <?php if($flog && $flog->flog_id == $flogData->flog_id):?>
                            <span class="highlight" title="<?php echo $flogData->from_vs;?>&nbsp;更新到&nbsp;<?php echo $flogData->to_vs;?>">
                                <?php echo date('Y-m-d H:i:s', $flogData->dateline);?>
                            </span>
                            <?php else: ?>
                            <a  href="?svnlog/index/<?php echo $flogData->flog_id;?>" 
                                title="<?php echo $flogData->from_vs;?>&nbsp;更新到&nbsp;<?php echo $flogData->to_vs;?>">
                                <?php echo date('Y-m-d H:i:s', $flogData->dateline);?>
                            </a>
                            <?php endif;?>
                        </li>
                        <?php endforeach;?>
                        <?php endif;?>
                    </ul>
                </dd>
            </dl>
    		<div class="clear_both"></div>
        </div>
        <div class="main_right">