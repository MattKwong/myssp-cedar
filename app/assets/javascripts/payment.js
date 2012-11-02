var cc_processing_charge = 0;
var cc_payment_amount = 0;
var cc_to_be_charged = 0;
var group_status;

$(document).ready(function() {
    $("input[name=include_cc_charge]").attr("disabled", "disabled");
});

$(document).ready(function() {
    $("#pay_cc_now").hover(function() {
        $(this).addClass('hover');
    });
});

$(document).ready(function() {
    $("input[name=include_cc_charge]").click(function(){
        //Pull the deposit_amount and processing_charge
        if ($(this).is(':checked')) {
            cc_processing_charge = (parseFloat($("input[name=cc_payment_amount]").val()) * .029).toFixed(2);
        } else {
            cc_processing_charge = 0;
        }

        cc_to_be_charged = (parseFloat(cc_payment_amount) + parseFloat(cc_processing_charge));

        $("td#cc_processing_charge").html("$" + cc_processing_charge);
        $("td#cc_to_be_charged").html("$" + cc_to_be_charged);
    });
});
$(document).ready(function() {
    $('input[name=cc_payment_amount]').change(function(){
        //Pull the deposit_amount and processing_charge
        $("input[name=include_cc_charge]").removeAttr("disabled");
        cc_payment_amount = $('input[name=cc_payment_amount]').val();;
        if ($.isNumeric(cc_payment_amount)) {

            cc_to_be_charged = (parseFloat(cc_payment_amount) + parseFloat(cc_processing_charge));
            $("td#cc_processing_charge").html("$" + cc_processing_charge.toFixed(2));
            $("td#cc_to_be_charged").html("$" + cc_to_be_charged.toFixed(2));
            $("#cc_payment_errors").html("");
            $('#pay_cc_now').removeAttr("disabled");

        } else {
            $("#cc_payment_errors").html("Please input a valid number - no $ or characters.");
            $("input[name=cc_payment_amount]").addClass("error");
            $('#pay_now').attr("disabled", "disabled");
        }
    });
});

$(document).ready(function() {
    $("#pay_cc_now").click(function(event) {
        // disable the submit button to prevent repeated clicks
        $('#pay_cc_now').attr("disabled", "disabled");
        // createToken returns immediately - the supplied callback submits the form if there are no errors

        Stripe.createToken({
            number: $('.card-number').val(),
            cvc: $('.card-cvc').val(),
            exp_month: $('.card-expiry-month').val(),
            exp_year: $('.card-expiry-year').val()
        }, stripePaymentResponseHandler);
        return false; // submit from callback
    });
});

function stripePaymentResponseHandler(status, response) {
    if (response.error) {
        // re-enable the submit button
        $('#pay_cc_now').removeAttr("disabled");
        // show the errors on the form
        $("#cc_payment_errors").html(response.error.message);
    } else {
        // token contains id, last4, and card type
        var token = response['id'];
        // and submit
        group_status = $("input[name=group_status]").val();
        payment_comments = $("input[name=payment_comments]").val();
        registration_id = $("input[name=registration_id]").val();
        $.get("process_cc_payment?reg_id=" + registration_id + "&payment_amount=" + cc_payment_amount
            + "&amount_paid=" + cc_to_be_charged + "&processing_charge=" + cc_processing_charge + "&payment_tracking_number="
            + token + "&payment_comments=" + payment_comments + "&group_status=" + group_status,  function(data) {

            $("#gateway_data").html(data);
            var error_message = $("input[name=gateway_error]").val();
            if (error_message) {
                $("#cc_payment_errors").html(error_message);
            } else {
                table_html += "<tr><td>Payment Amount</td><td>";
                table_html += "$" + parseFloat(cc_payment_amount).toFixed(2);
                table_html += "<tr><td>Processing Charge</td><td>";
                table_html += "$" + parseFloat(cc_processing_charge).toFixed(2);
                table_html += "<tr><td>Amount paid</td><td>";
                table_html += "$" + parseFloat(cc_to_be_charged).toFixed(2);
                table_html += "</td></tr>";
                table_html += "<tr><td>Receipt id</td><td>";
                table_html += token;
                table_html += "</td></tr>";
                $('#final_confirmation_table').append(table_html);
                //slide steps
                $('#cc_payment_step').slideUp();
                $('#confirmation_step').slideDown();
            };

        });

    };
}
