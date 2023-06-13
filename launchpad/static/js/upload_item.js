var upload_list = [];


function getFile(elem){
    $(elem).click();
}

conv_socket.on('status', function( json) {
    $('.upload_item[upload_id="' + json['id'] + '"]').find('.status').text(json['status']);
});

conv_socket.on('completed', function( json) {
    $('.upload_item[upload_id="' + json['id'] + '"]').find('.status').text(json['status']);
    $('.upload_item[upload_id="' + json['id'] + '"]').find('.download').show();
});


function resetForm(form){
    $(form).find('input[type=submit]').val('Submit');
    $(form).find('input[type=submit]').prop("disabled", true);
    $(form).find('input[type=text]').prop("disabled", true);
    $(form).find('input[type=text]').val('');
    $(form).find('.prompt').text('');
    $(form).hide();
    clearInterval(countdown); 
}

function show_input(upload_item, data){
    $(upload_item).find('.input_form').show();
    $(upload_item).find(".user_input").prop("disabled", false);
    $(upload_item).find(".user_input").focus();
    $(upload_item).find('.prompt').append(data.message);
    $(upload_item).find(".sid").val(data.sio);
    $(upload_item).find(".input_submit").prop("disabled", false);
}

conv_socket.on('prompt_input', function( data ){
    console.log("Waiting for input!");
    // alert('Input for '+data.upload_id+'!');
    var upload_item = $('.upload_item[upload_id=' + data.upload_id + ']');
    //alert(upload_item.attr('class'))
    if($(upload_item).length == 1){
        show_input(upload_item, data)
    }
    
    
    var timer = data.timeout;
    countdown = setInterval(function(){
        if($(upload_item).length == 0){
            upload_item = $('.upload_item[upload_id=' + data.upload_id + ']');
        } else{
            if($(upload_item).find(".user_input").prop("disabled") == true){
                show_input(upload_item, data)
            }
            $(upload_item).find(".input_submit").val("Submit (" + timer + ")");
            timer -= 1;
        }
        
        if(timer < 0){ 
            resetForm($(upload_item).find('.input_form'));
            conv_socket.emit('submit_input', {'input' : null, 'sender' : $(upload_item).find(".sid").val()}); 
        }
    }, 1000);
});

$(".uploads_container").on("submit", ".uploads", function( event ) {
    var button = $("input[type=submit][clicked=true]");

    if(button.hasClass('input_submit')){
        var input_form = $(button).parent();
        event.preventDefault();
        var data = $(input_form).find(".user_input").val();
        console.log($(input_form).find(".sid").val());
        conv_socket.emit('submit_input', {'input' : data, 'sender' : $(input_form).find(".sid").val()}, function(){
            console.log('Input acknowledged: ' + data);
        });
        resetForm(input_form);
    }
});

/* Check/Uncheck All */
$(".uploads_container").on("change", ".select", function( event ){
    if($(event.currentTarget).prop('checked')){
        $('input[name='+ $(event.currentTarget).attr("name") +']').prop("checked", true);
        //$(this).prop('checked', true);
    } else{
        $('input[name='+ $(event.currentTarget).attr("name") +']').prop("checked", false);
        //$(this).prop('checked', false);
    }
});

/* Checks/Unchecks the 'Check All' button based on state of other checkboxes*/
$(".uploads_container").on("change", 'input[class=select_button]', function( event ){
    if($(event.currentTarget).prop('checked')){
        if($('input[name='+$(event.currentTarget).attr('name')+']:checked').length == $('input[name='+$(event.currentTarget).attr('name')+']').length - 1){
            $(".select[name="+$(event.currentTarget).attr('name')+"]").prop("checked", true);
        }
    }else{
        $(".select[name="+$(event.currentTarget).attr('name')+"]").prop("checked", false);
    }
});


$(".uploads_container").on("click", "form input[type=submit]", function( event ) {
    $("input[type=submit]", $(event.currentTarget).parents("form")).removeAttr("clicked");
    $(event.currentTarget).attr("clicked", "true");
});

$(".uploads_container").on('keypress', '.user_input', function (e) {
    if (e.which == 13) {
        //alert($(e.currentTarget).prop('value'));
        $(e.currentTarget).siblings('.input_submit').click();
        return false;    //<---- Add this line
    }
});

function delete_file(file){
    var parent = $(file).parent();
    var directory = $(file).attr("upload_id")
    $.ajax({
        type: 'POST',
        url: file_delete_url,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify({
            "directory": String(directory)
        }),
        success: function() {
            $(file).remove();
            if($( parent ).children('div').length == 1){
                $(parent).parent().html("<p id='nouploads'>You don't have any recent uploads.</p>")
            $('.upload_item:nth-last-child(2)').prop('style', 'border-bottom: 2px solid grey; margin-bottom: 0.5rem;')
    }
        },
        error: function() {
            alert('Failed to delete');
        }
    });
}

function pad(str, max){
    str = str.toString();
    return str.length < max ? pad("0" + str, max) : str;
}


$('.timer').each(function(){
    var distance = parseInt(directory_lifetime) - ((Date.now() - new Date($(this).attr('value'))) / 1000);
    upload_list.push([this, distance]);
});

function startTimers(){
    var x = setInterval(function(){
        var keep = [];
        for (i in upload_list){
            var distance = Math.floor(upload_list[i][1]);
            var item = upload_list[i][0];
            
            if (distance < 0) {
                //$(item).text("EXPIRED");
                delete_file($(item).closest('.upload_item'));
            }
            else{
                keep.push(upload_list[i])
                // Find the distance between now and the count down date


                // Time calculations for days, hours, minutes and seconds
                var days = Math.floor(distance / 86400) + 1;

                var hours = pad(Math.floor(distance / 3600), 2);
                var minutes = pad(Math.floor((distance % 3600) / 60), 2);
                var seconds = pad(Math.floor(distance % 60), 2);

                // Output the result in an element with id="demo"
                if (days > 1){
                    $(item).text('Days: ' + days);
                } else {
                    $(item).text(hours + ":"+ minutes + ":" + seconds);
                }
                upload_list[i][1] = upload_list[i][1] - 1;
                // If the count down is over, write some text
            }
        }
        
        upload_list = keep.slice();

        if(upload_list.length == 0){
            clearInterval(x);
        }
    }, 1000);
}

$(document).ready(function(){
    if(upload_list.length > 0){
        startTimers();
    }
});