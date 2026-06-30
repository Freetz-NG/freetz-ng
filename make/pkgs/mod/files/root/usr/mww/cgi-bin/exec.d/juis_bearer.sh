cgi_begin 'juis_bearer ...'
echo '<pre>'
echo 'Please wait ...'
echo

juis_bearer g | html

echo
echo "done."
echo '</pre>'
back_button mod system
cgi_end

