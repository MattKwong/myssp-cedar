
$(document).ready(function() {
    $(document).scrollTop(0);
    $("#survey_submit_first").hover(function() {
        $(this).addClass('hover');
    });
});

$(document).ready(function() {
        $('#survey_submit_first').click(function(){
            var error = 0
            var email_error = 0
            var phone_error = 0
            var zip_error = 0
            if( $('#supporter_first_name').val() == '') {
                $('#supporter_first_name').addClass("survey_error")
                $('#supporter_first_name').focus()
                error++
            } else {
                $('#supporter_first_name').removeClass("survey_error")
            }
            if( $('#supporter_last_name').val() == '') {
                $('#supporter_last_name').addClass("survey_error")
                $('#supporter_last_name').focus()
                error++
            } else {
                $('#supporter_last_name').removeClass("survey_error")
            }
            if( $('#supporter_address1').val() == '') {
                $('#supporter_address1').addClass("survey_error")
                $('#supporter_address1').focus()
                error++
            } else {
                $('#supporter_address1').removeClass("survey_error")
            }
            if( $('#supporter_city').val() == '') {
                $('#supporter_city').addClass("survey_error")
                $('#supporter_city').focus()
                error++
            } else {
                $('#supporter_city').removeClass("survey_error")
            }
            if( $('#supporter_state').val() == '') {
                $('#supporter_state').addClass("survey_error")
                $('#supporter_state').focus()
                error++
            } else {
                $('#supporter_state').removeClass("survey_error")
            }
            if( $('#supporter_zip').val() == '') {
                $('#supporter_zip').addClass("survey_error")
                $('#supporter_zip').focus()
                error++
            } else {
                $('#supporter_zip').removeClass("survey_error")
            }
//        if( $('#supporter_phone').val() == '') {
//            $('#supporter_phone').addClass("survey_error")
//            $('#supporter_phone').focus()
//            error++
//        } else {
//            $('#supporter_phone').removeClass("survey_error")
//        }
////
//        if( $('#supporter_phone_type').val() == '') {
//            $('#supporter_phone_type').addClass("survey_error")
//            $('#supporter_phone_type').focus()
//            error++
//        } else {
//            $('#supporter_phone_type').removeClass("survey_error")
//        }
            if( $('#supporter_email').val() == '') {
                $('#supporter_email').addClass("survey_error")
                $('#supporter_email').focus()
                error++
            } else {
                $('#supporter_email').removeClass("survey_error")
            }
            if( $('#supporter_gender').val() == '') {
                $('#supporter_gender').addClass("survey_error")
                $('#supporter_gender').focus()
                error++
            } else {
                $('#supporter_gender').removeClass("survey_error")
            }

            if (!error) {
                // Check zip code
                if ( $('#supporter_zip').val().length < 5 || !($.isNumeric($('#supporter_zip').val()) )) {
                    $('#supporter_zip').addClass("survey_error");
                    $('#supporter_zip').focus();
                    zip_error++;
                    alert("Please enter a valid 5-digit zip code.")
                } else {
                    $('#supporter_zip').removeClass("survey_error")
                }
            }
            if (!error && !zip_error) {
                // Check email format
                if( !validateEmail($('#supporter_email').val())) {
                    $('#supporter_email').addClass("survey_error")
                    $('#supporter_email').focus()
                    email_error++;
                    alert("This does not appear to be a valid email address.")
                } else {
                    $('#supporter_email').removeClass("survey_error")
                }
            }

            if (!error && !email_error && !zip_error ) {
                // Check phone format
                if( !$('#supporter_phone').val() == '') {
                    if( !validatePhone($('#supporter_phone').val())) {
                        $('#supporter_phone').addClass("survey_error");
                        $('#supporter_phone').focus();
                        phone_error++;
                        alert("Please enter a phone number in the format 111-222-3333.")
                    } else {
                        $('#supporter_phone').removeClass("survey_error")
                    }
                }
            }
            if (error) {
                alert("The highlighted fields are required. Please complete them and press Continue.")
            }

            if (!error && !email_error && !phone_error && !zip_error) {
                $('#progress_text').html('20% Complete');
                $('#progress').css('width','68px');
                //slide steps
                $('#section1').slideUp();
                $('#section2').slideDown();
                $(document).scrollTop(0);
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

function validateEmail($email) {
    email_error = 0
    var emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
    if( !emailReg.test( $email ) ) {
        email_error++
        return false;
    } else {
        return true;
    }
}
function validatePhone($phone) {
    phone_error = 0
    var phoneReg = /1?\s*\W?\s*([2-9][0-8][0-9])\s*\W?\s*([2-9][0-9]{2})\s*\W?\s*([0-9]{4})(\se?x?t?(\d*))?/;
    if( !phoneReg.test( $phone ) ) {
        phone_error++
        return false;
    } else {
        return true;
    }
}
