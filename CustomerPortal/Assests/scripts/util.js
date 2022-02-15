function ShowLoading() {
    $('#ajax').modal({ backdrop: 'static', keyboard: false });
};

function HideLoading() {
    $('#ajax').modal('hide');
};

function showModal(data, title,fn) {
    //$('modalbody').html(data);
    var modalbody = document.getElementById('modalbody');
    modalbody.innerHTML = data;
    modalbody.focus();
    var modaltitle = document.getElementById('title');
    modaltitle.innerText = title;
    var submitbtn = document.getElementById('modalSubmit');
    submitbtn.setAttribute("data-click", fn);
    submitbtn.setAttribute("onclick", fn);
    //submitbtn.onclick=fn;
    $('#Modal').modal({ backdrop: 'static', keyboard: false });

};

function showModalfromfile(url, title, fn) {
    $('#modalbody').load(url);
    var modaltitle = document.getElementById('title');
    modaltitle.innerText = title;
    var submitbtn = document.getElementById('modalSubmit');
    submitbtn.setAttribute("data-click", fn);
    submitbtn.setAttribute("onclick", fn);
    $('#Modal').modal({ backdrop: 'static', keyboard: false });

};

function hideModal(Isclose) {
    var modalbody = document.getElementById('modalbody');
    if (Isclose) {
        modalbody.innerHTML = "";
    }
    $('#Modal').modal('hide');
};

function SubmitModal(el) {
    var f = $(el).attr('data-click')
    var func = new Function(f);
};

function LoadDropDown(el,url,data,defaultText) {
    var url = url;
    var data = data;
    var promise = $.post(url, data, function (data) {    //ajax call
        var items = [];
        items.push("<option value=" + 0 + ">" + defaultText + "</option>"); //first item
        for (var i = 0; i < data.length; i++) {
            items.push("<option value=" + data[i].Value + ">" + data[i].Text + "</option>");
        }                                         //all data from the team table push into array
        $(el).html(items.join(' '));
    });
    return promise;
}

function ValidateInput(container) {
    var isValid = true;
    var fields;
    if (container != null || container != '' || container !== undefined) {
        fields = $(container + ' .ss-item-required').find('select,textarea,input').serializeArray();
    } else {
        fields = $('.ss-item-required').find('select,textarea,input').serializeArray();
    }

    $.each(fields, function (i, field) {
        if (!field.value) {
            toastr.error(field.name + " required", "Validation Error");
            isValid = false;
        }
    });
    return isValid;

}

$.maxZIndex = $.fn.maxZIndex = function (opt) {
    /// <summary>
    /// Returns the max zOrder in the document (no parameter)
    /// Sets max zOrder by passing a non-zero number
    /// which gets added to the highest zOrder.
    /// </summary>    
    /// <param name="opt" type="object">
    /// inc: increment value, 
    /// group: selector for zIndex elements to find max for
    /// </param>
    /// <returns type="jQuery" />
    var def = { inc: 10, group: "*" };
    $.extend(def, opt);
    var zmax = 0;
    $(def.group).each(function () {
        var cur = parseInt($(this).css('z-index'));
        zmax = cur > zmax ? cur : zmax;
    });
    if (!this.jquery)
        return zmax;

    return this.each(function () {
        zmax += def.inc;
        $(this).css("z-index", zmax);
    });
}
