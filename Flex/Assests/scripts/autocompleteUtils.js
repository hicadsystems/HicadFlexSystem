$(function () {

    var autoCompleteSelectHandler = function (event, ui) {
        event.preventDefault();
        console.log(ui);
        var $input = $(this);
        var selectedObj = ui.item;
        console.log(selectedObj.value);
        $input.val(selectedObj.label);
        var hidden = $input.siblings('input[data-autocomplete-id]')[0];
        $(hidden).val(selectedObj.value);
        var func = $input.attr('data-func');
    }

    var productautoCompleteSelectHandler = function (event, ui) {
        event.preventDefault();
        console.log(ui);
        var $input = $(this);
        var selectedObj = ui.item;
        console.log(selectedObj.value);
        $input.val(selectedObj.label);
        var hidden = $input.siblings('input[data-autocomplete-id]')[0];
        $(hidden).val(selectedObj.value);
        getprice(selectedObj.value);
    }

    var createAutocomplete = function () {
        var $input = $(this);

        var options = {
            source: $input.attr("data-autocomplete"),
            select: autoCompleteSelectHandler
        }

        $input.autocomplete(options);
    };

    var createProductAutocomplete = function () {
        var $input = $(this);

        var options = {
            source: $input.attr("data-autocomplete-Product"),
            select: productautoCompleteSelectHandler
        }

        $input.autocomplete(options);
    };


    //$("input[data-autocomplete]").each(createAutocomplete);
    $(document).on('keydown.autocomplete', 'input[data-autocomplete]', createAutocomplete);

    $(document).on('keydown.autocomplete', 'input[data-autocomplete-Product]', createProductAutocomplete);
});