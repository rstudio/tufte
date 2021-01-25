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

# put references in margin when link-citations: yes

    Code
      margin_references(x)
    Output
      [1] "<p>See <span class=\"citation\">(<label for=\"tufte-mn-\" class=\"margin-toggle\">&#8853;</label><input type=\"checkbox\" id=\"tufte-mn-\" class=\"margin-toggle\">Xie 2020<span class=\"marginnote\">Xie, Yihui. 2020. <em>Knitr: A General-Purpose Package for Dynamic Report Generation in r</em>. <a href=\"https://yihui.org/knitr/\">https://yihui.org/knitr/</a>.</span>)</span>.</p>"                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
      [2] "<p>See <span class=\"citation\"><label for=\"tufte-mn-\" class=\"margin-toggle\">&#8853;</label><input type=\"checkbox\" id=\"tufte-mn-\" class=\"margin-toggle\">Xie (2020)<span class=\"marginnote\">Xie, Yihui. 2020. <em>Knitr: A General-Purpose Package for Dynamic Report Generation in r</em>. <a href=\"https://yihui.org/knitr/\">https://yihui.org/knitr/</a>.</span></span></p>"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
      [3] "<p>See <span class=\"citation\"><label for=\"tufte-mn-\" class=\"margin-toggle\">&#8853;</label><input type=\"checkbox\" id=\"tufte-mn-\" class=\"margin-toggle\">Xie (2020)<span class=\"marginnote\">Xie, Yihui. 2020. <em>Knitr: A General-Purpose Package for Dynamic Report Generation in r</em>. <a href=\"https://yihui.org/knitr/\">https://yihui.org/knitr/</a>.</span></span> and <span class=\"citation\"><label for=\"tufte-mn-\" class=\"margin-toggle\">&#8853;</label><input type=\"checkbox\" id=\"tufte-mn-\" class=\"margin-toggle\">Xie, Allaire, and Grolemund (2018)<span class=\"marginnote\">Xie, Yihui, J. J. Allaire, and Garrett Grolemund. 2018. <em>R Markdown: The Definitive Guide</em>. Boca Raton, Florida: Chapman; Hall/CRC. <a href=\"https://bookdown.org/yihui/rmarkdown\">https://bookdown.org/yihui/rmarkdown</a>.</span></span></p>"
      [4] "<p>See <span class=\"citation\">(<label for=\"tufte-mn-\" class=\"margin-toggle\">&#8853;</label><input type=\"checkbox\" id=\"tufte-mn-\" class=\"margin-toggle\">Xie 2020<span class=\"marginnote\">Xie, Yihui. 2020. <em>Knitr: A General-Purpose Package for Dynamic Report Generation in r</em>. <a href=\"https://yihui.org/knitr/\">https://yihui.org/knitr/</a>.</span>)</span> and <span class=\"citation\">(<label for=\"tufte-mn-\" class=\"margin-toggle\">&#8853;</label><input type=\"checkbox\" id=\"tufte-mn-\" class=\"margin-toggle\">Xie, Allaire, and Grolemund 2018<span class=\"marginnote\">Xie, Yihui, J. J. Allaire, and Garrett Grolemund. 2018. <em>R Markdown: The Definitive Guide</em>. Boca Raton, Florida: Chapman; Hall/CRC. <a href=\"https://bookdown.org/yihui/rmarkdown\">https://bookdown.org/yihui/rmarkdown</a>.</span>)</span></p>"

---

    Code
      margin_references(x)
    Output
       [1] "<p>See <span class=\"citation\">(Xie 2020)</span>.</p>"                                                                                                                                                                               
       [2] "<p>See <span class=\"citation\">Xie (2020)</span></p>"                                                                                                                                                                                
       [3] "<p>See <span class=\"citation\">Xie (2020)</span> and <span class=\"citation\">Xie, Allaire, and Grolemund (2018)</span></p>"                                                                                                         
       [4] "<p>See <span class=\"citation\">(Xie 2020)</span> and <span class=\"citation\">(Xie, Allaire, and Grolemund 2018)</span></p>"                                                                                                         
       [5] "<div id=\"refs\" class=\"references csl-bib-body hanging-indent\">"                                                                                                                                                                   
       [6] "<div id=\"ref-R-knitr\" class=\"csl-entry\">"                                                                                                                                                                                         
       [7] "Xie, Yihui. 2020. <em>Knitr: A General-Purpose Package for Dynamic Report Generation in r</em>. <a href=\"https://yihui.org/knitr/\">https://yihui.org/knitr/</a>."                                                                   
       [8] "</div>"                                                                                                                                                                                                                               
       [9] "<div id=\"ref-rmarkdown2018\" class=\"csl-entry\">"                                                                                                                                                                                   
      [10] "Xie, Yihui, J. J. Allaire, and Garrett Grolemund. 2018. <em>R Markdown: The Definitive Guide</em>. Boca Raton, Florida: Chapman; Hall/CRC. <a href=\"https://bookdown.org/yihui/rmarkdown\">https://bookdown.org/yihui/rmarkdown</a>."
      [11] "</div>"                                                                                                                                                                                                                               
      [12] "</div>"                                                                                                                                                                                                                               

