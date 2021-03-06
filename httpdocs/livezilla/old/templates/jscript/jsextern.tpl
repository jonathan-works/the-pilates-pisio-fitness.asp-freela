//window.onerror = lz_global_handle_exception;
window.onbeforeunload = lz_chat_before_unload;
window.onunload = lz_chat_unload;

var lz_chat_data = new lz_chat_data_box();
var lz_poll_request;
var lz_shout_request;
var lz_resize_interval = null;
var lz_title_timer;
var lz_title_step = 0;
var lz_title_modes = new Array(document.title,"<!--lang_client_new_messages-->");
var lz_chat_rate_settings = new Array(0,0);
var lz_chat_feedback_comment_started = false;
var lz_chat_feedback_comment_sent = false;
var lz_document_head = document.getElementsByTagName("head")[0];
var lz_geo_resolution;
var lz_geo_resolution_needed = <!--geo_resolute-->;
var lz_user_id = "<!--user_id-->";
var lz_browser_id = "<!--browser_id-->";
var lz_server_id = "<!--server_id-->";
var lz_geo_url = "<!--geo_url-->";
var lz_mip = "<!--mip-->";
var lz_oak = '';
var lz_is_ie = <!--is_ie-->;

var lz_shared_kb_auto_search = <!--kb_suggest-->;
var lz_shared_kb_last_search_time = 0;

<!--calcoak-->

lz_chat_data.TempImage.onload=lz_chat_show_intern_image;
lz_chat_data.TempImage.onerror=new function(){
};
lz_chat_data.GeoResolution = new lz_geo_resolver();

lz_chat_detect_sound();

if(<!--window_resize-->)
    window.resizeTo(<!--window_width-->,<!--window_height-->);

function lz_get_session()
{
	return lz_chat_data.ExternalUser.Session;
}

function lz_chat_remove_from_parent()
{
	if(window.opener != null)
	{

		try
		{
			if(typeof(window.opener.lz_tracking_remove_chat_window) != 'undefined')
				window.opener.lz_tracking_remove_chat_window(lz_chat_data.ExternalUser.Session.BrowserId);
		}
		catch(ex)
		{
		 // domain restriction
		}
	}
}

function lz_chat_announce_to_parent()
{
    try
    {
        if(window.opener != null)
        {
            if(typeof(window.opener.lz_tracking_add_chat_window) != 'undefined')
            {
                window.opener.lz_tracking_add_chat_window(lz_chat_data.ExternalUser.Session.BrowserId,false);
                if(lz_chat_data.WindowAnnounce == null)
                    lz_chat_data.WindowAnnounce = setTimeout("lz_chat_data.WindowAnnounce=null;lz_chat_announce_to_parent();",2000);
                if(lz_chat_data.ParentURI==null && window.opener.location.href!=null)
                    lz_chat_data.ParentURI = window.opener.location.href;
            }
        }
    }
    catch(ex)
    {
     // domain restriction
    }
}

function lz_chat_unload()
{
    if(lz_chat_data.CurrentApplication=="chat" && lz_chat_data.Status.Status >= lz_chat_data.STATUS_INIT)
    {
        lz_chat_stop_system();

        if(lz_poll_request != null)
            lz_poll_request.TimeoutConnection();

        if(lz_shout_request != null)
            lz_shout_request.TimeoutConnection();

        var closeSessionConnect = new lz_connector("./server.php",lz_chat_get_post_values("logoff",false,false),10000);
        closeSessionConnect.ConnectAsync();
    }
}

function lz_chat_before_unload()
{
    if((lz_chat_data.CurrentApplication=="chat"||lz_chat_data.CurrentApplication=="callback") && lz_chat_data.Status.Status >= lz_chat_data.STATUS_INIT)
    {
        lz_chat_switch_options(true);
        if(lz_chat_data.FeedbackURL != null && lz_chat_data.FeedbackOnExit && lz_chat_data.Status.Status >= lz_chat_data.STATUS_ACTIVE && lz_chat_show_feedback(false))
            return "<!--lang_client_ask_feedback-->";
        else if(lz_chat_data.Status.Status < lz_chat_data.STATUS_STOPPED)
            return "<!--lang_client_really_close-->";
    }
}

function lz_chat_set_translation(_activeId,_from,_into)
{
    _into = lz_global_base64_decode(_into).toLowerCase();
    _from = lz_global_base64_decode(_from).toLowerCase();

    _into = (_into.length==0) ? null : _into;
    _from = (_from.length==0) ? null : _from;

    if(lz_chat_data.TranslationActive != _activeId)
    {
        lz_chat_data.TranslationActive = _activeId;
        lz_chat_get_frame_object('lz_chat_translation_target_language').disabled = (_from == null);
        lz_chat_get_frame_object('lz_translation_service_active').checked = (_from != null);
    }
    else
        return;

    if(lz_chat_data.TranslateFrom != _from && _from != null)
    {
        lz_chat_data.TranslateFrom = _from;
        for(var i=0;i<lz_chat_get_frame_object('lz_chat_translation_target_language').options.length;i++)
        {
            if(lz_chat_get_frame_object('lz_chat_translation_target_language').options[i].value==_from)
                lz_chat_get_frame_object('lz_chat_translation_target_language').selectedIndex = i;
        }
    }
    if(lz_chat_data.TranslateInto != _into)
        lz_chat_data.TranslateInto = _into;
}

function lz_chat_chat_resize_detect(_on)
{
    if(_on && lz_resize_interval == null)
        lz_resize_interval = setInterval("lz_chat_chat_resize_input();",500);
}

function lz_chat_chat_resize_input()
{
    try
    {
        var tbheight = parseInt(lz_chat_get_frame_object('lz_chat_text').style.height.replace("px",""));
        lz_chat_get_frame_object('lz_chat_floor').style.height = tbheight+30+"px";
        lz_chat_get_frame_object('lz_chat_main').style.bottom = tbheight+30+"px";
    }
    catch(ex)
    {
    }
}

function lz_chat_init_rating_drop_down(_cntdwn)
{

}

function lz_chat_rating_drop_down()
{

}

function lz_chat_change_browser_id(_newId)
{
    lz_chat_data.ExternalUser.Session.BrowserId = _newId;
    lz_chat_data.ExternalUser.Session.Save();
}
	
function lz_chat_set_parentid()
{			
	lz_chat_data.ExternalUser.Session = new lz_jssess();
	lz_chat_data.ExternalUser.Session.Load();
	try
	{
		if(window.opener != null && typeof(window.opener.lz_get_session) != 'undefined')
		{
			lz_chat_data.ExternalUser.Session.UserId = window.opener.lz_get_session().UserId;
			if(lz_chat_data.ExternalUser.Session.GeoResolved.length == 0)
				lz_chat_data.ExternalUser.Session.GeoResolved = window.opener.lz_get_session().GeoResolved;
		}
	}
	catch(ex){
    }
	lz_chat_data.ExternalUser.Session.Save();
}

function lz_chat_startup()
{
	if(lz_chat_data.Groups == null)
	{
		lz_chat_data.Groups = new lz_group_list(lz_chat_get_frame_object(''),lz_chat_get_frame_object('lz_form_groups'));
        lz_chat_data.Groups.StatusIcon = !lz_chat_data.IsSmall && !<!--rtl-->;
		lz_chat_data.Groups.CreateHeader("<!--lang_client_please_select-->");
        lz_chat_reload_groups();
	}
	lz_chat_announce_to_parent();
}

function lz_chat_reload_groups()
{
	if(lz_chat_data.Status.Status > lz_chat_data.STATUS_START)
		return;

	if(!lz_chat_data.Status.Loaded)
	{
		lz_chat_change_group(lz_chat_get_frame_object('lz_form_groups'),false);
		lz_chat_server_request("./server.php",lz_chat_get_post_values("reloadgroups",true,true),30000,null);
	}
	else
	{
		if(!lz_chat_data.ConnectionRunning)
			lz_chat_server_request("./server.php",lz_chat_get_post_values("reloadgroups",false,true),30000,null);
	}
}

function lz_chat_get_post_data(_action)
{
    var fd = new FormData();
    fd.append("p_request","extern");
    if(lz_chat_data.WaitingLinksShow)
        fd.append("p_wls","1");

    if(lz_chat_data.CallMeBackMode)
        fd.append("p_cmb","1");

    if(_action == "send_mail")
    {
        fd.append("p_action","mail");
        fd.append("p_username",lz_global_base64_url_encode(lz_chat_data.ExternalUser.Username));
        fd.append("p_group",lz_global_base64_url_encode(lz_chat_data.ExternalUser.Group));
        fd.append("p_email",lz_global_base64_url_encode(lz_chat_data.ExternalUser.Email));
        fd.append("p_company",lz_global_base64_url_encode(lz_chat_data.ExternalUser.Company));
        fd.append("p_question",lz_global_base64_url_encode(lz_chat_data.ExternalUser.MailText));
        fd.append("p_phone",lz_global_base64_url_encode(lz_chat_data.ExternalUser.Phone));

        for(var i=0;i<10;i++)
        {
            if(lz_chat_data.InputFieldValues[i].Active && lz_chat_data.InputFieldValues[i].Index.toString().length==1 && lz_chat_data.InputFieldValues[i].Value.toString().length>0)
            {
                if(lz_chat_data.InputFieldValues[i].Type != "File")
                    fd.append("p_cf" + lz_chat_data.InputFieldValues[i].Index, lz_global_base64_url_encode(lz_chat_data.InputFieldValues[i].Value));
                else if(lz_chat_data.InputFieldValues[i].Type == "File" && lz_chat_data.InputFieldValues[i].Value != null)
                {
                    fd.append("p_cf" + lz_chat_data.InputFieldValues[i].Index, lz_chat_get_frame_object('').getElementsByName("form_" + lz_chat_data.InputFieldValues[i].Index)[0].files[0]);
                    lz_chat_data.InputFieldValues[i].Value = null;
                }
            }
        }

        if(lz_chat_data.ParentURI != null)
            fd.append("p_url",lz_global_base64_url_encode(lz_chat_data.ParentURI));
        if(lz_chat_data.InternalUser != null && lz_chat_data.InternalUser.Id != "")
            fd.append("p_requested_intern_userid",lz_global_base64_url_encode(lz_chat_data.InternalUser.Id));
    }

    if(lz_chat_data.Id != '')
        fd.append("p_cid",lz_global_base64_url_encode(lz_chat_data.Id));

    fd.append("p_extern_userid",lz_global_base64_url_encode(lz_chat_data.ExternalUser.Session.UserId));
    fd.append("p_extern_browserid",lz_global_base64_url_encode(lz_chat_data.ExternalUser.Session.BrowserId));
    return fd;
}

function lz_chat_get_post_values(_action, _groups, _params)
{
	var values = "p_request=extern";

    if(lz_chat_data.WaitingLinksShow)
        values += "&p_wls=1";

	if(_action == "listen" || _action == "shout")
	{
		values += "&p_action=listen&p_gl_a="+lz_global_base64_url_encode(lz_chat_data.PollHash)+"&p_gl_acid="+lz_global_base64_url_encode(lz_chat_data.PollAcid);

        if(lz_chat_data.ExternalUser.Username != lz_chat_data.Language.Guest)
            values += "&p_username="+lz_global_base64_url_encode(lz_chat_data.ExternalUser.Username);

        values += "&p_group="+lz_global_base64_url_encode(lz_chat_data.ExternalUser.Group)+"&p_email="+lz_global_base64_url_encode(lz_chat_data.ExternalUser.Email)+"&p_company="+lz_global_base64_url_encode(lz_chat_data.ExternalUser.Company)+"&p_phone="+lz_global_base64_url_encode(lz_chat_data.ExternalUser.Phone)+"&p_question="+lz_global_base64_url_encode(lz_chat_data.ExternalUser.Question);
		values += "&p_acid="+Math.random()+((lz_chat_data.ExternalUser.Typing)?"&p_typ="+lz_global_base64_url_encode(1):"");

		if(lz_chat_get_frame_object('lz_chat_transcript_email') != null)
			values += "&p_tc_email=" + lz_global_base64_url_encode(lz_global_trim(lz_chat_get_frame_object('lz_chat_transcript_email').value));
		if(lz_chat_get_frame_object('lz_chat_send_chat_transcript') != null && '<!--transcript_option_display-->' != 'none' && !lz_chat_get_frame_object('lz_chat_send_chat_transcript').checked)
			values += "&p_tc_declined=1";
		
		if(lz_chat_data.InternalUser != null && lz_chat_data.InternalUser.Id != null)
			values += "&p_requested_intern_userid=" + lz_global_base64_url_encode(lz_chat_data.InternalUser.Id);

		if(lz_chat_data.CallMeBackMode)
			values += "&p_cmb=" + lz_global_base64_url_encode(1);

        for(var i=0;i<lz_chat_data.InputFieldIndices.length;i++)
			if(lz_chat_data.InputFieldValues[i].Value != null && lz_chat_data.InputFieldValues[i].Value.length>0 && lz_chat_data.InputFieldValues[i].Index.toString().length==1)
				values += "&p_cf" + lz_chat_data.InputFieldIndices[i] + "=" + lz_global_base64_url_encode(lz_chat_data.InputFieldValues[i].Value);

		if(lz_chat_data.ComChatVoucherActive != null)
			values += "&p_tid="+lz_global_base64_url_encode(lz_chat_data.ComChatVoucherActive.Id);
			
		if(_action == "shout")
			values += "&p_shout="+lz_global_base64_url_encode(1);
		else if(lz_chat_data.LastConnectionFailed)
			values += "&p_lcf="+lz_global_base64_url_encode(1);
	}
	else if(_action == "logoff")
	{
		values += "&p_action=logoff";
        if(lz_chat_data.ExternalUser.Username != lz_chat_data.Language.Guest)
		    values += "&p_username=" + lz_global_base64_url_encode(lz_chat_data.ExternalUser.Username)+"&p_group="+lz_global_base64_url_encode(lz_chat_data.ExternalUser.Group)+"&p_email="+lz_global_base64_url_encode(lz_chat_data.ExternalUser.Email)+"&p_company="+lz_global_base64_url_encode(lz_chat_data.ExternalUser.Company);
	}
	else if(_action == "reloadgroups")
	{
		values += "&p_action=reloadgroups";
		values += "&p_requested_intern_userid=" + lz_global_base64_url_encode(lz_chat_data.InternalUser.Id);
		values += "&p_tzo=" + lz_global_base64_url_encode(lz_chat_data.TimezoneOffset) + "&p_cd="+ lz_global_base64_url_encode(window.screen.colorDepth);
		values += "&p_resh="+ lz_global_base64_url_encode(screen.height) + "&p_resw="+ lz_global_base64_url_encode(screen.width);
	}
	else if(_action == "send_mail")
	{
		values += "&p_action=mail";
		values += "&p_username=" + lz_global_base64_url_encode(lz_chat_data.ExternalUser.Username) + "&p_group="+lz_global_base64_url_encode(lz_chat_data.ExternalUser.Group)+"&p_email="+lz_global_base64_url_encode(lz_chat_data.ExternalUser.Email)+"&p_company="+lz_global_base64_url_encode(lz_chat_data.ExternalUser.Company)+"&p_question="+lz_global_base64_url_encode(lz_chat_data.ExternalUser.MailText)+"&p_phone="+lz_global_base64_url_encode(lz_chat_data.ExternalUser.Phone);

        if(lz_chat_data.CallMeBackMode)
            values += "&p_cmb=" + lz_global_base64_url_encode(1);

        if(lz_chat_data.ParentURI != null)
            values += "&p_url=" + lz_global_base64_url_encode(lz_chat_data.ParentURI);
        if(lz_chat_data.InternalUser != null && lz_chat_data.InternalUser.Id != "")
            values += "&p_requested_intern_userid=" + lz_global_base64_url_encode(lz_chat_data.InternalUser.Id);

		for(var i=0;i<=13;i++)
			if(lz_chat_data.InputFieldValues[i].Value.toString().length>0 && lz_chat_data.InputFieldValues[i].Index.toString().length==1)
				values += "&p_cf" + lz_chat_data.InputFieldValues[i].Index + "=" + lz_global_base64_url_encode(lz_chat_data.InputFieldValues[i].Value);
	}
	else if(_action == "rate")
	{
		values += "&p_action=rate";
		values += "&p_username=" + lz_global_base64_url_encode(lz_chat_data.ExternalUser.Username) + "&p_group="+lz_global_base64_url_encode(lz_chat_data.ExternalUser.Group)+"&p_email="+lz_global_base64_url_encode(lz_chat_data.ExternalUser.Email)+"&p_company="+lz_global_base64_url_encode(lz_chat_data.ExternalUser.Company)+"&p_requested_intern_userid="+lz_global_base64_url_encode(lz_chat_data.InternalUser.Id);
	}
    else if(_action == "search_kb")
    {
        if(lz_chat_data.KBOnly)
            values += "&p_kbo=1";
        values += "&p_action=search_kb";
        values += "&p_q=" + lz_global_base64_url_encode(_params);
    }
	
	if(lz_chat_data.Id != '')
		values += "&p_cid=" + lz_global_base64_url_encode(lz_chat_data.Id);
		
	values +="&p_extern_userid=" + lz_global_base64_url_encode(lz_chat_data.ExternalUser.Session.UserId) + "&p_extern_browserid=" + lz_global_base64_url_encode(lz_chat_data.ExternalUser.Session.BrowserId);

    if(lz_geo_resolution_needed && lz_chat_data.ExternalUser.Session.GeoResolved.length == 7)
        values += "&geo_lat=" + lz_global_base64_url_encode(lz_global_base64_decode(lz_chat_data.ExternalUser.Session.GeoResolved[0])) + "&geo_long=" + lz_global_base64_url_encode(lz_global_base64_decode(lz_chat_data.ExternalUser.Session.GeoResolved[1])) + "&geo_region=" + lz_global_base64_url_encode(lz_global_base64_decode(lz_chat_data.ExternalUser.Session.GeoResolved[2])) + "&geo_city=" + lz_global_base64_url_encode(lz_global_base64_decode(lz_chat_data.ExternalUser.Session.GeoResolved[3])) + "&geo_tz=" + lz_global_base64_url_encode(lz_global_base64_decode(lz_chat_data.ExternalUser.Session.GeoResolved[4])) + "&geo_ctryiso=" + lz_global_base64_url_encode(lz_global_base64_decode(lz_chat_data.ExternalUser.Session.GeoResolved[5])) + "&geo_isp=" + lz_global_base64_url_encode(lz_global_base64_decode(lz_chat_data.ExternalUser.Session.GeoResolved[6]));
    values += "&geo_rid=" + lz_global_base64_url_encode(lz_chat_data.GeoResolution.Status);
    if(lz_chat_data.GeoResolution.Span > 0)
        values += "&geo_ss=" + lz_global_base64_url_encode(lz_chat_data.GeoResolution.Span);

    return values;
}

function lz_chat_login(_groupId) 
{
	lz_chat_get_frame_object('lz_form_groups').disabled = false;
	
	if(lz_chat_data.InputFieldValues[lz_array_indexOf(lz_chat_data.InputFieldIndices,111)].Active)
		if(lz_chat_data.ExternalUser.Username != lz_chat_data.Language.Guest)
            lz_chat_data.ExternalUser.Username = lz_chat_get_frame_object('').getElementsByName('form_111')[0].value.substr(0,255);

	if(lz_chat_data.InputFieldValues[lz_array_indexOf(lz_chat_data.InputFieldIndices,112)].Active)
		lz_chat_data.ExternalUser.Email = lz_chat_get_frame_object('').getElementsByName('form_112')[0].value.substr(0,255);
		
	if(lz_chat_data.InputFieldValues[lz_array_indexOf(lz_chat_data.InputFieldIndices,113)].Active)
		lz_chat_data.ExternalUser.Company = lz_chat_get_frame_object('').getElementsByName('form_113')[0].value.substr(0,255);
	
	if(lz_chat_data.InputFieldValues[lz_array_indexOf(lz_chat_data.InputFieldIndices,114)].Active)
		lz_chat_data.ExternalUser.Question = lz_chat_get_frame_object('').getElementsByName('form_114')[0].value.substr(0,64000);

	if(lz_chat_data.InputFieldValues[lz_array_indexOf(lz_chat_data.InputFieldIndices,116)].Active || lz_chat_data.CallMeBackMode)
		lz_chat_data.ExternalUser.Phone = lz_chat_get_frame_object('').getElementsByName('form_116')[0].value.substr(0,255);

	lz_chat_set_status(lz_chat_data.STATUS_INIT);
	if(lz_chat_data.ConnectionRunning)
	{
		setTimeout("lz_chat_login('"+_groupId+"');",100);
		return;
	}
	lz_chat_data.ExternalUser.Group=_groupId;
	lz_chat_data.PermittedFrames=1;
	if(lz_chat_data.ExternalUser.Username.length == 0)
		lz_chat_data.ExternalUser.Username = lz_chat_data.Language.Guest;

    for(var i = 0;i < lz_chat_data.InputFieldValues.length;i++)
        lz_chat_data.InputFieldValues[i].SetStatus("lz_chat_frame_lgin.1.0",false);

	lz_chat_check_connection();
	lz_chat_get_frame_object('').lz_login_form.submit();
}

function lz_chat_activate()
{
    lz_chat_data.ChatActive = true;
    lz_chat_get_frame_object('lz_chat_navigation_table').style.display = '';
    lz_chat_get_frame_object('lz_chat_floor').style.display = '';
    lz_chat_get_frame_object('lz_chat_main').style.display = '';
    lz_chat_get_frame_object('lz_chat_call_me_back_info').style.visibility = 'hidden';
    lz_chat_get_frame_object('lz_chat_options').style.display = 'block';
    lz_chat_set_status(lz_chat_data.Status.Status);
    if(lz_chat_data.ComChatVoucherActive != null)
    {
        lz_chat_update_com_chat_data(false);
        lz_chat_switch_com_chat_box(true);
    }
}

function lz_chat_loaded() 
{
	if(lz_chat_data.ComChatVoucherActive != null)
	{
		lz_chat_get_frame_object('lz_chat_com_chat_chat_period_spacer').style.display =
		lz_chat_get_frame_object('lz_chat_com_chat_chat_period_caption').style.display =
		lz_chat_get_frame_object('lz_chat_com_chat_chat_period_value').style.display = (lz_chat_data.ComChatVoucherActive.Expires > 0) ? "" : "none";
		lz_chat_update_com_chat_data(false);
		lz_chat_switch_com_chat_box(true);
	}

    if(lz_chat_data.CurrentApplication=="callback")
    {
        lz_chat_get_frame_object('lz_chat_call_me_back_info').style.visibility = 'visible';
        lz_chat_get_frame_object('lz_chat_options').style.display = 'none';
    }
    else
        lz_chat_activate();

	lz_chat_get_frame_object('lz_chat_transcript_email').value=lz_chat_data.ExternalUser.Email;
	lz_chat_get_frame_object('lz_chat_send_chat_transcript').checked = (lz_chat_data.ExternalUser.Email!='');

    lz_chat_set_host('','','','',false,false,'<!--dynamic_group-->',lz_chat_data.FeedbackPossible);

    if(lz_chat_data.ExternalUser.Question.length > 0 && lz_chat_data.DynamicGroup == '')
		lz_chat_add_system_text(-1,'<b>'+ lz_chat_data.Language.ClientTopic + '</b>:&nbsp;<i>'+lz_global_htmlentities(lz_chat_data.ExternalUser.Question)+'</i>');
    else
        lz_chat_message('',lz_chat_data.ExternalUser.Question);

	lz_chat_listen();

	if(window.opener != null)
	{
		try
		{
			if(typeof(window.opener.lz_tracking_poll_server) != 'undefined')
			{
				setTimeout("window.opener.lz_tracking_poll_server(1099);",5000);
			}
		}
		catch(ex)
		{
		 // domain restriction
		}
	}
}

function lz_chat_listen() 
{	
	if(lz_chat_data.Status.Status > lz_chat_data.STATUS_START && lz_chat_data.Status.Status < lz_chat_data.STATUS_STOPPED)
	{
		if(!lz_chat_data.ConnectionRunning)
			lz_chat_server_request("./server.php",lz_chat_get_post_values("listen",false,true),lz_global_get_long_poll_runtime()*1000,null);
		setTimeout("lz_chat_listen();",lz_chat_data.ChatFrequency * 1000);
	}
}

function lz_chat_reshout()
{	
	lz_chat_data.ShoutRunning = false;
	if(lz_chat_data.ShoutNeeded)
		lz_chat_shout(4);
}

function lz_chat_shout(_call)
{	
	if(lz_chat_data.Status.Status == lz_chat_data.STATUS_ACTIVE)
	{
		if(!lz_chat_data.ShoutRunning)
		{
			lz_chat_data.ShoutRunning = true;
			lz_chat_shout_request("./server.php",lz_chat_get_post_values("shout",false,true),60000);
			lz_chat_data.ShoutNeeded = false;
		}
		else
		{
			lz_chat_data.ShoutNeeded = true;
		}
	}
	else
		lz_chat_data.ShoutNeeded = true;
}

function lz_chat_listen_hash(_hash,_acid)
{
	lz_chat_data.PollHash = _hash;
	lz_chat_data.PollAcid = _acid;
}

function lz_chat_server_request(_url, _post, _timeout, _errorEvent, _progressEvent)
{	
	if(lz_chat_data.ShoutNeeded && !lz_chat_data.ShoutRunning && lz_chat_data.Status.Status == lz_chat_data.STATUS_ACTIVE)
	{
		lz_chat_shout(5);
		return;
	}
    lz_chat_data.ConnectionRunning = true;
    if(lz_chat_data.GetParameters.length > 0)
        _url += "?" + lz_chat_data.GetParameters;

    lz_poll_request	= new lz_connector(_url,_post,_timeout);
	lz_poll_request.OnEndEvent = lz_chat_handle_response;
	if(_errorEvent==null)
	{
		lz_poll_request.OnErrorEvent =
		lz_poll_request.OnTimeoutEvent = lz_chat_handle_connection_error;
	}
	else
	{
		lz_poll_request.OnErrorEvent =
		lz_poll_request.OnTimeoutEvent = _errorEvent;
	}
    if(_progressEvent != null)
        lz_poll_request.OnProgressEvent = _progressEvent;
	lz_poll_request.ConnectAsync();
}

function lz_chat_shout_request(_url, _post, _timeout)
{	
	lz_chat_data.ShoutRunning = true;
	if(lz_chat_data.Status.Status < lz_chat_data.STATUS_STOPPED)
	{
		var counter = 0;
		for(var i in lz_chat_data.ExternalUser.MessagesSent)
		{
			_post += "&p_p" + counter.toString() + "=" + lz_global_base64_url_encode(lz_chat_data.ExternalUser.MessagesSent[i].MessageText) + "&p_i" + (counter).toString() + "=" + lz_global_base64_url_encode(lz_chat_data.ExternalUser.MessagesSent[i].MessageId);
			if(lz_chat_data.ExternalUser.MessagesSent[i].MessageTranslation != '')
			{
				_post += "&p_pt" + counter.toString() + "=" + lz_global_base64_url_encode(lz_chat_data.ExternalUser.MessagesSent[i].MessageTranslation);
				_post += "&p_ptiso" + counter.toString() + "=" + lz_global_base64_url_encode(lz_chat_get_frame_object('lz_chat_translation_target_language').options[lz_chat_get_frame_object('lz_chat_translation_target_language').selectedIndex].value);
			}
			counter++;
		}
		counter = 0;
		for(var i in lz_chat_data.ExternalUser.MessagesReceived)
			if(!lz_chat_data.ExternalUser.MessagesReceived[i].Received)
				_post += "&pr_i" + (counter++).toString() + "=" + lz_global_base64_url_encode(lz_chat_data.ExternalUser.MessagesReceived[i].MessageId);
	}
	
	if(lz_chat_data.GetParameters.length > 0)
		_url += "?" + lz_chat_data.GetParameters;

	lz_shout_request = new lz_connector(_url,_post,_timeout);
	lz_shout_request.OnEndEvent = lz_chat_handle_shout_response;
	lz_shout_request.OnErrorEvent =
	lz_shout_request.OnTimeoutEvent = lz_chat_handle_connection_error;
	lz_shout_request.ConnectAsync();
}

function lz_chat_check_connection()
{
	if(lz_chat_data.LastConnection < (lz_global_timestamp() - lz_chat_data.PollTimeout) && lz_chat_data.Status.Status < lz_chat_data.STATUS_STOPPED)
	{
		if(!lz_chat_data.ConnectionBroken)
			lz_chat_add_system_text(-1,lz_chat_data.Language.ConnectionBroken);
		lz_chat_data.ConnectionBroken = true;
	}
	else
		lz_chat_data.ConnectionBroken = false;

	setTimeout("lz_chat_check_connection();",5000);
}

function lz_chat_set_config(_timeout,_frequency)
{
	lz_chat_data.PollTimeout = _timeout;
	lz_chat_data.ChatFrequency = _frequency;
}

function lz_chat_stop_system()
{
	window.status = "";
	if(lz_chat_data.Status.Status > lz_chat_data.STATUS_INIT && lz_chat_data.Status.Status < lz_chat_data.STATUS_STOPPED)
	{
		lz_chat_get_frame_object('lz_chat_translation_target_language').disabled =
		lz_chat_get_frame_object('lz_translation_service_active').disabled =
		lz_chat_get_frame_object('lz_chat_transcript_email').disabled =
		lz_chat_get_frame_object('lz_chat_send_chat_transcript').disabled =
		lz_chat_get_frame_object('lz_chat_text').disabled = 
		lz_chat_get_frame_object('lz_chat_submit').disabled = true;
		lz_chat_set_host('','','','',false,false,'',lz_chat_data.FeedbackPossible);
	}
	lz_chat_set_status(lz_chat_data.STATUS_STOPPED);
	lz_chat_set_intern_image(0,'',false);

    if(!lz_chat_data.ChatActive)
        lz_chat_activate();

}


function lz_chat_play_sound(_result)
{
    if(lz_chat_data.SoundsAvailable)
    {
        if(_result && lz_chat_data.SoundPlayerResult != null)
            lz_chat_data.SoundPlayerResult.play();
        else if(lz_chat_data.SoundPlayerMessage != null)
            lz_chat_data.SoundPlayerMessage.play();
    }
}

function lz_chat_switch_sound()
{
	lz_chat_data.SoundsAvailable = !lz_chat_data.SoundsAvailable;
	if(lz_chat_data.SoundsAvailable)
		lz_chat_get_frame_object('lz_chat_sound_button').src = "./images/button_s1.gif";
	else
		lz_chat_get_frame_object('lz_chat_sound_button').src = "./images/button_s0.gif";
}

function lz_chat_detect_sound()
{
    try
    {
        var sa = document.createElement('audio');
        var avail_ogg = sa.canPlayType('audio/ogg;');
        var avail_mp3 = sa.canPlayType('audio/mpeg;');
        lz_chat_data.SoundsAvailable = (avail_ogg || avail_mp3);
        if(lz_chat_data.SoundsAvailable)
        {
            lz_chat_data.SoundPlayerMessage = new Audio((!avail_ogg) ? "./sound/message.mp3" : "./sound/message.ogg");
            lz_chat_data.SoundPlayerResult = new Audio((!avail_ogg) ? "./sound/wind.mp3" : "./sound/wind.ogg");
        }
    }
    catch(ex)
    {

    }
}

function lz_chat_set_group(_group)
{
	lz_chat_data.ExternalUser.Group = lz_global_base64_decode(_group);
}

function lz_chat_set_groups(_chatPossible, _groups, _errors, _selected)
{
    try
    {
        lz_chat_data.Groups.Update(_groups);
        if(_errors.length > 0)
        {
            lz_chat_data.SetupError = _errors;
            lz_chat_dialog(_errors,null,-1,null,null,true);
        }
        else
        {
            lz_chat_data.ChatGroupAvailable = _chatPossible;
            if(lz_chat_data.PreselectTicket)
                lz_chat_tab_set_active("ticket",false);
            else if(lz_chat_data.PreselectCallback)
                lz_chat_tab_set_active("callback",false);
            else if(!lz_chat_data.ChatGroupAvailable && lz_chat_data.CurrentApplication == "chat")
                lz_chat_tab_set_active("ticket",false);
            else if(lz_chat_data.CurrentApplication != "")
                lz_chat_tab_set_active(lz_chat_data.CurrentApplication,false);
            lz_chat_init_reload_groups();

            if(lz_chat_data.PreselectKnowledgebase)
            {
                lz_chat_tab_set_active("knowledgebase",false);
                lz_chat_get_frame_object('lz_chat_kb_input').value = lz_chat_get_input_value(114);
                lz_chat_init_search_kb(false,false);
            }

        }
    }
    catch(ex)
    {
        if(lz_chat_data.Debug)
            alert(ex);
    }
}

function lz_chat_init_reload_groups()
{
    if(lz_chat_data.TimerReloadGroups != null)
        clearTimeout(lz_chat_data.TimerReloadGroups);
    lz_chat_data.TimerReloadGroups = setTimeout("lz_chat_reload_groups();",(<!--extern_timeout-->*1000)-10000);
}


function lz_chat_pre_change_group(_box)
{
    lz_chat_data.ForceSelectInit=true;
}

function lz_chat_change_group(_box,_userActivity)
{
    if(lz_chat_data.ForceGroupSelect && !lz_chat_data.ForceSelectMade && _box.selectedIndex == _box.childNodes.length-1)
        return;

    if(lz_chat_data.ForceGroupSelect && lz_chat_data.ForceSelectInit && !lz_chat_data.ForceSelectMade)
    {
        lz_chat_data.ForceSelectMade=true;
        _box.removeChild(lz_chat_data.Groups.ForceSelectOption);
        lz_chat_set_input_fields(lz_chat_data.SelectedGroup,lz_chat_get_frame_object(''));
    }

    var last = (lz_chat_data.SelectedGroup != null) ? lz_chat_data.SelectedGroup.Id+lz_chat_data.SelectedGroup.Amount : "";
	lz_chat_data.SelectedGroup = (lz_chat_get_frame_object('') != null) ? lz_chat_data.Groups.GetGroupById(_box.value) : null;
	if(lz_chat_data.SelectedGroup == null)
	{
		var position = _box.selectedIndex;
		var reset = false;

		while(lz_chat_data.SelectedGroup == null)
		{
			position++;
			if(position == _box.childNodes.length)
				if(!reset)
				{
					position = 0;
					reset=true;
				}
				else
					break;
            if(_box.childNodes.length>0)
			    lz_chat_data.SelectedGroup = lz_chat_data.Groups.GetGroupById(_box.childNodes[position].value);
            else
                break;
		}
	}

    var current = (lz_chat_data.SelectedGroup != null) ? lz_chat_data.SelectedGroup.Id+lz_chat_data.SelectedGroup.Amount : "";

	if(lz_chat_data.SelectedGroup != null)
	{
		if(_box.length > position)
 			_box.selectedIndex = position;

        if(last != current)
            lz_chat_tab_set_active(lz_chat_data.CurrentApplication,_userActivity);
        _box.style.color = _box.childNodes[_box.selectedIndex].style.color;
        _box.style.background = _box.childNodes[_box.selectedIndex].style.background;

    }
    lz_chat_update_group_icon();
}

function lz_chat_update_group_icon()
{
    lz_chat_get_frame_object('lz_chat_group_status').className = (lz_chat_data.SelectedGroup != null && lz_chat_data.SelectedGroup.Amount > 0 && lz_chat_data.CurrentApplication != "ticket") ? "lz_chat_input_icon lz_chat_input_icon_online" : "lz_chat_input_icon lz_chat_input_icon_offline";
}

function lz_chat_set_input_fields(_selGroup,_document)
{
	if(lz_chat_data.InputFieldIndices != null)
	{
        var isChat = (lz_chat_data.CurrentApplication!="ticket" && _selGroup.Amount > 0);
		var ihidden = (isChat) ? _selGroup.ChatInputsHidden : _selGroup.TicketInputsHidden;
		var imandatory = (isChat) ? _selGroup.ChatInputsMandatory : _selGroup.TicketInputsMandatory;
		var mandatoryFields = (lz_chat_data.CurrentApplication!="ticket" && _selGroup.ChatVouchersRequired.length > 0);
		var isComChat = mandatoryFields && _selGroup.Amount > 0;
        var isPlaceholderSupport = lz_is_placeholder_support();

		for(var i = 0;i < lz_chat_data.InputFieldIndices.length;i++)
		{
			var findex = lz_chat_data.InputFieldIndices[i];

			if(_document.getElementById("lz_form_active_" + findex).value == "true" || (findex==116 && lz_chat_data.CallMeBackMode))
			{
				_document.getElementById("lz_form_" + findex).className = (findex==115 && isComChat) ? "lz_input lz_input_com" : "lz_input";
				_document.getElementById("lz_form_" + findex).className = (findex==116 && lz_chat_data.CallMeBackMode) ? "lz_input lz_input_com" : _document.getElementById("lz_form_" + findex).className;

                var hideInput = ((lz_array_indexOf(ihidden,findex) > -1) || (lz_chat_data.ForceGroupSelect && !lz_chat_data.ForceSelectMade && lz_chat_data.InputFieldValues[i].IsHiddenGeneral(lz_chat_data.Groups.Groups,isChat)) || (findex==114 && isChat && lz_chat_data.IsPublicGroupChat));

                _document.getElementById("lz_form_" + findex).style.display = (hideInput) ? "none" : "";
				_document.getElementById("lz_form_" + findex).style.display = (findex==115) ? ((isComChat) ? "" : "none") : _document.getElementById("lz_form_" + findex).style.display;
				_document.getElementById("lz_form_" + findex).style.display = (findex==116 && lz_chat_data.CallMeBackMode) ? "" : _document.getElementById("lz_form_" + findex).style.display;
                _document.getElementById("lz_form_" + findex).style.display = (lz_chat_data.InputFieldValues[i].Type == "File" && lz_chat_data.CurrentApplication=="chat") ? "none" : _document.getElementById("lz_form_" + findex).style.display;


                if(_document.getElementById("lz_form_info_" + findex).innerHTML.length > 0)
                {
                    _document.getElementById("lz_form_mandatory_" + findex).className = "lz_input_icon lz_info";
                    _document.getElementById("lz_form_mandatory_" + findex).style.display = "";
                    _document.getElementById("lz_form_mandatory_" + findex).onclick = new Function("lz_chat_show_info_box('"+findex.toString()+"',true);");

                    if(!lz_chat_data.IsMobile)
                    {
                        _document.getElementById("lz_form_mandatory_" + findex).onmouseover = new Function("lz_chat_show_info_box('"+findex.toString()+"',true);");
                        _document.getElementById("lz_form_mandatory_" + findex).onmouseout = new Function("lz_chat_show_info_box('"+findex.toString()+"',false);");
                    }
                    _document.getElementById("lz_form_info_" + findex).onclick = new Function("lz_chat_show_info_box('"+findex.toString()+"',false);");
                }
                else
                    _document.getElementById("lz_form_mandatory_" + findex).style.display = "none";
				
				if(lz_array_indexOf(imandatory,findex) != -1 || (lz_chat_data.InputFieldValues[i].Validation && lz_array_indexOf(ihidden,findex) == -1))
					mandatoryFields = true;

                if(!isPlaceholderSupport && (lz_chat_data.InputFieldValues[i].Type == "Text" || lz_chat_data.InputFieldValues[i].Type == "TextArea"))
                {
                    if(_document.getElementsByName("form_" + findex)[0].value=='')
                    {
                        _document.getElementsByName("form_" + findex)[0].value = _document.getElementById("lz_form_ph_" + findex).value;
                        _document.getElementsByName("form_" + findex)[0].style.color = '#BBB';
                    }
                    _document.getElementsByName("form_" + findex)[0].onfocus=new Function("if (this.value == '"+_document.getElementById("lz_form_ph_" + findex).value+"') {this.value = ''; this.style.color='#333'}");
                    _document.getElementsByName("form_" + findex)[0].onblur=new Function("if (this.value == '') {this.value = '"+_document.getElementById("lz_form_ph_" + findex).value+"'; this.style.color='#BBB'}");
                }




			}
			else
				_document.getElementById("lz_form_" + findex).style.display = 'none';
		}
        lz_chat_get_frame_object('buy_voucher_button').style.display = (lz_chat_data.SelectedGroup.ChatVouchersRequired.length > 0 && _selGroup.Amount > 0 && lz_chat_data.CurrentApplication != "ticket") ? '' : 'none';
    }
}

function lz_chat_show_info_box(_id,_active)
{
    lz_chat_get_frame_object('lz_form_info_' + _id).style.display = (lz_chat_get_frame_object('lz_form_info_' + _id).style.display!='block') ? 'block' : 'none';
    lz_chat_show_header();
}

function lz_chat_validate_group(_chat)
{
	var group = lz_chat_data.Groups.GetGroupById(lz_chat_get_frame_object('lz_form_groups').value);
	if(group == null)
	{
		lz_chat_dialog(lz_chat_data.Language.SelectValidGroup,null,null,null,null);
		return false;	
	}
    lz_chat_data.SelectedGroup = group;
    if(_chat && lz_chat_data.SelectedGroup.Amount == 0)
    {
        if(<!--function_ticket-->)
            lz_chat_dialog(lz_chat_data.Language.ChatNotAvailable,null,new Function("lz_chat_tab_set_active('ticket',true);"),lz_chat_data.Language.LanguageLeaveMessageShort,null,true);
        else
            lz_chat_dialog(lz_chat_data.Language.ChatNotAvailable,null,null,lz_chat_data.Language.LanguageClose,null,true);
        return false;
    }
	return true;
}

function lz_chat_bookmark()
{
	var title = '<!--bookmark_name-->';
	if(window.chrome)
		alert('Your browser does not support this function.');
	else if(window.sidebar) 
		window.sidebar.addPanel(lz_global_base64_decode(title),self.location.href,"");
	else if(window.external)
		window.external.AddFavorite(self.location.href,lz_global_base64_decode(title));
}  

function lz_chat_goto_message(_inChat,_send)
{
	if(<!--offline_message_mode--> == 1)
	{
        lz_chat_alternative_ticket_page();
		return false;
	}
	if(lz_chat_data.SetupError.length > 0)
	{
		lz_chat_dialog("<!--lang_client_error_unavailable-->",lz_chat_get_frame_object(''));
		return false;
	}
    if(_inChat)
    {
        lz_chat_stop_system();
        lz_chat_config_reset();
        lz_chat_data.PermittedFrames = 1;
        lz_chat_data.CurrentApplication = "ticket";
        lz_chat_data.WindowNavigating = true;
        lz_chat_data.DirectLogin = false;
        lz_chat_data.PreselectCallback = false;
        document.getElementById("lz_chat_content").src = './chat.php?template=lz_chat_frame_lgin&' + lz_chat_data.GetParameters;
        return false;
    }
    return true;
}

function lz_chat_config_reset()
{
    if(lz_chat_data.InternalUser != null)
        lz_chat_data.InternalUser.Id = "";

    lz_switch_title_mode(false);

    lz_chat_data.LastSender = -2;
    lz_chat_data.LastSound = 0;
    lz_chat_data.QueuePostsAdded = false;
    lz_chat_data.AlternateRow = true;
    lz_chat_data.Groups = null;
    lz_chat_data.Status.Loaded = false;

    if(lz_chat_data.TimerWaiting != null)
    {
        clearTimeout(lz_chat_data.TimerWaiting);
        lz_chat_data.TimerWaiting = null;
    }

    lz_chat_data.TimerReloadGroups = null;
    lz_chat_data.QueueMessageAppended = false;
    lz_chat_data.ConnectedMessageAppended = false;
    lz_chat_data.WaitingMessageAppended = false;
    lz_chat_data.Status.Status = lz_chat_data.STATUS_START;

}

function lz_chat_alternative_ticket_page()
{
    try
    {
        lz_chat_get_frame_object('lz_chat_login').style.display='none';
        lz_chat_get_frame_object('lz_form_details').style.display='none';
        lz_chat_get_frame_object('lz_chat_loading').style.display='';
    }
    catch(e)
    {

    }
    lz_chat_change_url('<!--offline_message_http-->',!<!--offline_message_pop-->);
    window.resizeTo(screen.width,screen.height);
    window.screenX = 0;
    window.screenY = 0;
}

function lz_load_input_values(_frame)
{
	for(var i = 0;i< lz_chat_data.InputFieldIndices.length;i++)
	{
		var findex = lz_chat_data.InputFieldIndices[i];
		if(lz_chat_get_frame_object('').getElementById("lz_form_" + findex) != null)
		{
            if(lz_chat_data.InputFieldValues[i].Type == "File")
                continue;
			if(lz_chat_get_frame_object('').getElementsByName("form_" + findex)[0].tagName.toUpperCase() == "SELECT")
				lz_chat_get_frame_object('').getElementsByName("form_" + findex)[0].selectedIndex = parseInt(lz_chat_data.InputFieldValues[i].Value);
			else if(lz_chat_get_frame_object('').getElementsByName("form_" + findex)[0].type.toUpperCase() == "CHECKBOX")
			{
				if(lz_chat_get_frame_object('').getElementsByName("form_" + findex)[0].value=="")
					lz_chat_get_frame_object('').getElementsByName("form_" + findex)[0].value = lz_chat_data.InputFieldValues[i].Value;
				lz_chat_get_frame_object('').getElementsByName("form_" + findex)[0].checked = (parseInt(lz_chat_data.InputFieldValues[i].Value)==1);
			}
			else
			{
				if(lz_chat_get_frame_object('').getElementsByName("form_" + findex)[0].value=="")
					lz_chat_get_frame_object('').getElementsByName("form_" + findex)[0].value = lz_global_trim(lz_chat_data.InputFieldValues[i].Value);
			}
		}
	}
}

function lz_chat_show_setup_error(_setupError)
{
    lz_chat_dialog(_setupError,null,-1,null,null,true);
}

function lz_chat_release(_chatPossible, _setupError)
{
    if(lz_chat_data.Status.Loaded)
        return;
    if((!_chatPossible || !<!--function_chat-->) && <!--offline_message_mode--> > 0)
        return;
    lz_chat_data.ChatGroupAvailable = _chatPossible;

	if(_setupError.length != 0)
	{
        lz_chat_get_frame_object('lz_chat_loading').style.display = "none";
        lz_chat_show_setup_error(_setupError);
		return;
	}
	else
	{
        lz_chat_show_header();
        lz_chat_get_frame_object('lz_tab_callback').style.display = (<!--function_callback-->) ? "" : "none";
        lz_chat_get_frame_object('lz_tab_chat').style.display = (<!--function_chat-->) ? "" : "none";
        lz_chat_get_frame_object('lz_tab_ticket').style.display = (<!--function_ticket-->) ? "" : "none";
        lz_chat_get_frame_object('lz_tab_knowledgebase').style.display = (<!--function_knowledgebase-->) ? "" : "none";
		lz_load_input_values('lz_chat_frame_lgin.1.0');
		lz_chat_set_status(lz_chat_data.STATUS_START);
		var reload = lz_chat_data.Status.Loaded;
		lz_chat_data.Status.Loaded = true;

        if(lz_chat_data.ExternalUser.Session.BDA == 1)
            lz_chat_data.DirectLogin = false;
        if(lz_chat_data.PreselectKnowledgebase || lz_chat_data.PreselectTicket)
            lz_chat_data.DirectLogin = false;

        lz_chat_data.ExternalUser.Session.BDA=1;
        lz_chat_data.ExternalUser.Session.Save();

		if(lz_chat_data.DirectLogin)
		{
            if(!_chatPossible && lz_chat_data.PreselectCallback && lz_chat_data.CurrentApplication == "callback")
            {
                setTimeout("lz_chat_validate_ticket_inputs(false);",100);
            }
            else if(_chatPossible && lz_chat_validate_group(true) && lz_check_missing_inputs(true,false,'lz_chat_check_login_inputs'))
            {
                lz_chat_login(lz_chat_data.Groups.GetGroupById(lz_chat_get_frame_object('lz_form_groups').value).Id);
                return;
            }
		}

        lz_chat_get_frame_object('lz_chat_loading').style.display = "none";

        if(!lz_chat_data.KBOnly)
		{
			lz_chat_get_frame_object('lz_chat_login').style.visibility = 'visible';
            lz_chat_get_frame_object('lz_chat_navigation').style.display = 'block';
			lz_chat_get_frame_object('lz_action_button').disabled = false;
		}
	}
	if(!lz_chat_data.ValidationRequired)
		lz_chat_get_frame_object('lz_form_details').style.display = '';
	if(lz_chat_data.CheckoutExtendSuccess)
		lz_chat_buy_voucher_navigate('voucher_extend_success');
	else if(lz_chat_data.CheckoutOnly)
		lz_chat_buy_voucher_navigate('voucher_select');
    lz_chat_init_search_kb("%ALL%");
}

function lz_check_missing_inputs(_display,_alert,_contFunc)
{
	if(lz_chat_data.Id.length > 0)
		return true;

	var missingInput = false;
	var imandatory = (lz_chat_data.CurrentApplication=="chat") ? lz_chat_data.SelectedGroup.ChatInputsMandatory : lz_chat_data.SelectedGroup.TicketInputsMandatory;
	var ihidden = (lz_chat_data.CurrentApplication=="chat") ? lz_chat_data.SelectedGroup.ChatInputsHidden : lz_chat_data.SelectedGroup.TicketInputsHidden;
    var isPlaceholderSupport = lz_is_placeholder_support();

	for(var i = 0;i < lz_chat_data.InputFieldIndices.length;i++)
	{
		var findex = lz_chat_data.InputFieldIndices[i];

        if( lz_chat_data.IsPublicGroupChat && lz_chat_data.CurrentApplication=="chat" && findex == 114)
        {

        }
		else if(lz_chat_data.InputFieldValues[i].Active || (findex == 116 && lz_chat_data.CallMeBackMode))
		{
            var isFilled = (lz_chat_data.InputFieldValues[i].Type == "CheckBox") ? lz_chat_get_frame_object('').getElementsByName("form_" + findex)[0].checked : lz_global_trim(lz_chat_get_frame_object('').getElementsByName("form_" + findex)[0].value).length > 0;

            if(!isPlaceholderSupport && isFilled && lz_chat_data.InputFieldValues[i].Type != "CheckBox" && lz_global_trim(lz_chat_get_frame_object('').getElementsByName("form_" + findex)[0].value) == lz_chat_get_frame_object("lz_form_ph_" + findex).value)
                isFilled = false;

            if((((findex == 115 && lz_chat_data.SelectedGroup.ChatVouchersRequired.length > 0 && lz_chat_data.CurrentApplication=="chat") || (lz_array_indexOf(ihidden,findex) == -1 && (lz_array_indexOf(imandatory,findex) != -1 || lz_chat_data.InputFieldValues[i].Validation))) || (findex == 116 && lz_chat_data.CallMeBackMode)) && !isFilled)
			{
				if(_display)
                {
                    lz_chat_get_frame_object("lz_form_mandatory_" + findex).className = "lz_input_icon lz_required";
                    lz_chat_get_frame_object("lz_form_mandatory_" + findex).style.display = "";
                }
				missingInput = true;
			}
			else
            {
			    if(lz_chat_get_frame_object("lz_form_info_" + findex).innerHTML.length > 0)
                {
                    lz_chat_get_frame_object("lz_form_mandatory_" + findex).className = "lz_input_icon lz_info";
                    lz_chat_get_frame_object("lz_form_mandatory_" + findex).style.display = "";
                }
                else
                    lz_chat_get_frame_object("lz_form_mandatory_" + findex).style.display = "none";
            }
		}
	}

    lz_chat_get_frame_object("lz_form_mandatory").style.display = (missingInput) ? '' : 'none';
	if(missingInput)
	{
		if(lz_chat_data.CurrentApplication!="chat")
		{
			lz_chat_get_frame_object('lz_chat_loading').style.display='none';
			lz_chat_get_frame_object('lz_form_details').style.display='';
		}
		if(_alert)
			lz_chat_dialog(lz_chat_data.Language.FillMandatoryFields,null,null,null,null,true);
		return false;
	}
	else
		return lz_validate_inputs(_contFunc,ihidden);
}

function lz_validate_inputs(_contFunc,_hidden)
{
	lz_chat_data.ValidationRequired = false;
	for(var i = 0;i < lz_chat_data.InputFieldValues.length;i++)
	{
		lz_chat_data.InputFieldValues[i].SetStatus(true,false);
	}

	for(var i = 0;i < lz_chat_data.InputFieldValues.length;i++)
	{
        if( lz_chat_data.IsPublicGroupChat && lz_chat_data.CurrentApplication=="chat" && lz_chat_data.InputFieldValues[i].Index == 114)
        {

        }
		else if(lz_chat_data.InputFieldValues[i].Active && lz_chat_data.InputFieldValues[i].Validation && !lz_chat_data.InputFieldValues[i].Validated && lz_array_indexOf(_hidden,lz_chat_data.InputFieldIndices[i]) == -1)
		{
			lz_chat_data.ValidationRequired = true;
			lz_chat_data.InputFieldValues[i].ValidationResult = null;
			lz_chat_get_frame_object('lz_action_button').style.cursor =
			lz_chat_get_frame_object('').body.style.cursor='wait';
			lz_chat_get_frame_object('lz_action_button').disabled = true;
			lz_chat_get_frame_object('lz_form_groups').disabled = true;
			lz_chat_data.InputFieldValues[i].Validate(_contFunc);
			return false;
		}
		else if((lz_chat_data.CurrentApplication=="chat" || lz_chat_data.CurrentApplication=="callback") && lz_chat_data.ComChatInput == null && lz_chat_data.InputFieldValues[i].Index == 115 && lz_chat_data.SelectedGroup.ChatVouchersRequired.length > 0)
		{
			var einput = lz_chat_data.InputFieldValues[i];
			lz_chat_data.ComChatInput = new lz_chat_input(115,true,einput.Caption,einput.InfoText,einput.Name,einput.Type,lz_global_base64_encode(einput.Value),true,lz_global_base64_encode("<!--server-->validate.php?value=<!--value--><!--website-->&intgroup=" + lz_chat_data.SelectedGroup.Id),5,false);
			lz_chat_data.ValidationRequired = true;
			lz_chat_data.ComChatInput.Validated = einput.Validated;
			lz_chat_data.ComChatInput.Caption = einput.Caption;
			lz_chat_data.ComChatInput.ValidationResult = null;
			lz_chat_get_frame_object('lz_action_button').style.cursor =
			lz_chat_get_frame_object('').body.style.cursor='wait';
			lz_chat_get_frame_object('lz_action_button').disabled = true;
			lz_chat_get_frame_object('lz_form_groups').disabled = true;
			lz_chat_data.ComChatInput.Validate(_contFunc);
			return false;
		}
	}
	return true;
}

function lz_validate_com_chat_input_result(_result,_inuse,_reason,_voucherid,_chatTime,_chatTimeMax,_chatSessions,_chatSessionsMax,_expires,_expired)
{
	if(!_result)
	{
		lz_chat_data.ComChatVoucherActive = null;
		if(_inuse)
			lz_chat_dialog(lz_chat_data.Language.ClientVoucherInUse,null,null,null,null,true);
		else if(_reason==0)
			lz_chat_dialog(lz_chat_data.Language.ClientInvalidComChatAccount,null,null,null,null,true);
		else
			lz_chat_dialog(lz_chat_data.Language.ClientEmptyComChatAccount,null,null,null,null,true);
	}
	else
	{
		lz_chat_data.ComChatVoucherActive = new lz_chat_com_chat_ticket();
		lz_chat_data.ComChatVoucherActive.Id = _voucherid;
		lz_chat_data.ComChatVoucherActive.ChatTime = _chatTime;
		lz_chat_data.ComChatVoucherActive.ChatTimeMax = _chatTimeMax;
		lz_chat_data.ComChatVoucherActive.ChatSessions = _chatSessions;
		lz_chat_data.ComChatVoucherActive.ChatSessionsMax = _chatSessionsMax;
		lz_chat_data.ComChatVoucherActive.Expires = _expires;
    	lz_chat_data.ComChatVoucherActive.Expired = _expired;
	}
	lz_validate_input_result(_result,115);
}

function lz_chat_add_update_vouchers_init(_changeHTML)
{
	lz_chat_data.ComChatVouchers = new Array();
	lz_chat_data.ComChatVoucherChangeHTML = lz_global_base64_decode(_changeHTML);
	lz_chat_get_frame_object('lz_chat_com_chat_change_voucher').style.display = (lz_chat_data.ComChatVoucherChangeHTML.length > 0) ? "" : "none";
}

function lz_chat_add_available_voucher(_id,_chatTime,_chatTimeMax,_chatSessions,_chatSessionsMax,_expires,_expired)
{
	var voucher = new lz_chat_com_chat_ticket();
	voucher.Id = _id;
	voucher.ChatTime = _chatTime;
	voucher.ChatTimeMax = _chatTimeMax;
	voucher.ChatSessions = _chatSessions;
	voucher.ChatSessionsMax = _chatSessionsMax;
	voucher.Expires = _expires;
	voucher.Expired = _expired;
	lz_chat_data.ComChatVouchers.push(voucher);
	if(_id == lz_chat_data.ComChatVoucherActive.Id)
		lz_chat_data.ComChatVoucherActive = voucher;
	lz_chat_get_frame_object('lz_chat_com_chat_change_voucher').style.display = (lz_chat_data.ComChatVouchers.length >= 2) ? "" : "none";
}

function lz_chat_extend_voucher()
{
	void(window.open('<!--server-->chat.php?intgroup='+lz_global_base64_url_encode(lz_chat_data.ExternalUser.Group)+'<!--website-->&co='+lz_global_base64_url_encode(lz_chat_data.ComChatVoucherActive.Id),'','width=<!--window_width-->,height=<!--window_height-->,left=0,top=0,resizable=yes,menubar=no,location=no,status=yes,scrollbars=yes'));
}

function lz_validate_input_result(_result,_id)
{
	for(var i = 0;i < lz_chat_data.InputFieldValues.length;i++)
    	lz_chat_data.InputFieldValues[i].SetStatus("lz_chat_frame_lgin.1.0",true);
	var failed = false;
	for(var i = 0;i < lz_chat_data.InputFieldValues.length;i++)
	{
		if(lz_chat_data.InputFieldValues[i].Index != _id || lz_chat_data.InputFieldValues[i].Validated)
			continue;
		if(lz_chat_data.InputFieldValues[i].ValidationResult != null)
			continue;
			
		var cinput = lz_chat_data.InputFieldValues[i];
		if((lz_chat_data.CurrentApplication=="chat" || lz_chat_data.CurrentApplication=="callback") && _id == 115 && lz_chat_data.SelectedGroup.ChatVouchersRequired.length > 0)
			cinput = lz_chat_data.ComChatInput

		cinput.Validated = true;
		cinput.ValidationResult = _result;
		clearTimeout(cinput.ValidationTimeoutObject);
		if(_result === false)
			failed = true;
		else if(_result === -1)
		{
			if(cinput.ValidationContinueOnTimeout)
			{
				cinput.ValidationResult = true;
				lz_chat_get_frame_object('').body.style.cursor='default';
				eval(cinput.ValidationContinueAt);
				return;
			}
			else
				failed = true;
		}
		else if(_result === true)
		{
			lz_chat_get_frame_object('').body.style.cursor='default';
			eval(cinput.ValidationContinueAt);
			return;
		}

		if(failed)
		{
			if(lz_chat_data.CurrentApplication!="chat")
				lz_chat_get_frame_object('').getElementById('lz_chat_loading').style.display='none';
			lz_chat_get_frame_object('').getElementById('lz_form_details').style.display='';
			lz_chat_get_frame_object('lz_action_button').disabled = false;
			lz_chat_get_frame_object('').getElementById("lz_form_mandatory_" + cinput.Index).style.display = "";
            lz_chat_get_frame_object('lz_action_button').style.cursor =
			lz_chat_get_frame_object('').body.style.cursor='default';
			lz_chat_get_frame_object('lz_form_groups').disabled = false;
			if(cinput != lz_chat_data.ComChatInput)
				lz_chat_dialog(lz_chat_data.Language.ClientInvalidData + "<br><br>" + cinput.Caption.replace(":","") + "<br><br>" + cinput.InfoText,null,null,null,null,true);
			cinput.Validated = false;
			for(var x=0;x< lz_chat_data.InputFieldValues.length;x++)
				lz_chat_data.InputFieldValues[x].Validated = false;
			if(cinput.Index == 115)
				lz_chat_data.ComChatInput = null;
			return;
		}
	}
}

function lz_chat_check_login_inputs()
{
	if(!lz_chat_validate_group(true))
		return;
	if(!lz_check_missing_inputs(true,true,'lz_chat_check_login_inputs'))
		return;
	lz_chat_login(lz_chat_data.SelectedGroup.Id);
}

function lz_chat_validate_ticket_inputs(_noAlert)
{
    if(!lz_chat_validate_group(false))
        return;
	if(!lz_check_missing_inputs(true,_noAlert !== false,'lz_chat_validate_ticket_inputs'))
		return;
	if(lz_chat_data.InputFieldValues[lz_array_indexOf(lz_chat_data.InputFieldIndices,111)].Active)
        lz_chat_data.ExternalUser.Username = lz_chat_get_frame_object('').getElementsByName("form_111")[0].value.substr(0,255);
	if(lz_chat_data.InputFieldValues[lz_array_indexOf(lz_chat_data.InputFieldIndices,112)].Active)
		lz_chat_data.ExternalUser.Email = lz_chat_get_frame_object('').getElementsByName("form_112")[0].value.substr(0,255);
	if(lz_chat_data.InputFieldValues[lz_array_indexOf(lz_chat_data.InputFieldIndices,113)].Active)
		lz_chat_data.ExternalUser.Company = lz_chat_get_frame_object('').getElementsByName("form_113")[0].value.substr(0,255);
	if(lz_chat_data.InputFieldValues[lz_array_indexOf(lz_chat_data.InputFieldIndices,114)].Active)
		lz_chat_data.ExternalUser.MailText = lz_chat_get_frame_object('').getElementsByName("form_114")[0].value.substr(0,64000);
    if(lz_chat_data.InputFieldValues[lz_array_indexOf(lz_chat_data.InputFieldIndices,116)].Active || lz_chat_data.CallMeBackMode)
		lz_chat_data.ExternalUser.Phone = lz_chat_get_frame_object('').getElementsByName('form_116')[0].value.substr(0,255);
	lz_chat_data.ExternalUser.Group = lz_chat_get_frame_object('lz_form_groups').value;
	lz_chat_send_ticket();
}

function lz_chat_is_file_upload()
{
    try
    {
        var test = new FormData();
    }
    catch(e)
    {
        return false
    }

    for(var i = 0;i< lz_chat_data.InputFieldIndices.length;i++)
    {
        var findex = lz_chat_data.InputFieldIndices[i];
        if(lz_chat_get_frame_object('').getElementById("lz_form_" + findex) != null)
            if(!lz_chat_input_is_hidden(findex) && lz_chat_get_frame_object('').getElementsByName("form_" + findex)[0].tagName.toUpperCase() == "INPUT" && lz_chat_get_frame_object('').getElementsByName("form_" + findex)[0].type.toUpperCase() == "FILE")
                return true;
    }

    return false;
}

function lz_chat_input_is_hidden(_findex)
{
    if(lz_chat_get_frame_object("lz_form_" + _findex).style.display == "none")
        return true;
    return false;
}

var doReset = false;

function lz_chat_send_ticket()
{
	lz_chat_get_frame_object('lz_action_button').disabled=true;
	lz_chat_get_frame_object('lz_action_button').style.cursor='wait';
    if(lz_chat_is_file_upload())
        lz_chat_server_request("./server.php",lz_chat_get_post_data("send_mail",false,true),0,null,lz_chat_mail_progress);
    else
	    lz_chat_server_request("./server.php",lz_chat_get_post_values("send_mail",false,true),20000,null,null);
}

function lz_chat_mail_progress(evt)
{
    if (evt.lengthComputable)
    {
        var percentComplete = Math.round(evt.loaded * 100 / evt.total);
        lz_chat_get_frame_object('lz_action_button').value = lz_chat_data.Language.SendMessage + " ("+ percentComplete+ "%)";
    }
}

function lz_chat_mail_callback(_success)
{
	lz_chat_get_frame_object('lz_action_button').style.cursor='pointer';
	lz_chat_get_frame_object('lz_chat_loading').style.display='none';
    lz_chat_get_frame_object('lz_action_button').disabled = false;
    lz_chat_get_frame_object('lz_form_groups').disabled = false;

    lz_chat_get_frame_object('').getElementsByName("lz_login_form")[0].reset();
    lz_chat_change_group(lz_chat_get_frame_object('lz_form_groups'),false);

    if(_success)
	{
        lz_chat_data.CurrentApplication = "";
        for(var i=0;i < lz_chat_get_frame_object('').getElementsByTagName("textarea").length;i++)
            lz_chat_get_frame_object('').getElementsByTagName("textarea")[i].value="";
		lz_chat_get_frame_object('lz_chat_ticket_success').style.display='';
        lz_chat_get_frame_object('lz_form_details').style.display='none';
        lz_chat_get_frame_object('lz_input_header_box').style.display='none';
        lz_chat_get_frame_object('lz_tab_ticket').className = "lz_chat_navigation_tab";
        lz_chat_get_frame_object('lz_tab_callback').className = "lz_chat_navigation_tab";
	}
	else
	{
		lz_chat_dialog(lz_chat_data.Language.MessageFlood,null,null,null,null,true);
        lz_chat_tab_set_active("ticket",true);
	}
}

function lz_chat_close()
{
	var windowName = window.name;
	if(lz_chat_data.GetParameters.indexOf("&dl=") != -1)
		lz_chat_data.GetParameters = lz_chat_data.GetParameters.replace("&dl=MQ__","");

	if(lz_chat_data.GetParameters.indexOf("mp") == -1)
		lz_chat_change_url("./<!--file_chat-->?"+lz_chat_data.GetParameters + "&mp=MQ__", false);
	else
		lz_chat_change_url("./<!--file_chat-->?"+lz_chat_data.GetParameters, false);
	window.name = windowName;
}

function lz_chat_geo_result(_lat,_long,_region,_city,_tz,_ctryi2,_isp)
{
	lz_chat_data.GeoResolution.OnTimeoutEvent = null;
	lz_chat_data.ExternalUser.Session.GeoResolved = Array(_lat,_long,_region,_city,_tz,_ctryi2,_isp);
	lz_chat_data.ExternalUser.Session.Save();
	lz_chat_startup();
}

function lz_chat_geo_resolute()
{
	lz_chat_data.GeoResolution.SetStatus(1);
	lz_chat_data.GeoResolution.OnEndEvent = "lz_chat_geo_result";
	lz_chat_data.GeoResolution.OnTimeoutEvent = lz_chat_geo_failure;
	lz_chat_data.GeoResolution.OnSpanEvent = "lz_chat_set_geo_span";
	lz_chat_data.GeoResolution.ResolveAsync();
}

function lz_chat_set_geo_span(_timespan)
{
	lz_chat_data.GeoResolution.SetSpan(_timespan);
}

function lz_chat_geo_failure()
{
	lz_chat_data.GeoResolution.SetSpan(<!--connection_error_span-->);
	lz_chat_data.GeoResolution.SetStatus(4);
	lz_chat_startup();
}

function lz_chat_show_waiting_links(_html)
{
    lz_chat_data.WaitingLinksShow = true;
    if(lz_global_base64_decode(_html).length>0)
        lz_chat_add_system_text(99,_html);
}

function lz_global_replace_smilies(_text)
{
	var shorts = new Array(/:-\)/g,/::smile/g,/:\)/g,/:-\(/g,/::sad/g,/:\(/g,/:-]/g,/::lol/g,/;-\)/g,/::wink/g,/;\)/g,/:'-\(/g,/::cry/g,/:-O/g,/::shocked/g,/:-\\\\/g,/::sick/g,/:-p/g,/::tongue/g,/:-P/g,/:\?/g,/::question/g,/8-\)/g,/::cool/g,/zzZZ/g,/::sleep/g,/:-\|/g,/::neutral/g);
	var images = new Array("smile","smile","smile","sad","sad","sad","lol","lol","wink","wink","wink","cry","cry","shocked","shocked","sick","sick","tongue","tongue","tongue","question","question","cool","cool","sleep","sleep","neutral","neutral");
	for(var i = 0;i<shorts.length;i++)
		_text = _text.replace(shorts[i]," <img border=0 src='./images/smilies/"+images[i]+".gif'> ");
	return _text;
}

function lz_chat_tab_set_active(_application, _userActivity)
{
    try
    {
        for(var i = 0;i < lz_chat_data.InputFieldValues.length;i++)
            lz_chat_data.InputFieldValues[i].SetStatus('lz_chat_frame_lgin.1.0',true);
        if(_userActivity && !lz_chat_data.ChatGroupAvailable)
            if(_application=="chat")
            {
                if(<!--function_ticket-->)
                {
                    lz_chat_dialog(lz_chat_data.Language.ChatNotAvailable,null,new Function("lz_chat_tab_set_active('ticket',true);"),lz_chat_data.Language.LanguageLeaveMessageShort,null,true);
                    return;
                }
            }

        if(_application == "ticket" && !<!--function_ticket-->)
            _application = "chat";

        lz_chat_data.CurrentApplication = _application;
        lz_chat_data.CallMeBackMode = (_application == "callback");

        if(lz_chat_data.SelectedGroup != null)
        {
            lz_chat_set_input_fields(lz_chat_data.SelectedGroup,lz_chat_get_frame_object(''));
            lz_load_input_values('lz_chat_frame_lgin.1.0');
        }

        var tab = lz_chat_get_frame_object("lz_tab_"+lz_chat_data.CurrentApplication);
        var items = tab.parentNode.getElementsByTagName("li");
        var infoIcon = "./images/chat_header_icon_"+lz_chat_data.CurrentApplication+".png";

        lz_chat_get_frame_object("lz_form_mandatory").style.display = 'none';
        lz_chat_show_header();

        var _onlineOnly = true;
        var online = ((lz_chat_data.SelectedGroup != null && lz_chat_data.SelectedGroup.Amount > 0) || lz_chat_data.NoPreChatMessages);
        var infoFieldText = "";
        var infoFieldTitle = "";
        var buttonTitle = "";
        var buttonTarget = lz_chat_check_login_inputs;
        var buttonIcon = "chat";
        lz_chat_get_frame_object('lz_chat_ticket_success').style.display='none';
        lz_chat_get_frame_object('lz_chat_login').style.display = (_application != "knowledgebase" && !lz_chat_data.CheckoutActive) ? '' : 'none';
        lz_chat_get_frame_object('lz_chat_knowledgebase').style.display= (_application == "knowledgebase") ? '' : 'none';

        if(_application == "ticket")
        {
            if(lz_chat_data.CheckoutActive)
                lz_chat_buy_voucher_navigate('cancel',false);

            infoFieldText = (lz_chat_data.SelectedGroup.TicketInformation.length > 0) ? lz_chat_data.SelectedGroup.TicketInformation : lz_chat_data.Language.LanguageLeaveMessageInformation;
            infoFieldTitle = lz_chat_data.Language.LanguageLeaveMessage;
            buttonTitle = lz_chat_data.Language.SendMessage;
            buttonIcon = "ticket";
            lz_chat_get_frame_object('lz_form_details').style.display = "";
            lz_chat_get_frame_object('lz_group_selection_box').style.display = (lz_chat_data.HideGroupTicket) ? "none" : "";
            buttonTarget=lz_chat_validate_ticket_inputs;

            if(!lz_chat_goto_message(false,false))
                return false;
        }
        else if(_application == "callback")
        {
            infoFieldText += (infoFieldText.length > 0) ? ("<br>" + lz_chat_data.SelectedGroup.CallMeBackInformation) : lz_chat_data.SelectedGroup.CallMeBackInformation;
            infoFieldText = ((infoFieldText.length > 0) ? infoFieldText : ((online) ? lz_chat_data.Language.ClientRequestInstantCallbackInfo : lz_chat_data.Language.ClientRequestInstantCallbackInfoOffline));
            infoFieldTitle = lz_chat_data.Language.ClientRequestInstantCallback;
            buttonTitle = (online) ? lz_chat_data.Language.ClientCallMeNow : lz_chat_data.Language.ClientCallMeLater;
            buttonIcon = "phone";
            buttonTarget= (online) ? lz_chat_check_login_inputs : lz_chat_validate_ticket_inputs;
            lz_chat_get_frame_object('lz_form_details').style.display = "";
        }
        else if(_application == "knowledgebase")
        {
            infoFieldText = "<!--lang_client_tab_knowledgebase_info-->";
            infoFieldTitle = "<!--lang_client_tab_knowledgebase-->";
            lz_chat_get_frame_object('lz_chat_knowledgebase').style.visibility = 'visible';

        }
        else if(_application == "chat")
        {
            infoFieldText = "";//lz_global_base64_decode(lz_chat_data.Language.InfoFieldText);
            infoFieldText += (infoFieldText.length > 0) ? ("<br>" + lz_chat_data.SelectedGroup.ChatInformation) : lz_chat_data.SelectedGroup.ChatInformation;
            infoFieldText = ((infoFieldText.length > 0) ? infoFieldText : ((lz_chat_data.SelectedGroup.ChatVouchersRequired.length > 0) ? lz_chat_data.Language.StartChatInformation + "&nbsp;" + lz_chat_data.Language.StartChatComInformation : lz_chat_data.Language.StartChatInformation));
            infoFieldTitle = lz_chat_data.Language.StartChatHeader;
            buttonTitle = lz_chat_data.Language.StartChat;
            lz_chat_get_frame_object('lz_form_details').style.display = (lz_chat_data.ChatGroupAvailable || !<!--function_ticket-->) ? "" : "none";
            lz_chat_get_frame_object('lz_group_selection_box').style.display = (lz_chat_data.HideGroupChat) ? "none" : "";
        }

        var isOperatorPreselect = (lz_chat_data.InternalUser != null && lz_chat_data.InternalUser.Id != "" && _application != "knowledgebase");
        if(isOperatorPreselect)
            lz_chat_get_frame_object('lz_header_icon_operator').src = "./picture.php?intid="+lz_global_base64_url_encode(lz_chat_data.InternalUser.Id);

        lz_chat_get_frame_object('lz_header_icon_operator').style.visibility = (isOperatorPreselect) ? 'visible' : 'hidden';
        lz_chat_get_frame_object('lz_header_icon_operator_close').style.visibility = (isOperatorPreselect) ? 'visible' : 'hidden';
        infoFieldTitle += (isOperatorPreselect) ? "<span id='lz_header_target'>(" + lz_chat_data.InternalUser.Fullname + ")</span>" : "";
        lz_chat_get_frame_object('lz_action_button').value = buttonTitle;
        lz_chat_get_frame_object('lz_action_button').style.backgroundImage = "url('templates/overlays/chat/images/icon_"+buttonIcon+".png')";
        lz_chat_get_frame_object('lz_header_title').innerHTML = infoFieldTitle;
        lz_chat_get_frame_object('lz_form_info_field').innerHTML = infoFieldText;
        lz_chat_get_frame_object('lz_action_button').onclick=buttonTarget;
        lz_chat_get_frame_object('lz_header_type_icon').style.backgroundImage= (!isOperatorPreselect) ? "url("+infoIcon+")" : "";

        for (var i = 0;i<items.length;i++)
        {
            var chatstatus = "";
            if(items[i].id=="lz_tab_chat")
                chatstatus = " lz_chat_navigation_tab_chat";
            var cn = 'lz_chat_navigation_tab' + chatstatus;
            if(tab.id==items[i].id)
                cn = 'lz_chat_navigation_tab lz_chat_navigation_tab_active' + chatstatus;
            items[i].className = cn;
        }

        lz_chat_get_frame_object('lz_chat_navigation_status').className = (online) ? "lz_chat_navigation_status_online" : "lz_chat_navigation_status_offline";
        var spacer = (lz_chat_get_frame_object('lz_tab_chat').getElementsByTagName("span")[1].innerHTML.trim().length-9)*3;
        lz_chat_get_frame_object('lz_chat_navigation_status').style.marginLeft = (-18+spacer)+"px";
        lz_chat_update_group_icon();
        return true;
    }
    catch(ex)
    {

    }
}

function lz_chat_unset_operator()
{
    lz_chat_data.InternalUser.Id = "";
    lz_chat_tab_set_active(lz_chat_data.CurrentApplication,true);
}

function lz_chat_init_search_kb(_reset,_backgroundSearch)
{
    if(!<!--function_knowledgebase--> || (_backgroundSearch && !lz_chat_data.KnowledgebaseSuggest))
        return;

    var phrase = lz_chat_get_frame_object('lz_chat_kb_input').value;

    if(_reset)
        lz_chat_data.KBLastSearchPhrase = '';

    if(phrase.length < 1)
        phrase = "%ALL%";
    else if(!_backgroundSearch && phrase.length < <!--kb_query_min_length-->)
    {
        lz_chat_dialog("<!--lang_client_kb_query_too_short-->".replace("<!--min_length-->",<!--kb_query_min_length-->),null,null,null,null);
        return;
    }

    if(phrase != lz_chat_data.KBLastSearchPhrase)
    {
        if(!lz_chat_data.KBSearchActive)
        {
            lz_chat_data.KBBackgroundSearch = _backgroundSearch;
            lz_chat_data.KBLastSearchPhrase = phrase;
            lz_shared_kb_last_search_time = lz_global_timestamp();
            lz_chat_data.KBReSearch = false;
            lz_chat_data.KBSearchActive = true;
            lz_chat_server_request("./server.php",lz_chat_get_post_values("search_kb",false,phrase),5000,lz_chat_search_after,null);
            lz_chat_get_frame_object('lz_chat_kb_results').innerHTML = '<br><br><br><div class=\"lz_anim_loading\"></div>';
        }
        else
            lz_chat_data.KBReSearch = true;
    }
}

var kbsoundplayed = false;
function lz_chat_search_result(_externalLink,_result,_count)
{
    lz_chat_get_frame_object('lz_chat_kb_match_info').style.display = (_count > 0 && lz_chat_data.KBBackgroundSearch) ? "block" : "none";
    if(!kbsoundplayed && lz_chat_data.KBLastSearchCount < _count && lz_chat_data.KBBackgroundSearch)
    {
        kbsoundplayed = true;
        lz_chat_play_sound(true);
    }

    lz_chat_data.KBLastSearchCount = _count;
    if(!lz_chat_search_after())
        lz_chat_get_frame_object('lz_chat_kb_results').innerHTML = lz_global_base64_decode(_result);

    lz_chat_get_frame_object('lz_chat_kb_external_link').style.display = (_externalLink) ? "block" : "none";
    lz_chat_kb_show_icon(_count);
    lz_chat_resize();
}

function lz_chat_kb_show_icon(_count)
{
    var show = _count!=0 && lz_global_get_window_width() > 400;
    lz_chat_get_frame_object('lz_chat_kb_icon').style.display = (show) ? 'inline-block' : 'none';
    lz_chat_get_frame_object('lz_chat_kb_icon').innerHTML = _count.toString();
    lz_chat_get_frame_object('lz_chat_kb_icon').style.background = lz_chat_data.PrimaryColor;
}

function lz_chat_open_external_kb()
{
    var curl = lz_global_base64_decode("<!--kb_curl-->");
    if(<!--kb_int--> == 1)
        curl = '<!--kb_eurl-->';
    window.open(curl,'','');
}

function lz_chat_kb_deactivate()
{
    lz_shared_kb_auto_search = false;
    lz_chat_get_frame_object('lz_chat_kb_match_info').style.display = "none";
}

function lz_chat_search_after()
{
    lz_chat_get_frame_object('lz_chat_kb_results').innerHTML = '';
    lz_chat_data.KBSearchActive = false;

    if(lz_chat_data.KBReSearch)
    {
        lz_chat_init_search_kb(lz_chat_get_frame_object('lz_chat_kb_input').value);
        return true;
    }
    return false;
}

function lz_chat_show_kb_entry(_id)
{
    var src = "<!--kb_eurl-->&id=" + _id;
    if(lz_chat_get_frame_object('lz_chat_dialog_resource').attachEvent)
        window.open(src,'','width=590,height=760,left=0,top=0,resizable=yes,menubar=no,location=yes,status=yes,scrollbars=yes');
    else
        lz_chat_dialog(null,null,null,lz_chat_data.Language.Close,null,true,new Array(0.80,0.94),src,true);
}

function lz_chat_resize()
{
    lz_chat_show_header();
}

function lz_chat_kb_scroll(_elem)
{
    //lz_chat_get_frame_object('lz_chat_kb_navigation_top').style.display = (_elem.scrollTop>300) ? "block" : "none";
    //var sw = 100;
    //lz_chat_get_frame_object('cats').style.marginTop = (_elem.scrollTop>sw) ? (_elem.scrollTop-sw) + "px" : "0";
}

function lz_chat_resize_area_int(_a,_b,_c)
{


}


