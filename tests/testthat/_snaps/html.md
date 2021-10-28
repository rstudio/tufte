# add marginnote

    Code
      marginnote_html("text")
    Output
      [1] "<label for=\"tufte-mn-\" class=\"margin-toggle\">&#8853;</label><input type=\"checkbox\" id=\"tufte-mn-\" class=\"margin-toggle\">text"

---

    Code
      marginnote_html("text", "#")
    Output
      [1] "<label for=\"tufte-mn-\" class=\"margin-toggle\">#</label><input type=\"checkbox\" id=\"tufte-mn-\" class=\"margin-toggle\">text"

