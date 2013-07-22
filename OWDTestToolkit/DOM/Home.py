frame_locator        = ("src", "homescreen")
cards_view           = ('id', 'cards-view')
lockscreen_frame     = ('id', 'lockscreen')
dock                 = ("class name", "dockWrapper")

app_icon_css         = 'li.icon[aria-label="%s"]'
# app_delete_icon      = ('css selector', 'span.options')
app_delete_icon_xpath= "//li[@class='icon'][.//span[text()='%s']]//span[@class='options']"
app_confirm_delete   = ('id', 'confirm-dialog-confirm-button')

app_card             = ('css selector', '#cards-view li.card[data-origin*="%s"]')
app_cards            = ('css selector', '#cards-view li.card')
#app_card             = ('xpath', '//*[@data-origin="app://%s.gaiamobile.org"]')
app_close            = ('css selector', '#cards-view li.card[data-origin*="%s"] .close-card')

datetime_time_xpath  = "//p[@id='landing-clock']//span[@class='numbers' and text()='%s']"
datetime_ampm_xpath  = "//p[@id='landing-clock']//span[@class='meridiem' and text()='%s']"
datetime_date_xpath  = "//div[@id='landing-time']//p[@id='landing-date' and text()='%s']"

