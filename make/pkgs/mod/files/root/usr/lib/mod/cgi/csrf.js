<script type='text/javascript'>
function csrfPost(url, params, target, features) {
	var form = document.createElement('form');
	form.method = 'POST';
	form.action = url.replace(/&amp;/g, '&');
	form.style.display = 'none';
	if (target) {
		if (features)
			window.open('', target, features);
		form.target = target;
	}
	params = params || {};
	params.csrf_token = document.querySelector('meta[name="csrf-token"]').content;
	for (var key in params) {
		if (!Object.prototype.hasOwnProperty.call(params, key))
			continue;
		var input = document.createElement('input');
		input.type = 'hidden';
		input.name = key;
		input.value = params[key];
		form.appendChild(input);
	}
	document.body.appendChild(form);
	form.submit();
	document.body.removeChild(form);
	return false;
}
</script>

