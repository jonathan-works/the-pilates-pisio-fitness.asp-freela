<input type="hidden" id="lz_form_active_<!--name-->" value="<!--active-->">
<input type="hidden" id="lz_form_ph_<!--name-->" value="<!--caption_plain-->">
<table id="lz_form_<!--name-->" class="lz_input">
	<tr>
		<td><input name="form_<!--name-->" placeholder="<!--caption_plain-->" class="lz_form_base lz_form_box" maxlength="254" onchange="parent.lz_chat_save_input_value('<!--name-->',this.value);" onkeyup="return parent.lz_chat_save_input_value('<!--name-->',this.value);"></td>
        <td class="lz_form_icon">
            <div class="lz_form_info_box" id="lz_form_info_<!--name-->"><!--info_text--></div>
            <div id="lz_form_mandatory_<!--name-->" style="display:none;"></div>
        </td>
	</tr>
</table>