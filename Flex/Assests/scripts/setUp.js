var rateRules = rateRules || new Array();
var rate = rate || {};

var pageModel = pageModel || {};

function addruleRow(rule) {
    var table = document.getElementById("tbrules");
    var tbDiv = document.getElementById('divrules');
    tbDiv.style.display = "block";

    var tbody = document.getElementById('tbrules').getElementsByTagName('tbody')[0];
    var rowCount = tbody.rows.length;
    var row = tbody.insertRow(rowCount);

    row.insertCell(0).innerHTML = rule.intr;
    row.insertCell(1).innerHTML = rule.Commission;
    row.insertCell(2).innerHTML = rule.MktCommRate;
    row.insertCell(3).innerHTML = rule.CommUpperLimit;
    row.insertCell(4).innerHTML = rule.IntrUpperLimit;
    row.insertCell(5).innerHTML = '<input type="button" value = "Remove" onClick="Javacsript:deleteRule(this)">';

}
function addrule() {
    var isvallid = ValidateInput('#rateRules')
    if (isvallid) {
        var form = $("#rateRules");
        var rule = form.serializeObject();
        rateRules.push(rule);
        addruleRow(rule);
        clearrule();
    }
}

function clearrule() {
    document.getElementById('intr').value = '';
    document.getElementById('Commission').value = '';
    document.getElementById('MktCommRate').value = '';
    document.getElementById('CommUpperLimit').value = '';
    document.getElementById('IntrUpperLimit').value = '';
}

function deleteRule(obj) {
    var index = obj.parentNode.parentNode.rowIndex;
    var table = document.getElementById("tbrules");
    table.deleteRow(index);
    var i = index - 1;
    rateRules.splice(i, 1);
}


function showCoyProfileInput(mode, el, coyCode) {
    console.log('About to add Company Profile');
    ShowLoading();
    var url = $(el).attr('data-url');
    var data = { mode: mode, coyCode: coyCode };
    var coyProfilePromise = Post(url, data, 'Get');

    coyProfilePromise.done(function (resp) {
        var func = 'SaveUpdateCoyProfile("' + mode + '")';
        showModal(resp, 'Company Profile', func);
        HideLoading();
    });

    coyProfilePromise.fail(function (resp) {
        if (resp.status === 401) {
            //window.location.href = loginurl;
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error"); HideLoading();
    });
    //HideLoading();
};

function SaveUpdateCoyProfile(mode) {
    console.log('about to save/update coy profile');
    hideModal();
    ShowLoading();
    var Isvalid = ValidateInput('#frmCoyProfile');
    if (Isvalid) {
        var formdata = $("form").serialize();
        formdata += "&mode=" + encodeURIComponent(mode);
        var url = applicationBaseUrl + '/SetUp/SaveUpdate';

        var coyPromise = Post(url, formdata, 'Post');

        coyPromise.done(function (resp) {
            var coyView = document.getElementById('custpolContent');
            coyView.innerHTML = resp;
            HideLoading();
        });

        coyPromise.fail(function (resp) {
            if (resp.status === 401) {
                window.location.href = loginurl;
            }
            toastr.error(resp.statusText, "Error"); HideLoading();
        });
    }
    //HideLoading();
};

function showGrp(el,Id) {
    console.log('About to add Policy Group');
    ShowLoading();
    var url = $(el).attr('data-url');
    var data = { GroupId: Id };
    var coyProfilePromise = Post(url, data, 'Get');

    coyProfilePromise.done(function (resp) {
        var func = 'saveUpdateGroup()';
        showModal(resp, 'Policy Group', func);
        HideLoading();
    });

    coyProfilePromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error"); HideLoading();
    });
    //HideLoading();
};


function searchGroupList(term, page, size) {
    var spinner = document.getElementById('searching');
    spinner.style.display = 'block';
    //if (size === undefined) {
    //    size = 0;
    //}
    var data = {
        searchterm: term, page: page, pagesize: size };
    var url =applicationBaseUrl + '/SetUp/SearchGroup';
    //var url ="/SetUp/SearchGroupList";
    var coyPromise = Post(url, data, 'Post');
    coyPromise.done(function (resp) {
        var pagediv = document.getElementById('tbgroup');
        pagediv.innerHTML = resp;
        spinner.style.display = 'none';
    });
    coyPromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error"); spinner.style.display = 'none';
    });
}

//V2
function searchGroup(el, page) {
    ShowLoading();
    var searchModel = searchModel || {};


    //var name = document.getElementById('groupSearch').value;
    //var type = document.getElementById('agType').value;
    //var location = document.getElementById('agLocation').value;

    //searchModel.Name = name;
    //searchModel.Type = type;
    //searchModel.Location = location;

    pageModel.Page = page;
    searchModel.Page = pageModel;

    var data = { searchmodel: searchModel };
    var url = $(el).attr('data-url');

    var coyPromise = Post(url, data, 'Post');

    coyPromise.done(function (resp) {
        var pagediv = document.getElementById('tbgroup');
        pagediv.innerHTML = resp;
        HideLoading();
    });

    coyPromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error"); HideLoading();
    });
}

function saveUpdateGroup() {
    console.log('about to save/update group');
    var isValid = ValidateInput('#frmGrp');
    if (isValid) {
        ShowLoading();
        hideModal();
        if ($("form").validate().valid()) {
            event.preventDefault();
            var grpclass = '';
            var grpclasses = document.getElementsByName('grpclass');
            for (var i = 0; i < grpclasses.length; i++) {
                if (grpclasses[i].type == 'checkbox') {
                    var element = grpclasses[i];
                    if (element.checked) {
                        grpclass += element.value + ';';
                    }
                }
            }
            var formdata = $("form").serialize();
            formdata += "&Report=" + encodeURIComponent(grpclass);
            var url = applicationBaseUrl + '/SetUp/SaveUpdateGroup';

            var coyPromise = Post(url, formdata, 'Post');

            coyPromise.done(function (resp) {
                var pageview = document.getElementById('custpolContent');
                pageview.innerHTML = resp;
                HideLoading();
            });

            coyPromise.fail(function (resp) {
                if (resp.status === 401) {
                    window.location.href = loginurl;
                }
                toastr.error(resp.statusText, "Error"); HideLoading();
            });
        }
    }
   
    //HideLoading();

}

function ShowdelItem(el, Id,title) {
    console.log('About to Delete');
    ShowLoading();
    var url = $(el).attr('data-url');
    var submitUrl = $(el).attr('data-submitUrl');
    var data = { Id: Id };
    var coyProfilePromise = Post(url, data, 'Get');

    coyProfilePromise.done(function (resp) {
        var func = 'delItem("' + submitUrl + '")';
        showModal(resp, title, func);
        HideLoading();
    });

    coyProfilePromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error"); HideLoading();
    });
    //HideLoading();
};

function ShowdelItem2(el, Id, title) {
    console.log('About to Delete');
    ShowLoading();
    var url = $(el).attr('data-url');
    //var sms = document.getElementById('sms').value;
    var submitUrl = $(el).attr('data-submitUrl');
    var data = { Id: Id, sms: sms };
    var coyProfilePromise = Post(url, data, 'Get');

    coyProfilePromise.done(function (resp) {
        var func = 'delItem("' + submitUrl + '")';
        showModal(resp, title, func);
        HideLoading();
    });

    coyProfilePromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error"); HideLoading();
    });
    //HideLoading();
};

function delItem(url) {
    hideModal();
    ShowLoading();
    var id = document.getElementById('id').value;
    var data = { Id: id };

    var coyPromise = Post(url, data, 'Post');

    coyPromise.done(function (resp) {
        toastr.success("Item Deleted Successfully", 'Delete');
        var pagediv = document.getElementById('custpolContent');
        pagediv.innerHTML = resp;
        HideLoading();
    });

    coyPromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error"); HideLoading();
    });
    //HideLoading();
};


function searchAgent(el,page) {
    ShowLoading();
    var searchModel = searchModel || {};


    var name = document.getElementById('agName').value;
    var type = document.getElementById('agType').value;
    var location = document.getElementById('agLocation').value;

    searchModel.Name = name;
    searchModel.Type = type;
    searchModel.Location = location;

    pageModel.Page = page;
    searchModel.Page = pageModel;

    var data = { searchmodel: searchModel };
    var url = $(el).attr('data-url');

    var coyPromise = Post(url, data, 'Post');

    coyPromise.done(function (resp) {
        var pagediv = document.getElementById('tbagents');
        pagediv.innerHTML = resp;
        HideLoading();
    });

    coyPromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error"); HideLoading();
    });
}

function showAgentInput(el,agentId) {
    console.log('About to add/Edit Agent');
    ShowLoading();
    var url = $(el).attr('data-url');
    var data = { AgentId: agentId };
    var coyProfilePromise = Post(url, data, 'Get');

    coyProfilePromise.done(function (resp) {
        var func = 'saveUpdateAgent()';
        showModal(resp, 'Agent', func);
        HideLoading();
    });

    coyProfilePromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error"); HideLoading();
    });
    //HideLoading();
};

function saveUpdateAgent() {
    console.log('about to save/update agent');
    var isValid = ValidateInput('#frmAgent');
    if (isValid) {
        ShowLoading();
        hideModal();
        var formdata = $("form").serialize();
        var url = applicationBaseUrl + '/SetUp/SaveUpdateAgent';

        var coyPromise = Post(url, formdata, 'Post');

        coyPromise.done(function (resp) {
            var pageview = document.getElementById('custpolContent');
            pageview.innerHTML = resp;
            HideLoading();
        });

        coyPromise.fail(function (resp) {
            if (resp.status === 401) {
                window.location.href = loginurl;
            }
            toastr.error(resp.statusText, "Error"); HideLoading();
        });

    }
    //HideLoading();

}


function exportAgent(format) {
    ShowLoading();
    var downloadModel = downloadModel || {};

    downloadModel.IsReport = true;
    downloadModel.ReportFormat = format;

    var data = { query: downloadModel };

    var url = applicationBaseUrl + '/SetUp/Agent2';

    var coyPromise = Post(url, data, 'Post');

    coyPromise.done(function (resp) {
        window.open(resp, "resizeable,scrollbar");
        HideLoading();
    });

    coyPromise.fail(function (resp) {
        HideLoading()
        toastr.error(resp.statusText, "Error");
    });
}

function searchLocation(term,format,page) {
    var spinner = document.getElementById('searching');
    spinner.style.display = 'block';
    var download = false;
    if (format ||format != null) {
        download = true;
    }

    var searchModel = searchModel || {};

    searchModel.SearchTerm = term;
    searchModel.IsReport = download;
    searchModel.ReportFormat = format;

    pageModel.Page = page;
    searchModel.Page = pageModel;

    var data = { searchmodel: searchModel };

    var url =applicationBaseUrl + '/SetUp/SearchLocation';

    var coyPromise = Post(url, data, 'Post');

    coyPromise.done(function (resp) {
        if (!download) {
            var pagediv = document.getElementById('tbloc');
            pagediv.innerHTML = resp;
        }
        else {
            window.open(resp, "resizeable,scrollbar")
        }
        spinner.style.display = 'none';
    });

    coyPromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error");
        spinner.style.display = 'none';
    });
}

function showLocationInput(el, locationId) {
    console.log('About to add/Edit Location');
    ShowLoading();
    var url = $(el).attr('data-url');
    var data = { Id: locationId };
    var coyProfilePromise = Post(url, data, 'Get');

    coyProfilePromise.done(function (resp) {
        var func = 'saveUpdateLocation()';
        showModal(resp, 'Location', func);
        jQuery(document).trigger("select2");
        HideLoading();
    });

    coyProfilePromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
    //HideLoading();
};

function saveUpdateLocation() {
    console.log('about to save/update Location');
    var isValid = ValidateInput('#frmLoc');
    if (isValid) {
        ShowLoading();
        hideModal();
        var formdata = $("form").serialize();
        var url = applicationBaseUrl + '/SetUp/SaveUpdateLocation';

        var coyPromise = Post(url, formdata, 'Post');

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

    }
    //HideLoading();

}

function exportPolType(format) {
    ShowLoading();
    var downloadModel = downloadModel || {};

    downloadModel.IsReport = true;
    downloadModel.ReportFormat = format;

    var data = { query: downloadModel };

    var url = applicationBaseUrl + '/SetUp/PolicyType2';

    var coyPromise = Post(url, data, 'Post');

    coyPromise.done(function (resp) {
        window.open(resp, "resizeable,scrollbar");
        HideLoading();
    });

    coyPromise.fail(function (resp) {
       HideLoading()
        toastr.error(resp.statusText, "Error");
    });
}

function exportLifeRate(format) {
    ShowLoading();
    var downloadModel = downloadModel || {};

    downloadModel.IsReport = true;
    downloadModel.ReportFormat = format;

    var data = { query: downloadModel };

    var url = applicationBaseUrl + '/SetUp/LifeRate2';

    var coyPromise = Post(url, data, 'Post');

    coyPromise.done(function (resp) {
        window.open(resp, "resizeable,scrollbar");
        HideLoading();
    });

    coyPromise.fail(function (resp) {
        HideLoading()
        toastr.error(resp.statusText, "Error");
    });
}

function showPolTypeInput(el, Id) {
    console.log('About to add/Edit Policy Type');
    ShowLoading();
    var url = $(el).attr('data-url');
    var data = { Id: Id };
    var coyProfilePromise = Post(url, data, 'Get');

    coyProfilePromise.done(function (resp) {
        var func = 'saveUpdatePolType()';
        showModal(resp, 'Policy Type', func);
        jQuery(document).trigger("select2");
        HideLoading();
    });

    coyProfilePromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
    //HideLoading();
};

function saveUpdatePolType() {
    console.log('about to save/update Poicy Type');
    var isValid = ValidateInput('#frmPolType');
    if (isValid) {
        ShowLoading();
        hideModal();
        var formdata = $("form").serialize();
        var url = applicationBaseUrl + '/SetUp/SaveUpdatePolicyType';

        var coyPromise = Post(url, formdata, 'Post');

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

    }
   //HideLoading();

}

function showRateInput(el) {
   
    console.log('About to add Rate');
    ShowLoading();
    var url = $(el).attr('data-url');
    var data = {};
    var coyProfilePromise = Post(url, data, 'Get');

    coyProfilePromise.done(function (resp) {
      

        /*document.getElementById('rateRulesPPP').style.display = "none";*/
        /*$('#rateRulesPPP').hide();*/
        var func = 'saveRate()';
        showModal(resp, 'Rate', func);
        HideLoading();
    });

    coyProfilePromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
    //HideLoading();
};

function showRateInput2(el) {

    console.log('About to add Rate');
    ShowLoading();
    var url = $(el).attr('data-url');
    var data = {};
    var coyProfilePromise = Post(url, data, 'Get');

    coyProfilePromise.done(function (resp) {


        /*document.getElementById('rateRulesPPP').style.display = "none";*/
        /*$('#rateRulesPPP').hide();*/
        var func = 'saveRate()';
        showModal(resp, 'Rate', func);
        HideLoading();
    });

    coyProfilePromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
    //HideLoading();
};

function saveRate() {
    console.log('about to save Rate');

    if (rateRules.length === null || rateRules.length===0) {
        var isvallid = ValidateInput('#rate1')
        if (isvallid) {
            ShowLoading();
            hideModal();
            var rate = $("#rate1").serializeObject();

            //rate.rateRules = rateRules;

            var model = JSON.stringify(rate);
            var data = { model: model };

            var url = applicationBaseUrl + '/SetUp/Saveliferate';

            var coyPromise = Post(url, data, 'Post');

            coyPromise.done(function (resp) {
                rateRules = new Array();
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

        }
    }

    else if (rateRules.length > 0) {
        var isvallid = ValidateInput('#rate')
        if (isvallid) {
            ShowLoading();
            hideModal();
            var rate = $("#rate").serializeObject();

            rate.rateRules = rateRules;

            var model = JSON.stringify(rate);
            var data = { model: model };

            var url =applicationBaseUrl + '/SetUp/Saveliferate';

            var coyPromise = Post(url, data, 'Post');

            coyPromise.done(function (resp) {
                rateRules = new Array();
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

        }
    } else {
        toastr.error("One or more rule(s) required", "Error");
    }
}

function viewRateRules(id) {
    ShowLoading();
    hideModal();
    var data = { Id: id };

    var url =applicationBaseUrl + '/SetUp/GetRateRules';

    var coyPromise = Post(url, data, 'Get');

    coyPromise.done(function (resp) {
       
        HideLoading();
        showModal(resp, "Rate Rules", "");
    });

    coyPromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });

}

function searchRate(el) {
    ShowLoading();
    var searchModel = searchModel || {};

    var period = document.getElementById('period').value;
    var poltype = document.getElementById('PolType').value;
    var group = document.getElementById('Group').value;

    searchModel.Period = period;
    searchModel.PolicyType = poltype;
    searchModel.Group = group;

    var data = { searchmodel: searchModel };
    var url = $(el).attr('data-url');

    var coyPromise = Post(url, data, 'Post');

    coyPromise.done(function (resp) {
        var pagediv = document.getElementById('tbrate');
        pagediv.innerHTML = resp;
        HideLoading();
    });

    coyPromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error");
        HideLoading();
    });
}

function searchHoliday(term, page, size) {
    var spinner = document.getElementById('searching');
    spinner.style.display = 'block';
    var data = { searchterm: term, page: page, pagesize: size };
    var url = applicationBaseUrl + '/SetUp/SearchPublicHoliday';

    var coyPromise = Post(url, data, 'Post');

    coyPromise.done(function (resp) {
        var pagediv = document.getElementById('tbholiday');
        pagediv.innerHTML = resp;
        spinner.style.display = 'none';
    });

    coyPromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error"); spinner.style.display = 'none';
    });
}

function searchHoliday2(el, page) {
    ShowLoading();
    var searchModel = searchModel || {};

    pageModel.Page = page;
    searchModel.Page = pageModel;

    var data = { searchmodel: searchModel };
    var url = $(el).attr('data-url');

    var coyPromise = Post(url, data, 'Post');

    coyPromise.done(function (resp) {
        var pagediv = document.getElementById('tbholiday');
        pagediv.innerHTML = resp;
        HideLoading();
    });

    coyPromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error"); HideLoading();
    });
}


function showHoliday(el, Id) {
    ShowLoading();
    var url = $(el).attr('data-url');
    var data = { HolidayId: Id };
    var coyProfilePromise = Post(url, data, 'Get');

    coyProfilePromise.done(function (resp) {
        var func = 'saveUpdateHoliday()';
        showModal(resp, 'Public Holiday', func);
        HideLoading();
    });

    coyProfilePromise.fail(function (resp) {
        if (resp.status === 401) {
            window.location.href = loginurl;
        }
        toastr.error(resp.statusText, "Error"); HideLoading();
    });
    //HideLoading();
};

function saveUpdateHoliday() {
    console.log('about to save/update holiday');
    var isValid = ValidateInput('#frmHoliday');
    if (isValid) {
        ShowLoading();
        hideModal();
        if ($("form").validate().valid()) {
            event.preventDefault();
            var formdata = $("form").serialize();
            var url = applicationBaseUrl + '/SetUp/SaveUpdateHoliday';

            var coyPromise = Post(url, formdata, 'Post');

            coyPromise.done(function (resp) {
                var pageview = document.getElementById('custpolContent');
                pageview.innerHTML = resp;
                HideLoading();
            });

            coyPromise.fail(function (resp) {
                if (resp.status === 401) {
                    window.location.href = loginurl;
                }
                toastr.error(resp.statusText, "Error"); HideLoading();
            });
        }
    }

    //HideLoading();

}


