
window.onload = function () {
    jQuery(document).trigger("date_picker");
    var name = document.getElementById('name');
    var username = document.getElementById('username');
    var name = getName();
    if (name!='') {
        name.innerText = name;
        username.innerText = getUserName();

        var greetingName = document.getElementById('greetingName');
        if (greetingName != null) {
            greetingName.innerText = name;
        }
    }
    else {
        //window.location.href = '/Login';
        window.location.href = loginurl;
    }

};