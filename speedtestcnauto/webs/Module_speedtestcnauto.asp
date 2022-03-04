<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- version: 1.8 -->
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache"/>
<meta HTTP-EQUIV="Expires" CONTENT="-1"/>
<link rel="shortcut icon" href="images/favicon.png"/>
<link rel="icon" href="images/favicon.png"/>
<title>宽带自动提速</title>
<link rel="stylesheet" type="text/css" href="index_style.css"/> 
<link rel="stylesheet" type="text/css" href="form_style.css"/>
<link rel="stylesheet" type="text/css" href="css/element.css">
<link rel="stylesheet" type="text/css" href="res/softcenter.css">
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/help.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script language="JavaScript" type="text/javascript" src="/client_function.js"></script>
<script language="JavaScript" type="text/javascript" src="/validator.js"></script>
<script type="text/javascript" src="/js/jquery.js"></script>
<script type="text/javascript" src="/switcherplugin/jquery.iphone-switch.js"></script>
<script type="text/javascript" src="/res/softcenter.js"></script>
<style>
.loadingBarBlock{
    width:740px;
}
.popup_bar_bg_ks{
    position:fixed;
    margin: auto;
    top: 0;
    left: 0;
    width:100%;
    height:100%;
    z-index:99;
    /*background-color: #444F53;*/
    filter:alpha(opacity=90);  /*IE5、IE5.5、IE6、IE7*/
    background-repeat: repeat;
    visibility:hidden;
    overflow:hidden;
    /*background: url(/images/New_ui/login_bg.png);*/
    background:rgba(68, 79, 83, 0.85) none repeat scroll 0 0 !important;
    background-position: 0 0;
    background-size: cover;
    opacity: .94;
}
.show-btn{
	border-radius: 5px 5px 0px 0px;
	font-size:10pt;
	color: #fff;
	padding: 10px 3.75px;
	width:13.45601%;
	border: 1px solid #222;
	background: linear-gradient(to bottom, #919fa4 0%, #67767d 100%);
	border: 1px solid #91071f; /* W3C rogcss*/
	background: none; /* W3C rogcss*/
}
.active {
	background: linear-gradient(to bottom, #61b5de 0%, #279fd9 100%);
	border: 1px solid #222;
	background: linear-gradient(to bottom, #cf0a2c 0%, #91071f 100%); /* W3C rogcss*/
	border: 1px solid #91071f; /* W3C rogcss*/
}
#log_content1 {
	width:97%;
	padding-left:4px;
	padding-right:37px;
	font-family:'Lucida Console';
	font-size:11px;
	color:#FFFFFF;
	outline:none;
	overflow-x:hidden;
	border:0px solid #222;
	background:#475A5F;
	border:1px solid #91071f; /* W3C rogcss*/
	background:transparent; /* W3C rogcss*/
}
#kuandai_speed_status, #kuandai_info_status{
	margin: -1px 0px 0px 0px;
	border: 1px solid #91071f; /* W3C rogcss*/
}
</style>
<script>
var CANSPEED = true;
var NEEDQUERY = true;
var _responseLen;
var refresh_flag;
var count_down;
var changeLog;
var has_new_version = false;

function init() {
    testSpeedTest();
	show_menu(menu_hook);
    showTab();
	tab_switch();
    queryTisu(0);
    getRuntime();
    manualResetControl();
    checkVersion();
}

function checkVersion()
{
    if(! has_new_version)
    {
        $('#version_update').html('检查更新中...');
        $.ajax({
             type: "GET",
             url: "/_api/softcenter_module_speedtestcnauto_version",
             async: true,
		     cache:false,
             dataType: 'json',
             success: function(response) {
                 if(response['result'][0]['softcenter_module_speedtestcnauto_version'])
                 {
                    var old_version = parseFloat(response['result'][0]['softcenter_module_speedtestcnauto_version']);
                    $.ajax({
                             type: "GET",
                             url: "https://raw.githubusercontents.com/wengheng/Koolcenter_speedtestcnauto/master/version_info",
                             async: true,
		                     cache:false,
                             dataType: 'json',
                             success: function(response) {
                                 if(response['version'])
                                 {
                                    var new_version = parseFloat(response['version']);
                                    if(new_version > old_version)
                                    {
                                        $('#version_update').html('<font color="yellow">有新版本:<font color="red">v' + new_version + '</font>(点击更新)</font>');
                                        has_new_version = true;
                                    }
                                    else
                                    {
                                        $('#version_update').html('插件暂无更新');
                                        $('#version_update').hide();
                                        $('#version_update_1').show();
                                    }
                                 }
                                 if(response['change_log'])
                                 {
                                    changeLog = response['change_log'];
                                    $('#soft_change_log').click(function(){
                                        viewChangelog();
                                    });
                                 }
                             }
                    });
                 }
                 else
                 {
                    $('#version_update').html('插件暂无更新');
                    $('#version_update').hide();
                    $('#version_update_1').show();
                 }
             }
         });
    }
    else
    {
        $('#version_update').html('插件更新中');
        versionUpdate(0);
    }

    $('#version_update_1').hover(
        function () {
            $(this).css("color",'#ff3300');
            $(this).html('强行更新插件');
        },
        function () {
            $(this).css("color",'#00ffe4');
            $(this).html('插件暂无更新');
        }
    );
}

function viewChangelog()
{
    if(changeLog)
    {
        var num = 0;
        var logHtml = '';
        E("loading_block_spilt").style.visibility = "hidden";
        E("ok_button").style.visibility = "visible";
        showLoadingBar('插件更新日志');
        var retArea = E("log_content");
        $.each(changeLog,function (k,v){
            if(num >= 10)
            {
                return ;
            }
            var note = '';
            $.each(v.note,function(kk,vv) {
                note+="- " + vv + "\n";
            });
            logHtml += "版本号：v" + v.version + "\n" + "更新内容：\n" + note + "\n\n";
            num++;
        });
        retArea.value = logHtml;
    }
}

function tisuactlog()
{
    $.ajax({
        type: "GET",
        url: "/_temp/speedtestcnauto_tisuactlog",
        async: true,
        cache:false,
        dataType: 'text',
        success: function(response) {
            var retArea = E("log_content");
            E("loading_block_spilt").style.visibility = "hidden";
            E("ok_button").style.visibility = "visible";
            showLoadingBar('查看提速日志');
            retArea.value = response;
        },
        error: function (xhr) {
            E("ok_button").style.visibility = "visible";
            return false;
        }
    });
}


function versionUpdate(act)
{
    //act 0普通更新 1强制更新
    var id2 = parseInt(Math.random() * 100000000);
    var postData = {"id": id2, "method": "speedtestcnauto_main.sh", "params":['update', act], "fields": ""};
    $.ajax({
        type: "POST",
        url: "/_api/",
        async: true,
        data: JSON.stringify(postData),
        success: function(response) {
            if (response.result == id2){
                E("loading_block_spilt").style.visibility = "visible";
			    get_realtime_log(0);
            }
        }
    });
}

function get_realtime_log(flag) {
    E("ok_button").style.visibility = "hidden";
    showLoadingBar();
	$.ajax({
		url: '/_temp/speedtestcnauto_log.txt',
		type: 'GET',
		async: true,
		cache:false,
		dataType: 'text',
		success: function(response) {
            var retArea = E("log_content");
            if (response.search("SPEEDTNBBSCDE") != -1) {
                retArea.value = response.replace("SPEEDTNBBSCDE", "");
                E("ok_button").style.visibility = "visible";
                retArea.scrollTop = retArea.scrollHeight;
                if (flag == 1) {
                    count_down = -1;
                    refresh_flag = 0;
                } else {
                    count_down = 6;
                    refresh_flag = 1;
                }
                count_down_close();
                return false;
            }
            setTimeout("get_realtime_log(" + flag + ");", 200);
            retArea.value = response.replace("SPEEDTNBBSCDE", " ");
            retArea.scrollTop = retArea.scrollHeight;
        },
        error: function (xhr) {
            E("ok_button").style.visibility = "visible";
            return false;
        }
	});
}

function getRuntime()
{
    var id2 = parseInt(Math.random() * 100000000);
    var postData = {"id": id2, "method": "speedtestcnauto_main.sh", "params":['status'], "fields": ""};
    $.ajax({
        type: "POST",
        url: "/_api/",
        async: true,
        data: JSON.stringify(postData),
        success: function(response) {
            var arr = response.result.split("@");
            if (arr[0] != "" && arr[1] != "") {
                E("tisu_status_5").innerHTML = arr[0];
                E("tisu_status_6").innerHTML = arr[1];
                E("tisu_status_4").innerHTML = arr[2];
                //如果提速成功则展示提速日志
                if(arr[4] == 'yes')
                {
                    $("#tisuactlog").show();
                }
                NEEDQUERY = false;
            }
        }
    });
    if(CANSPEED || NEEDQUERY)
    {
        setTimeout("getRuntime()",5000);
    }
}


function showTab()
{
	if($('.show-btn1').hasClass("active")){
        $("#kuandai_speed_status").show();
        $("#kuandai_info_status").hide();
        $("#kuandai_speedtest").hide();
	}else if($('.show-btn2').hasClass("active")){
        $("#kuandai_info_status").show();
        $("#kuandai_speed_status").hide();
        $("#kuandai_speedtest").hide();
	}else if($('.show-btn3').hasClass("active")){
        $("#kuandai_info_status").hide();
        $("#kuandai_speed_status").hide();
        $("#kuandai_speedtest").show();
    }else{
		$('.show-btn1').addClass('active');
		$('.show-btn2').removeClass('active');
		$('.show-btn3').removeClass('active');
        $("#kuandai_speed_status").show();
        $("#kuandai_info_status").hide();
        $("#kuandai_speedtest").hide();
	}
}

function tab_switch(){
	$(".show-btn1").click(function() {
		$('.show-btn1').addClass('active');
		$('.show-btn2').removeClass('active');
		$('.show-btn3').removeClass('active');
        showTab();
	});
	$(".show-btn2").click(function() {
		$('.show-btn1').removeClass('active');
		$('.show-btn2').addClass('active');
		$('.show-btn3').removeClass('active');
        showTab();
	});
	$(".show-btn3").click(function() {
		$('.show-btn1').removeClass('active');
		$('.show-btn2').removeClass('active');
		$('.show-btn3').addClass('active');
        showTab();
	});
}

function menu_hook(title, tab) {
	tabtitle[tabtitle.length - 1] = new Array("", "宽带自动提速");
	tablink[tablink.length - 1] = new Array("", "Module_speedtestcnauto.asp");
}

function queryTisu(act)
{
    var apiurl = 'https://tisu-api.speedtest.cn/api/v2/speedup/query?source=www-index';
    var methon_type = 'GET';
    var postData = '';
    if(act == 1)
    {
        apiurl = '/_api/';
        methon_type = 'POST';
        postData = JSON.stringify({"id": parseInt(Math.random() * 100000000), "method": "speedtestcnauto_main.sh", "params":['query'], "fields": ""});
    }
    $.ajax({
        url: apiurl,
        type: methon_type,
        data: postData,
        cache: false,
        async: false,
        success: function(response) {
            var res = response;
            if(act == 1)
            {
                res = JSON.parse(window.atob(response['result']));
            }
            if(res.hasOwnProperty('data'))
            {
                var data = res.data;
                $('#tisu_status_3').html(data.addr.substring(0,data.addr.indexOf(':')));
                if(data.hasOwnProperty('status'))
                {
                    var status = data.status;
                    if(status.can_speed === 1)
                    {
                        CANSPEED=true;
                        var down_text = formatTextColor('未开通下行提速套餐');
                        var up_text = formatTextColor('未开通上行提速套餐');
                        if(data.down_expire_t)
                        {
                            down_text = formatTextColor('已开通下行提速套餐', 2);
                        }
                        if(data.down_expire_trial_t)
                        {
                            down_text = formatTextColor('已开通下行试用套餐', 2);
                        }
                        if(data.up_expire_t)
                        {
                            up_text = formatTextColor('已开通上行提速套餐', 2);
                        }
                        $('#tisu_status_2').html(down_text + ' / ' + up_text);

                        $('#tisu_status_1').html(formatTextColor('当前宽带支持提速',2));
                        $('#tisu_info_1').html(formatTextColor('当前宽带支持提速',2));
                        $('#tisu_info_2').html(status.msg);
                        $('#tisu_info_3').html("下行速率：" + formatTextColor(data.basic_down / 1024) +" M / 上行速率：" + formatTextColor(data.basic_up / 1024) + " M");
                        $('#tisu_info_4').html("下行速率：" + formatTextColor(data.target_down / 1024) +" M / 上行速率：" + formatTextColor(data.target_up / 1024) + " M");
                        $('#tisu_info_5').html(status.remain_time);
                        $('#tisu_status_7').html(status.remain_time);
                        $('#warning').html('');
                    }
                    else
                    {
                        CANSPEED = false;
                        $('#tisu_status_1').html(formatTextColor('当前宽带不支持提速',1));
                        $('#tisu_status_2').html(formatTextColor('当前宽带不支持提速',1));
                        $('#tisu_status_7').html(formatTextColor('当前宽带不支持提速',1));
                        $('#tisu_info_1').html(formatTextColor('当前宽带不支持提速',1));
                        $('#tisu_info_2').html(formatTextColor('当前宽带不支持提速',1));
                        $('#tisu_info_3').html(formatTextColor('当前宽带不支持提速',1));
                        $('#tisu_info_4').html(formatTextColor('当前宽带不支持提速',1));
                        $('#tisu_info_5').html(formatTextColor('当前宽带不支持提速',1));
                        $('#warning').html('当前宽带不支持提速<br>目前仅支持电信,联通,具体是否支持,请以此显示结果为准<br>本插件对你来说没有任何作用啦,你可以卸载本插件啦.',1);
                    }
                }
            }
        }
    });
}

function formatTextColor(text, color)
{
    let real_color = 'yellow';
    if(color === 2)
    {
        real_color = 'success';
    }
    return '<font color="'+real_color+'">'+text+'</font>';
}

function manualSpeedUp()
{
    queryTisu(1);
    var setTime = 60;
    var time = setTime;
    if(CANSPEED)//不支持提速就不要点了.
    {
        var id2 = parseInt(Math.random() * 100000000);
        var postData = {"id": id2, "method": "speedtestcnauto_main.sh", "params":['reopen'], "fields": ""};
        var t;
        $.ajax({
            type: "POST",
            url: "/_api/",
            async: true,
            data: JSON.stringify(postData),
            beforeSend:function (){
                manualResetControl(60);
            },
            success: function(response) {
                var arr = response.result.split("@");
                if (arr[0] != "" && arr[1] != "" && arr[2] != "" && arr[3] != "") {
                    E("tisu_status_5").innerHTML = arr[0];
                    E("tisu_status_6").innerHTML = arr[1];
                    E("tisu_status_4").innerHTML = arr[2];
                    E("warning").innerHTML       = arr[3];
                }
            },
            error:function(){

            }
        });
    }
    else
    {
        manualResetControl(60);
    }
}

var timeinter;
function manualResetControl(time)
{
    var resetTime = 0;
    var timestamp = (parseInt(Date.parse(new Date()))/1000);
    if(time)
    {
        timestamp += time;
        document.cookie ="speedtestcnauto_reset_time" + "=" + timestamp + ";expires=70";//"Name"是键,escape(是值)
        resetTime = parseInt(time);
        clearInterval(timeinter);
        timeinter='';
    }
    else
    {
        var resetTimeCookie = document.cookie.match(
            new RegExp("(^| )" + "speedtestcnauto_reset_time" + "=([^;]*)(;|$)")
        );
        if(resetTimeCookie)
        {
            resetTime = parseInt(resetTimeCookie[2]) - timestamp;
        }
    }

    if(resetTime && ! timeinter)
    {
        $('#mSup').attr('disabled','disabled');
        timeinter = setInterval(function () {
            resetTime--;
            $('#mSup').val('冷却中,剩余 '+resetTime+' 秒');
            if(resetTime <= 0)
            {
                $('#mSup').removeAttr('disabled');
                $('#mSup').val('手动提速');
                if(CANSPEED)
                {
                    $('#warning').html('');
                }
                clearInterval(timeinter);
            }
        },1000);
    }
}

function testSpeedTest() {
    var link = document.createElement('link')
    var speedtestUrl = '/internet_speed.html';
    link.rel = "stylesheet"
    link.type = "text/css"
    // 这里设置需要检测的url
    link.href = speedtestUrl
    link.onload = function () {
        var iframeHeight='420px';
        $(link).remove();//删除元素
        $('#internetSpeed_iframe').attr('src', speedtestUrl);
        $('#internetSpeed_iframe').css('height',iframeHeight);
        $('#internetSpeed_iframe').load(function (){
            var iframeObj = $('#internetSpeed_iframe').contents();
            iframeObj.find('.container').css('height', iframeHeight);
            iframeObj.find('.bg').css('min-height', iframeHeight);
            iframeObj.find('#speedTest_history_div').hide();
            iframeObj.find('.history_desc').hide();
            iframeObj.find('.speed_level_more').hide();
            iframeObj.find('#speed_level_btn').css('cursor','default');
            iframeObj.find('#speed_level_btn').removeAttr('onclick');
        });
    }
    link.onerror = function () {
        console.log('accessTest fail')
        $(link).remove();//删除元素
        $('#kuandai_speedtest').html('<h2 style="text-align:center;">您的路由器不支持测速功能!</h2>');
    }
    document.body.appendChild(link)
}

function showLoadingBar(title){
    document.scrollingElement.scrollTop = 0;
    E("loading_block_title").innerHTML = title ? title : "自动更新运行中，请稍后 ...";
    E("LoadingBar").style.visibility = "visible";
    var page_h = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
    var page_w = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
    var log_h = E("loadingBarBlock").clientHeight;
    var log_w = E("loadingBarBlock").clientWidth;
    var log_h_offset = (page_h - log_h) / 2;
    var log_w_offset = (page_w - log_w) / 2 + 90;
    $('#loadingBarBlock').offset({top: log_h_offset, left: log_w_offset});
}

function hideWBLoadingBar(){
    E("loading_block_spilt").style.visibility = "hidden";
    E("LoadingBar").style.visibility = "hidden";
    E("ok_button").style.visibility = "hidden";
    if (refresh_flag == "1"){
        var newURL = location.href.split("?")[0];
        window.history.pushState('object', document.title, newURL);
        refreshpage();
    }
}

function count_down_close() {
    if (count_down == "0") {
        hideWBLoadingBar();
    }
    if (count_down < 0) {
        E("ok_button1").value = "手动关闭"
        return false;
    }
    E("ok_button1").value = "自动关闭（" + count_down + "）"
    --count_down;
    setTimeout("count_down_close();", 1000);
}
</script>
</head>
<body onload="init();">
	<div id="TopBanner"></div>
	<div id="Loading" class="popup_bg"></div>
    <div id="LoadingBar" class="popup_bar_bg_ks" style="z-index: 200;" >
        <table cellpadding="5" cellspacing="0" id="loadingBarBlock" class="loadingBarBlock" align="center">
            <tr>
                <td height="100">
                    <div id="loading_block_title" style="margin:10px auto;margin-left:10px;width:85%; font-size:12pt;"></div>
                    <div id="loading_block_spilt" style="margin:10px 0 10px 5px;" class="loading_block_spilt">
                        <li><font color="#ffcc00">请等待日志显示完毕，并出现自动关闭按钮！</font></li>
                        <li><font color="#ffcc00">在此期间请不要刷新本页面，不然可能导致问题！</font></li>
                    </div>
                    <div style="margin-left:15px;margin-right:15px;margin-top:10px;overflow:hidden">
                        <textarea cols="50" rows="25" wrap="off" readonly="readonly" id="log_content" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" style="border:1px solid #000;width:99%; font-family:'Lucida Console'; font-size:11px;background:transparent;color:#FFFFFF;outline: none;padding-left:3px;padding-right:22px;overflow-x:hidden"></textarea>
                    </div>
                    <div id="ok_button" class="apply_gen" style="background:#000;visibility:hidden;">
                        <input id="ok_button1" class="button_gen" type="button" onclick="hideWBLoadingBar()" value="确定">
                    </div>
                </td>
            </tr>
        </table>
    </div>
    <table class="content" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td width="17">&nbsp;</td>
            <td valign="top" width="202">
                <div id="mainMenu"></div>
                <div id="subMenu"></div>
            </td>
            <td valign="top">
                <div id="tabMenu" class="submenuBlock"></div>
                <table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
                    <tr>
                        <td align="left" valign="top">
                            <table width="760px" border="0" cellpadding="5" cellspacing="0" bordercolor="#6b8fa3" class="FormTitle" id="FormTitle">
                                <tr>
                                    <td bgcolor="#4D595D" colspan="3" valign="top">
                                        <div>&nbsp;</div>
                                        <div class="formfonttitle">软件中心 - 宽带自动提速</div>
                                        <div style="float:right; width:15px; height:25px;margin-top:-20px">
                                            <img id="return_btn" onclick="reload_Soft_Center();" align="right" style="cursor:pointer;position:absolute;margin-left:-30px;margin-top:-25px;" title="返回软件中心" src="/images/backprev.png" onMouseOver="this.src='/images/backprevclick.png'" onMouseOut="this.src='/images/backprev.png'"></img>
                                        </div>
                                        <div style="margin:10px 0 10px 5px;" class="splitLine"></div>
                                        <div class="SimpleNote">
                                            <li>本插件帮你实现开通宽带提速后,在您的外网IP变化后自动帮你执行提速操作 ，<a href="http://www.everstu.com/" target="_blank"><em><u>程序</u></em></a>来自Everstu.com。<a id="soft_change_log" type="button" style="cursor:pointer" href="javascript:void(0);"><em>【<u>插件更新日志</u>】</em></a>
                                        </div>
                                        <div id="tablets">
                                            <table style="margin:10px 0px 0px 0px;border-collapse:collapse" width="100%" height="37px">
                                                <tr width="400px">
                                                    <td colspan="4" cellpadding="0" cellspacing="0" style="padding:0" border="1" bordercolor="#000">
                                                        <input id="show_btn1" class="show-btn show-btn1" style="cursor:pointer" type="button" value="宽带提速状态" />
                                                        <input id="show_btn2" class="show-btn show-btn2" style="cursor:pointer" type="button" value="宽带信息查询" />
                                                        <input id="show_btn3" class="show-btn show-btn3" style="cursor:pointer" type="button" value="网络测速(本地)">
                                                        <a id="show_btn4" class="show-btn show-btn4" style="cursor:pointer" type="button" value="" href="https://www.speedtest.net" target="_blank">网络测速(在线)</a>
                                                        <a id="version_update" class="show-btn" style="cursor:pointer" type="button" onClick="checkVersion();">检查更新中...</a>
                                                        <a id="version_update_1" class="show-btn" style="cursor:pointer;color:#00ffe4;display:none;" type="button" onClick="versionUpdate(1);">插件暂无更新</a>
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div id="kuandai_speed_status">
                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                <tr>
                                                    <th style="width:18%">
                                                        <label>宽带能否提速</label>
                                                    </th>
                                                    <td id="tisu_status_1">
                                                         等待程序运行 - Waiting for first refresh...
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th style="width:18%">
                                                        <label>是否开通提速</label>
                                                    </th>
                                                    <td id="tisu_status_2">
                                                         等待程序运行 - Waiting for first refresh...
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th style="width:18%">宽带提速有效期</th>
                                                    <td id="tisu_status_7">
                                                          等待程序运行 - Waiting for first refresh...
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th style="width:18%">前台查询IP地址</th>
                                                    <td id="tisu_status_3">
                                                        等待程序运行 - Waiting for first refresh...
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th style="width:18%">后台查询IP地址</th>
                                                    <td id="tisu_status_4">
                                                        等待程序运行 - Waiting for first refresh...
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th style="width:18%">最后运行时间</th>
                                                    <td>
                                                         <label id="tisu_status_5">等待程序运行 - Waiting for first refresh...</label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th style="width:18%">最后提速时间</th>
                                                    <td>
                                                         <label id="tisu_status_6">等待程序运行 - Waiting for first refresh...</label>
                                                         &nbsp;&nbsp;<input style="display:none;" class="button_gen" id="tisuactlog" onClick="tisuactlog();" type="button" value="查看提速日志" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th style="width:18%">手动提速操作</th>
                                                    <td>
                                                         <input class="button_gen" id="mSup" onClick="manualSpeedUp();" type="button" value="手动提速" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div id="kuandai_info_status" style="display:none;">
                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                <tr>
                                                    <th style="width:18%">
                                                        <label>宽带能否提速</label>
                                                    </th>
                                                    <td id="tisu_info_1">
                                                         等待程序运行 - Waiting for first refresh...
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th style="width:18%">宽带提速信息</th>
                                                    <td id="tisu_info_2">
                                                         等待程序运行 - Waiting for first refresh...
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th style="width:18%">宽带基本速率</th>
                                                    <td id="tisu_info_3">
                                                         等待程序运行 - Waiting for first refresh...
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th style="width:18%">宽带升级后速率</th>
                                                    <td id="tisu_info_4">
                                                         等待程序运行 - Waiting for first refresh...
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th style="width:18%">宽带提速有效期</th>
                                                    <td id="tisu_info_5">
                                                         等待程序运行 - Waiting for first refresh...
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div id="kuandai_speedtest" style="display:none;">
                                            <iframe id="internetSpeed_iframe" style="width: 100%; border: none;" src=""></iframe>
                                        </div>
                                        <div style="margin:10px 0 10px 5px;" class="splitLine"></div>
                                        <div id="warning" style="font-size:14px;margin:20px auto;text-align:center;color:yellow;"></div>
                                        <div class="apply_gen">
<!-- 												<input class="button_gen" id="mSup" onClick="manualSpeedUp();" type="button" value="手动提速" /> -->
                                        </div>
                                        <div class="SimpleNote">
                                            <li>如果使用中提速有任何问题,可以点击<a href="javascript:void();" onClick="manualSpeedUp();"><em><u>手动提速</u></em></a>来清除所有插件缓存,重新触发提速</li>
                                            <li>插件使用有任何问题请加入<a href="https://t.me/xbchat" target="_blank"><em><u>koolcenter TG群</u></em></a>联系@fiswonder</li>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
            <td width="10" align="center" valign="top"></td>
        </tr>
    </table>
	<div id="footer"></div>
</body>
</html>
