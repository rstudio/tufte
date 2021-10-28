# put references in margin when link-citations: yes

    Code
      margin_references(x)
    Output
      [1] "<p>See <span class=\"citation\">(Xie <label for=\"tufte-mn-\" class=\"margin-toggle\">&#8853;</label><input type=\"checkbox\" id=\"tufte-mn-\" class=\"margin-toggle\">2020a)<span class=\"marginnote\">Xie, Yihui. 2020a. <em>Knitr: A General-Purpose Package for Dynamic Report Generation in R</em>.</span></span>.</p>"                                                                                                                                                                                                                                                                                                                                                                                    
      [2] "<p>See <span class=\"citation\">Xie (<label for=\"tufte-mn-\" class=\"margin-toggle\">&#8853;</label><input type=\"checkbox\" id=\"tufte-mn-\" class=\"margin-toggle\">2020b)<span class=\"marginnote\">Xie, Yihui. 2020b. <em>Knitr: A General-Purpose Package for Dynamic Report Generation in R - Duplicate</em>.</span></span></p>"                                                                                                                                                                                                                                                                                                                                                                         
      [3] "<p>See <span class=\"citation\">Xie (<label for=\"tufte-mn-\" class=\"margin-toggle\">&#8853;</label><input type=\"checkbox\" id=\"tufte-mn-\" class=\"margin-toggle\">2020a)<span class=\"marginnote\">Xie, Yihui. 2020a. <em>Knitr: A General-Purpose Package for Dynamic Report Generation in R</em>.</span></span> and <span class=\"citation\">Xie, Allaire, and Grolemund (<label for=\"tufte-mn-\" class=\"margin-toggle\">&#8853;</label><input type=\"checkbox\" id=\"tufte-mn-\" class=\"margin-toggle\">2018<span class=\"marginnote\">Xie, Yihui, J. J. Allaire, and Garrett Grolemund. 2018. <em>R Markdown: The Definitive Guide</em>. Boca Raton, Florida: Chapman; Hall/CRC.</span>)</span></p>"
      [4] "<p>See <span class=\"citation\">(Xie <label for=\"tufte-mn-\" class=\"margin-toggle\">&#8853;</label><input type=\"checkbox\" id=\"tufte-mn-\" class=\"margin-toggle\">2020a)<span class=\"marginnote\">Xie, Yihui. 2020a. <em>Knitr: A General-Purpose Package for Dynamic Report Generation in R</em>.</span></span> and <span class=\"citation\">(Xie, Allaire, and Grolemund <label for=\"tufte-mn-\" class=\"margin-toggle\">&#8853;</label><input type=\"checkbox\" id=\"tufte-mn-\" class=\"margin-toggle\">2018<span class=\"marginnote\">Xie, Yihui, J. J. Allaire, and Garrett Grolemund. 2018. <em>R Markdown: The Definitive Guide</em>. Boca Raton, Florida: Chapman; Hall/CRC.</span>)</span></p>"

---

    Code
      margin_references(x)
    Output
       [1] "<p>See <span class=\"citation\">(Xie 2020a)</span>.</p>"                                                                                          
       [2] "<p>See <span class=\"citation\">Xie (2020b)</span></p>"                                                                                           
       [3] "<p>See <span class=\"citation\">Xie (2020a)</span> and <span class=\"citation\">Xie, Allaire, and Grolemund (2018)</span></p>"                    
       [4] "<p>See <span class=\"citation\">(Xie 2020a)</span> and <span class=\"citation\">(Xie, Allaire, and Grolemund 2018)</span></p>"                    
       [5] "<div id=\"refs\" class=\"references\">"                                                                                                           
       [6] "<div id=\"ref-R-knitr\">"                                                                                                                         
       [7] "<p>Xie, Yihui. 2020a. <em>Knitr: A General-Purpose Package for Dynamic Report Generation in R</em>.</p>"                                          
       [8] "</div>"                                                                                                                                           
       [9] "<div id=\"ref-R-knitr2\">"                                                                                                                        
      [10] "<p>———. 2020b. <em>Knitr: A General-Purpose Package for Dynamic Report Generation in R - Duplicate</em>.</p>"                                     
      [11] "</div>"                                                                                                                                           
      [12] "<div id=\"ref-rmarkdown2018\">"                                                                                                                   
      [13] "<p>Xie, Yihui, J. J. Allaire, and Garrett Grolemund. 2018. <em>R Markdown: The Definitive Guide</em>. Boca Raton, Florida: Chapman; Hall/CRC.</p>"
      [14] "</div>"                                                                                                                                           
      [15] "</div>"                                                                                                                                           

