<script type='text/javascript'>
function csrfUrl(url) {
	var token = document.querySelector('meta[name="csrf-token"]').content;
	url = url.replace(/&amp;/g, '&');
	if (/[?&]csrf_token=/.test(url))
		return url.replace(/([?&])csrf_token=[^&#]*/g, '$1csrf_token=' + token);
	else
		return url + (url.indexOf('?') < 0 ? '?' : '&') + 'csrf_token=' + token;
}
</script>

