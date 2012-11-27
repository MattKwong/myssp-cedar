prawn_document() do |pdf|
    logopath = ::Rails.root.join('public','logo.png')
    pdf.image logopath, :width => 80, :height => 80

    pdf.text "Statement", :align => :center, :style => :bold, :size => 20
    pdf.text "Sierra Service Project"
    pdf.text "PO Box 992"
    pdf.move_up(16)
    pdf.text "Date: #{Date.today}", :align => :right, :style => :bold
    pdf.text "Carmichael, CA 95609"
    pdf.text "916-488-6441"

    pdf.move_down(20)
    pdf.text "Bill To:", :style => :bold
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
    pdf.move_down(30)
    items = Array.new
    items[0] = ["","Number", "Amount Per", "Total Amount"]
    items[1] = ["Deposits", @group.overall_high_water, number_to_currency(@group.session.payment_schedule.deposit),
            number_to_currency(@group.deposit_amount)]

    pdf.table(items, :header => true,
            :column_widths => {0 => 60, 1 => 170, 2 => 150, 3 => 70, 4 => 70 },
            :row_colors => ["F0F0F0", "FFFFCC"] ) do
            cells.size = 10
             row(0).style :align => :left
            column(1).style :align => :left
            column(2).style :align => :left
            column(3).style :align => :right
            column(4).style :align => :right
    end

    pdf.move_down(20)
    pdf.text "If you have any questions about this statement call the SSP office at 916-488-6441."
end
