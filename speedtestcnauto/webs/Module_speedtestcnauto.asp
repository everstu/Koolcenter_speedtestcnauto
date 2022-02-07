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
.show-btn1, .show-btn2, .show-btn3 {
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

function init() {
	show_menu(menu_hook);
    showTab();
	tab_switch();
    queryTisu();
    getRuntime();
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
            if (arr[0] == "" || arr[1] == "") {
                E("tisu_status_4").innerHTML = "等待程序运行 - " + "Waiting for first refresh...";
                E("tisu_status_5").innerHTML = "等待程序运行 - " + "Waiting for first refresh...";
                E("tisu_status_6").innerHTML = "等待程序运行 - " + "Waiting for first refresh...";
            } else {
                E("tisu_status_4").innerHTML = arr[0];
                E("tisu_status_5").innerHTML = arr[1];
                E("tisu_status_6").innerHTML = arr[2];
            }
        }
    });
    if(CANSPEED)
    {
        setTimeout("getRuntime()",5000);
    }
}


function showTab()
{
	if($('.show-btn1').hasClass("active")){
        $("#kuandai_speed_status").show();
        $("#kuandai_info_status").hide();
	}else if($('.show-btn2').hasClass("active")){
        $("#kuandai_info_status").show();
        $("#kuandai_speed_status").hide();
	}else{
		$('.show-btn1').addClass('active');
		$('.show-btn2').removeClass('active');
        $("#kuandai_speed_status").show();
        $("#kuandai_info_status").hide();
	}
}

function tab_switch(){
	$(".show-btn1").click(
	function() {
		$('.show-btn1').addClass('active');
		$('.show-btn2').removeClass('active');
        showTab();
	});
	$(".show-btn2").click(
	function() {
		$('.show-btn1').removeClass('active');
		$('.show-btn2').addClass('active');
        showTab();
	});
}

function menu_hook(title, tab) {
	tabtitle[tabtitle.length - 1] = new Array("", "宽带自动提速");
	tablink[tablink.length - 1] = new Array("", "Module_speedtestcnauto.asp");
}

function queryTisu()
{
    $.ajax({
        url: "https://tisu-api.speedtest.cn/api/v2/speedup/query?source=www-index",
        cache: false,
        type: "GET",
        async: true,
        dataType: "json",
        success: function(res) {
            if(res.hasOwnProperty('data'))
            {
                let data = res.data;
                $('#tisu_status_2').html(formatTextColor('未开通提速套餐'));
                if(data.down_expire_t)
                {
                    $('#tisu_status_2').html('已开通提速套餐');
                }
                if(data.down_expire_trial_t)
                {
                    $('#tisu_status_2').html('已开通试用套餐');
                }
                $('#tisu_status_3').html(data.addr.substring(0,data.addr.indexOf(':')));
                if(data.hasOwnProperty('status'))
                {
                    let status = data.status;
                    if(status.can_speed === 1)
                    {
                        $('#tisu_status_1').html(formatTextColor('支持提速',2));
                        $('#tisu_info_1').html(formatTextColor('支持提速',2));
                        $('#tisu_info_2').html(status.msg);
                        $('#tisu_info_3').html("下行速率：" + formatTextColor(data.basic_down / 1024) +" M / 上行速率：" + formatTextColor(data.basic_up / 1024) + " M");
                        $('#tisu_info_4').html("下行速率：" + formatTextColor(data.target_down / 1024) +" M / 上行速率：" + formatTextColor(data.target_up / 1024) + " M");
                        $('#tisu_info_5').html(status.remain_time);
                    }
                    else
                    {
                        CANSPEED = false;
                        $('#tisu_status_1').html(formatTextColor('当前宽带不支持提速',1));
                        $('#tisu_status_2').html(formatTextColor('当前宽带不支持提速',1));
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
    queryTisu();
    if(CANSPEED)
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
                $('#mSup').attr('disabled','disabled');
            },
            success: function(response) {
                var setTime = 60;
                var time = setTime;
                $('#warning').html(response.result);
                t = setInterval(function () {
                    time--;
                    $('#mSup').val('冷却中,剩余 '+time+' 秒');
                    if(time <= 0)
                    {
                        $('#mSup').removeAttr('disabled');
                        $('#mSup').val('手动提速');
                        $('#warning').html('');
                        time = setTime;
                        clearInterval(t);
                    }
                },1000);
            },
            error:function(){
                $('#mSup').val('手动提速');
                $('#warning').html('');
                $('#mSup').removeAttr('disabled');
                clearInterval(t);
            }
        });
    }
}

function changeCanSpeed()
{

}
</script>
</head>
<body onload="init();">
	<div id="TopBanner"></div>
	<div id="Loading" class="popup_bg"></div>
	<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
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
												<li>本插件帮你实现开通宽带提速后,在您的外网IP变化后自动帮你执行提速操作 ，<a href="http://www.everstu.com/" target="_blank"><em><u>程序</u></em></a>来自Everstu.com。<a type="button" style="cursor:pointer" href="#"><em>【<u>插件更新日志(暂无)</u>】</em></a>
											</div>
											<div id="tablets">
												<table style="margin:10px 0px 0px 0px;border-collapse:collapse" width="100%" height="37px">
													<tr width="400px">
														<td colspan="4" cellpadding="0" cellspacing="0" style="padding:0" border="1" bordercolor="#000">
															<input id="show_btn1" class="show-btn1" style="cursor:pointer" type="button" value="宽带提速状态" />
															<input id="show_btn2" class="show-btn2" style="cursor:pointer" type="button" value="宽带信息查询" />
															<a id="show_btn3" class="show-btn3" style="cursor:pointer" type="button" href="/AdaptiveQoS_InternetSpeed.asp" target="_blank" title="请检查自己路由器是否支持此测速,此测速脚本为路由自带测速脚本.">测试网络速度</a>
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
                                                            当前宽带不支持提速
                                                        </td>
                                                    </tr>
													<tr>
														<th style="width:18%">
															<label>是否开通提速</label>
														</th>
                                                            <td id="tisu_status_2">
															未开通提速套餐
														</td>
													</tr>
													<tr>
														<th style="width:18%">前台查询IP地址</th>
														<td id="tisu_status_3">
														    未查询到IP地址
														</td>
													</tr>
													<tr>
														<th style="width:18%">后台查询IP地址</th>
														<td id="tisu_status_6">
                                                             等待程序运行 - Waiting for first refresh...
														</td>
													</tr>
													<tr>
														<th style="width:18%">最后运行时间</th>
														<td id="tisu_status_4">
                                                             等待程序运行 - Waiting for first refresh...
														</td>
													</tr>
													<tr>
														<th style="width:18%">最后提速时间</th>
														<td id="tisu_status_5">
                                                             等待程序运行 - Waiting for first refresh...
														</td>
													</tr>
												</table>
											</div>
											<div id="kuandai_info_status" >
											    <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                    <tr>
                                                        <th style="width:18%">
                                                            <label>宽带能否提速</label>
                                                        </th>
                                                        <td id="tisu_info_1">
                                                            当前宽带不支持提速
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <th style="width:18%">宽带提速信息</th>
                                                        <td id="tisu_info_2">
                                                            当前宽带不支持提速
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <th style="width:18%">宽带基本速率</th>
                                                        <td id="tisu_info_3">
                                                            当前宽带不支持提速
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <th style="width:18%">宽带升级后速率</th>
                                                        <td id="tisu_info_4">
                                                            当前宽带不支持提速
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <th style="width:18%">宽带提速有效期</th>
                                                        <td id="tisu_info_5">
                                                            当前宽带不支持提速
                                                        </td>
                                                    </tr>
                                                </table>
											</div>
											<div style="margin:10px 0 10px 5px;" class="splitLine"></div>
											<div id="warning" style="font-size:14px;margin:20px auto;text-align:center;color:yellow;"></div>
											<div class="apply_gen">
												<input class="button_gen" id="mSup" onClick="manualSpeedUp();" type="button" value="手动提速" />
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
