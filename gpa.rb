
$VERBOSE = nil

require 'watir'
require 'html_to_plain_text'
require 'pp'
require 'green_shoes'

Shoes.app(
    width: 170,
    height: 365,
    title: "Get GPA"
) do
  fill rgb(255,127, 80, 0.05)
  stroke rgb(139, 0, 0, 0.2)
  strokewidth 0.25
  animate(50) do
    oval(
        left:   rand(-50..self.width-25),
        top:    rand(-50..self.height-155),
        radius: rand(25..50)
    )
  end

  chrome_proc = Proc.new {

    browser = Watir::Browser.new :chrome

    browser.goto 'powerschool.sas.edu.sg'
    browser.button(value: 'Enter').wait_while_present

    x=HtmlToPlainText.plain_text(browser.tables[2].html).split(/\d\(.\)/)[1..-2]

    y = x.map { | i |
      i = i.split(/\n.*Rm: [^ ]* /)
      i = i[0] + i[1].split(' ')[0]
    }

    scores_ = []
    scores = []

    y.map { | i |
      z = (case i.split(" ")[-1]
             when "A+"; 4.5
             when "A"; 4
             when "B+"; 3.5
             when "B"; 3
             when "C+"; 2.5
             when "C"; 2
             when "D+"; 1.5
             when "D"; 1
             when "F"; 0
           end)

      if !(z.nil?) then scores_.push(z) end

      if i.include? "AP"
        if ["AP Computer Science", "AP Human Geography", "AP Statistics"].any? { | j |
          i.include? j
        }
          z += 0.25
        else
          z += 0.5
        end
      end

      if !(z.nil?) then scores.push(z) end
    }

    $pr = "Unweighted GPA: #{(scores_.reduce(:+) / scores_.length).round(2)}"
    $pr2= "Weighted GPA: #{(scores.reduce(:+) / scores.length).round(2)}"

    caption $pr, top:325,align:'center',font:"Source Sans Pro"
    caption $pr2, top:340,align:'center',font:"Source Sans Pro"

    browser.quit()

  }
  @s = stack do
    tagline(link(strong("PowerSchool Login"), &chrome_proc),
      top:300,
      align:'center',
      font:"Source Sans Pro"
    )
  end
end
