#!/bin/sh


. /usr/lib/libmodcgi.sh

if [ "$sec_level" -gt 0 ]; then
	cgi --id=rudishell
	cgi_begin "$(lang de:"Rudi(ment&auml;r)-Shell" en:"Rudi(mentary) Shell")"
	print_warning "$(lang \
	  de:"Rudi-Shell ist in der aktuellen Sicherheitsstufe nicht verf&uuml;gbar!" \
	  en:"Rudi shell is not available at the current security level!" \
	)"
	cgi_end
	exit
fi

cgi_begin "$(lang de:"Rudi(ment&auml;r)-Shell" en:"Rudi(mentary) Shell")"
cat << EOF
	<script type="text/javascript">
		var editing=0,code,output,exec,tar,gz,dl,his,repeat,file,hist = Array();
		window.onload = function(){
			code = document.getElementById("script_code");
			output = document.getElementById("shell_output");
			exec = document.getElementById("exec");
			tar = document.getElementById("tar");
			gz = document.getElementById("gz");
			dl = document.getElementById("dl");
			his = document.getElementById("history");
			file = document.getElementById("file2edit");
			repeat = document.getElementById("repeat");
		}
		function setShellOutput() {
			hist.push(new Array(code.value, output.innerHTML));
			his[hist.length - 1] = new Option("#" + (hist.length - 1));
			his.selectedIndex = 0;
		}
		function historySelected(index) {
			code.value = hist[hist.length - 1 - index][0];
			output.innerHTML = hist[hist.length - 1 - index][1];
		}
		function cleanHistory() {
			while (his.length > 0)
				his.remove(0)
		}
		function ajax_exec(params){
			var ajax = new XMLHttpRequest();
			ajax.open("POST","/cgi-bin/shell/cmd.cgi?pid=$$",false);
			ajax.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
			ajax.setRequestHeader("Content-length", params.length);
			ajax.setRequestHeader("Connection", "close");
			ajax.send(params);
			return ajax.responseText;
		}
		function RudiEdit() {
			output.innerHTML=ajax_exec("script=cat "+file.value);
			code.value=output.firstChild.nodeValue;
			exec.value="$(lang de:"Editieren" en:"Edit")";
			editing=1;
		}
		function tx(){
			if(repeat.value != ""){
				setTimeout("tx();",repeat.value);
			}
			if(editing){
				ajax_exec('script=echo "'+encodeURIComponent(code.value)+'" > '+file.value);
				code.value="";
				output.innerHTML="$(lang de:"Editiert!" en:"Edited!")";
				exec.value="$(lang de:"Skript ausf&uuml;hren" en:"Run script")";
				editing=0;
			}
			else{
				if(dl.checked){
					window.location = "/cgi-bin/shell/cmd.cgi?pid=$$&dl=true&script="+encodeURIComponent(code.value)+"&tar="+tar.checked+"&gz="+gz.checked;
				}
				else{
					output.innerHTML=ajax_exec("script="+encodeURIComponent(code.value));
					setShellOutput();
				}
			}
		}
	</script>
	<br>
	<div class="textwrapper"><textarea id="script_code" rows="10" cols="80"></textarea></div><p>
	<input type="button" id="exec" value="$(lang de:"Skript ausf&uuml;hren" en:"Run script")" onClick="tx();">&nbsp;&nbsp;
	<label for="repeat">$(lang de:"Wiederholungsintervall" en:"Loop interval")</label> <input type="text" id="repeat" size=6>&nbsp;ms&nbsp;&nbsp;
	<label for="history">$(lang de:"Historie" en:"History")</label> <select id="history" onChange="historySelected(this.selectedIndex)"></select>
	<input type="button" value="$(lang de:"Hist. l&ouml;schen" en:"Delete hist.")" onClick="cleanHistory()">&nbsp;&nbsp;
	<input type="checkbox" id="dl"><label for="dl">Download</label>
	(<input type="checkbox" id="tar"><label for="tar">.tar</label>
	<input type="checkbox" id="gz"><label for="gz">.gz</label> )
	<table>
		<form action="/cgi-bin/shell/upload.cgi?pid=$$" target="upload" method="POST" enctype="multipart/form-data">
			<tr><td><label for="source">$(lang de:"Quelldatei" en:"Source file")</label></td><td><input type="file" name="source" id="source" size=50></td></tr>
			<tr><td><label for="target">$(lang de:"Zieldatei" en:"Target file")</label></td><td><input type="text" name="target" id="target" value="/var/tmp/rudi_upload" size=50> <input type="submit" value="$(lang de:"Hochladen" en:"Upload")"></td></tr>
		</form>
		<tr><td><label for="file2edit">$(lang de:"Rudi-Edit" en:"Rudi edit")</label></td><td> <input type="text" id="file2edit" value="/var/tmp/tmp.txt" size=50> <input type="button" value="$(lang de:"Datei editieren" en:"Edit file")" onClick="RudiEdit()"></td></tr>
	</table>
	<iframe name="upload" style="width: 0; height: 0; visibility: hidden;"></iframe>
	<pre id="shell_output">---</pre>
EOF
cgi_end
echo $$ > /var/run/rudi_shell.pid

