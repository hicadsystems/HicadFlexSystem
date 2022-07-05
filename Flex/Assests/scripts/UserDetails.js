var auth = auth || {};

var name = name || '';

var token = token || '';

var username = username || '';

function getAuth() {
  /*  alert('i am still here');*/
     auth = Cookies.getJSON("auth");
    return auth;
}

function getName() {
    auth = getAuth();
    if (auth !=null || auth != undefined) {
        name = auth.User.Name; //+ ' ' + auth.User.LastName;
    }
    return name;
}

function getUserName() {
    getAuth();
    username = auth.User.Username;
    return username;
}

function getAuthToken() {
    getAuth();
    token = auth.Token;
    return token;
}