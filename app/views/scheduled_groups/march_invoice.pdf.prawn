prawn_document() do |pdf|
    logopath = ::Rails.root.join('public','logo.png')
    pdf.image logopath, :width => 80, :height => 80
    pdf.move_down(20)

    pdf.text "Sierra Service Project"
    pdf.move_up(16)
    pdf.text "MARCH INVOICE", :align => :right, :style => :bold
    pdf.text "PO Box 992"
    pdf.move_up(16)
    pdf.text "Date: #{Date.today}", :align => :right, :style => :bold
    pdf.text "Carmichael, CA 95609"
    pdf.text "916-488-6441"

    pdf.move_down(30)
    pdf.text "Bill To:", :style => :bold
    pdf.move_up(15)
    pdf.text "Please return a copy of this invoice with your payment", :style => :bold, :align => :right
    pdf.text @group.liaison.name
    pdf.text @group.church.name
    pdf.move_up(15)
    pdf.text "Site: #{@group.session.site.name}", :align => :right
    pdf.text @group.church.address1
    pdf.move_up(15)
    pdf.text "Period: #{@group.session.period.name} (#{@group.session.period.start_date.strftime("%m/%d/%y")} - #{@group.session.period.end_date.strftime("%m/%d/%y")})", :align => :right
    pdf.text "#{@group.church.city}, #{@group.church.state} #{@group.church.zip}"
    pdf.move_up(15)
    pdf.text "Group Name: #{@group.name}", :align => :right
    pdf.move_down(60)
    items = Array.new
    i = 0
    items[i] = ["","Number Registered", "Amount Per Person", "Total Amount Due"]
    i += 1
    items[i] = ["Deposits", @group.overall_high_water, number_to_currency(@group.session.payment_schedule.deposit),
            number_to_currency(@group.deposit_amount)]
    i += 1
    items[i] = ["2nd Payments", @group.second_half_high_water, number_to_currency(@group.session.payment_schedule.second_payment),
            number_to_currency(@group.second_pay_amount)]
    i += 1
    @group.adjustments.each { |a|
        items[i] = ["Adjustment: #{a.adjustment_code.short_name} (#{a.created_at.strftime("%m/%d/%Y")})", "", "", number_to_currency(-a.amount)]
        i += 1
    }
    items[i] = ["Total", "", "", number_to_currency(@group.total_due)]
    i += 1
    items[i] = ["Paid to Date", "", "", number_to_currency(-@group.fee_amount_paid)]
    i += 1
    items[i] = ["Second Payment Late Charge", "", "", number_to_currency(@group.second_late_penalty_amount)]
    i += 1
    items[i] = ["Current Balance Due", "", "", number_to_currency(@group.current_balance_march)]

    pdf.table(items, :header => true,
            :column_widths => {0 => 120, 1 => 140, 2 => 140, 3 => 140},
            :row_colors => ["F0F0F0", "FFFFCC"] ) do
            cells.size = 10
             row(0).style :align => :left
            column(1).style :align => :left
            column(2).style :align => :left
            column(3).style :align => :right
            column(4).style :align => :right
    end

    pdf.move_down(60)
    pdf.text "If you have any questions about this invoice call the SSP office at 916-488-6441."
end