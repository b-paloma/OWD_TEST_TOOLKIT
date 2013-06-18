from OWDTestToolkit.global_imports import *

import  app         ,\
        debug       ,\
        element     ,\
        general     ,\
        home        ,\
        iframe      ,\
        network     ,\
        reporting   ,\
        statusbar   ,\
        test


class UTILS(app.main        ,
            debug.main      ,
            element.main    ,
            general.main    ,
            home.main       ,
            iframe.main     ,
            network.main    ,
            reporting.main  ,
            statusbar.main  ,
            test.main):
    #
    # When you create your instance of this class, include the
    # "self" object so we can access the calling class' objects.
    #
    def __init__(self, p_parent):
        self.parent         = p_parent
        self.device         = p_parent.device
        self.data_layer     = p_parent.data_layer
        self.apps           = p_parent.apps
        self.marionette     = p_parent.marionette
        self.actions        = Actions(self.marionette)

        #
        # Globals used for reporting ...
        #
        self._resultArray   = []
        self._commentArray  = []
        self.errNum         = 0
        self.passed         = 0
        self.failed         = 0
        self.start_time     = time.time()
        self.last_timestamp = time.time()
        
        #
        # Other globals ...
        #
        self._DEFAULT_ELEMENT_TIMEOUT = 5

        #
        # Get run details from the OS.
        #
        self.testNum        = self.get_os_variable("TEST_NUM")
        self.det_fnam       = self.get_os_variable("DET_FILE")
        self.sum_fnam       = self.get_os_variable("SUM_FILE")        
        try:
            self.testDesc   = self.parent._Description
        except:
            self.testDesc   = "(no description found!)"
        

        #
        # Set device defaults.
        #
        self.data_layer.set_setting("vibration.enabled", True)
        self.data_layer.set_setting("audio.volume.notification", 0)
        self.data_layer.set_setting('ril.radio.disabled', False)

        self.apps.set_permission('Camera', 'geolocation', 'deny')
        self.apps.set_permission('Homescreen', 'geolocation', 'deny')

        self.marionette.set_search_timeout(20)

        self.setTimeToNow()
        
        self.setupDataConn()
         
        #
        # Unlock (if necessary).
        #
        self.parent.lockscreen.unlock()