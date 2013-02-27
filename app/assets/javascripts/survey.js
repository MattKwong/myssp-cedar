
$(document).ready(function() {
    $(document).scrollTop(0);
    $("#survey_submit_first").hover(function() {
        $(this).addClass('hover');
    });
});

$(document).ready(function() {
    $('#survey_submit_first').click(function(){
        var error = 0
        if( $('#supporter_first_name').val() == '') {
            $('#supporter_first_name').addClass("survey_error")
            $('#supporter_first_name').focus()
            error++
        }
        if( $('#supporter_last_name').val() == '') {
            $('#supporter_last_name').addClass("survey_error")
            $('#supporter_last_name').focus()
            error++
        }
        if( $('#supporter_address1').val() == '') {
            $('#supporter_address1').addClass("survey_error")
            $('#supporter_address1').focus
            error++
        }
        if( $('#supporter_city').val() == '') {
            $('#supporter_city').addClass("survey_error")
            $('#supporter_city').focus
            error++
        }
        if( $('#supporter_state').val() == '') {
            $('#supporter_state').addClass("survey_error")
            $('#supporter_state').focus
            error++
        }
        if( $('#supporter_zip').val() == '') {
            $('#supporter_zip').addClass("survey_error")
            $('#supporter_zip').focus
            error++
        }
        if( $('#supporter_phone').val() == '') {
            $('#supporter_phone').addClass("survey_error")
            $('#supporter_phone').focus
            error++
        }
//

        if( $('#supporter_phone_type').val() == '') {
            $('#supporter_phone_type').addClass("survey_error")
            $('#supporter_phone_type').focus()
            error++
        }
        if( $('#supporter_email').val() == '') {
            $('#supporter_email').addClass("survey_error")
            $('#supporter_phone_type').focus()
            error++
        }
// Check email format

        if( $('#supporter_gender').val() == '') {
            $('#supporter_gender').addClass("survey_error")
            $('#supporter_gender').focus()
            error++
        }

        if (!error) {
            $('#progress_text').html('20% Complete');
            $('#progress').css('width','68px');
            //slide steps
            $('#section1').slideUp();
            $('#section2').slideDown();
            $(document).scrollTop(0);
        } else {
            alert("The highlighted fields are required. Please complete them and press Continue.")
        }
    });
});


$(document).ready(function() {
    $("#survey_submit_second").hover(function() {
        $(this).addClass('hover');
    });
});

$(document).ready(function() {
    $('#survey_submit_second').click(function(){
        $('#progress_text').html('40% Complete');
        $('#progress').css('width','134px');
        //slide steps
        $('#section2').slideUp();
        $('#section3').slideDown();
        $(document).scrollTop(0);
    });
});
$(document).ready(function() {
    $('#survey_back_second').click(function(){
        $('#progress_text').html('20% Complete');
        $('#progress').css('width','68px');
        //slide steps
        $('#section2').slideUp();
        $('#section1').slideDown();
        $(document).scrollTop(0);
    });
});

$(document).ready(function() {
    $('#survey_submit_third').click(function(){
        $('#progress_text').html('60% Complete');
        $('#progress').css('width','202px');
        //slide steps
        $('#section3').slideUp();
        $('#section4').slideDown();
        $(document).scrollTop(0);
    });
});

$(document).ready(function() {
    $('#survey_back_third').click(function(){
        $('#progress_text').html('20% Complete');
        $('#progress').css('width','68px');
        //slide steps
        $('#section3').slideUp();
        $('#section2').slideDown();
        $(document).scrollTop(0);
    });
});

$(document).ready(function() {
    $('#survey_submit_fourth').click(function(){
        $('#progress_text').html('80% Complete');
        $('#progress').css('width','270px');
        //slide steps
        $('#section4').slideUp();
        $('#section5').slideDown();
        $(document).scrollTop(0);
    });
});
$(document).ready(function() {
    $('#survey_back_fourth').click(function(){
        $('#progress_text').html('40% Complete');
        $('#progress').css('width','134px');
        //slide steps
        $('#section4').slideUp();
        $('#section3').slideDown();
        $(document).scrollTop(0);
    });
});
$(document).ready(function() {
    $('#survey_back_fifth').click(function(){
        $('#progress_text').html('60% Complete');
        $('#progress').css('width','202px');
        //slide steps
        $('#section5').slideUp();
        $('#section4').slideDown();
        $(document).scrollTop(0);
    });
});