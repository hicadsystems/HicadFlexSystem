function loadUserInput(el) {
    ShowLoading();
    var url = $(el).attr('data-url');
    var promise = Post(url, {}, 'Get');

    promise.done(function (resp) {
        var func = 'addUser()';
        showModal(resp, 'Add New User', func);
        HideLoading();
    });

    promise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error("An Error Occurred.", "Error");
        HideLoading();
    });
};

function addUser() {
    hideModal();
    ShowLoading();
    var isValid = ValidateInput("#AddUser")

    if (isValid) {
        var user = $("#AddUser").serializeObject();
        var url = applicationBaseUrl + '/UserRole/AddUser';
        var data = { User: user };
        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            var pageview = document.getElementById('custpolContent');
            pageview.innerHTML = resp;
            HideLoading();
        });

        Promise.fail(function (resp) {
            if (resp.status === 401) {
                window.location.href = loginurl;
            }
            toastr.error(resp.statusText, "Error");
            HideLoading();
        });
    }
}

function loadRoleInput(el,Id) {
    ShowLoading();
    var url = $(el).attr('data-url');

    var data = { Role: Id };
    var promise = Post(url, data, 'Get');

    promise.done(function (resp) {
        var func = 'addRole()';
        showModal(resp, 'Role', func);
        HideLoading();
    });

    promise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error("An Error Occurred.", "Error");
        HideLoading();
    });
};

function addRole() {
    hideModal();
    ShowLoading();
    var isValid = ValidateInput("#divRole")
    var links = links || [];
    var role = role || {};
    if (isValid) {
        role.Name=document.getElementById('roleName').value;
        role.Id = document.getElementById('roleid').value;
        role.Desc = document.getElementById('roleDesc').value;
        var main = document.getElementsByName('portlet');
        $.each(main, function (i, o) {
            var portlet = '';
            var tab = '';
            var link = '';
            if (o.checked) {
                var tabdiv = $(o).parent().siblings()[0];
                var tabs = $(tabdiv).find('input[name=tab]');
                portlet = o.value;
                $.each(tabs, function (x, t) {
                    if (t.checked) {
                        tab+= t.value + ';'
                    }
                });
                link = portlet + '|' + tab;
                console.log(link);
                links.push(link);
            }
           
        });

        role.links = links;
        var url = applicationBaseUrl + '/UserRole/SaveUpdateRole';
        var data = { role: role };
        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            var pageview = document.getElementById('custpolContent');
            pageview.innerHTML = resp;
            HideLoading();
        });

        Promise.fail(function (resp) {
            if (resp.status === 401) {
                window.location.href = loginurl;
            }
            toastr.error(resp.statusText, "Error");
            HideLoading();
        });
    }
}

function togglecheckMainMenu(el) {
    console.log(el);
    if (el.checked) {
        $('.checkbox').attr('checked', true);
    } 
};

function showChangePassword() {
    showModalfromfile('appFiles/changePassword.html', 'Change Password', 'xPass()')
}

function showUserresetPwd(el) {
    ShowLoading();
    console.log(id);

    var url = $(el).attr('data-url');
    var id = $(el).attr('data-id');
    var data = { Id: id };

    var resetpwdPromise = Post(url, data, 'Get');

    resetpwdPromise.done(function (resp) {
        HideLoading();
        showModal(resp, 'Reset Password', 'resetUserPwd()')
    });

    resetpwdPromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
}

function resetUserPwd() {
    hideModal();
    ShowLoading();
    var id = document.getElementById('id').value;
    var data = { Id: id };
    var url = applicationBaseUrl +  '/UserRole/PasswordReset';

    var coyPromise = Post(url, data, 'Post');

    coyPromise.done(function (resp) {
        toastr.success(resp, 'Password Reset');
        alert(resp);
        HideLoading();
    });

    coyPromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error("An Error Occurred.", "Error");
        HideLoading();
    });
    //HideLoading();
};

function editUser(el, id) {
    ShowLoading();
    var url = $(el).attr('data-url');
    var data = { Id: id };
    var promise = Post(url, data, 'Get');

    promise.done(function (resp) {
        var func = 'updateUser()';
        showModal(resp, 'Edit User', func);
        HideLoading();
    });

    promise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
};

function updateUser() {
    hideModal();
    ShowLoading();
    var isValid = ValidateInput("#AddUser")

    if (isValid) {
        var user = $("#AddUser").serializeObject();
        var url = applicationBaseUrl + '/UserRole/UpdateUser';
        var data = { model: user };
        var Promise = Post(url, data, 'Post');

        Promise.done(function (resp) {
            var pageview = document.getElementById('custpolContent');
            pageview.innerHTML = resp;
            HideLoading();
        });

        Promise.fail(function (resp) {
            toastr.error(resp.statusText, "Error");
            HideLoading();
        });
    }
}


function confirmdeleteUser(el, id) {
    ShowLoading();
    var url = $(el).attr('data-url');
    var data = { Id: id };
    var promise = Post(url, data, 'Get');

    promise.done(function (resp) {
        var func = 'deleteUser()';
        showModal(resp, 'Delete User', func);
        HideLoading();
    });

    promise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
};

function deleteUser() {
    hideModal();
    ShowLoading();
    var id = document.getElementById('id').value;
    var data = { Id: id };
    var url = applicationBaseUrl + '/UserRole/DeleteUser';

    var coyPromise = Post(url, data, 'Post');

    coyPromise.done(function (resp) {
        var pageview = document.getElementById('custpolContent');
        pageview.innerHTML = resp;
        HideLoading();
    });

    coyPromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
    //HideLoading();
};

function searchUser(term) {
    //var spinner = document.getElementById('searching');
    //spinner.style.display = 'block';
    var data = { searchterm: term };
    var url = applicationBaseUrl + '/UserRole/SearchUsers';

    var coyPromise = Post(url, data, 'Post');

    coyPromise.done(function (resp) {
        var pagediv = document.getElementById('tbUsers');
        pagediv.innerHTML = resp;
        //spinner.style.display = 'none';
    });

    coyPromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error"); //spinner.style.display = 'none';
    });
}
