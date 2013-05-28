/*jslint white: false, nomen: true, devel: true, on: true, debug: false, evil: true, onevar: false, browser: true, white: false, indent: 2 */
/*global window, $, $$, Reporting, Element */

window.Reporting = {
  source: ($$("head")[0].select("script[src*='reporting.js']")[0].src),

  require: function (libraryName) {
    var jsName = Reporting.source.replace("reporting.js", "reporting/" + libraryName + ".js");
    try {
      // inserting via DOM fails in Safari 2.0, so brute force approach
      document.write('<script type="text/javascript" src="' + jsName + '"><\/script>');
    } catch (e) {
      // for xhtml+xml served content, fall back to DOM methods
      var script = document.createElement('script');
      script.type = 'text/javascript';
      script.src = jsName;
      document.getElementsByTagName('head')[0].appendChild(script);
    }
  },

  onload: function (func) {
    document.observe("dom:loaded", func);
  },

  flash: function (string, type) {
    if (type === undefined) {
      type = "error";
    }

    if ($("flash_" + type) !== null) {
      $("flash_" + type).remove();
    }

    var flash = new Element('div', {
      'id': 'flash_' + type,
      'class': 'flash ' + type
    }).update(new Element('a', {
      'href': '#'
    }).update(string));

    $("content").insert({top: flash});
    $$("#flash_" + type + " a")[0].focus();
  },

  clearFlash: function () {
    $$('div[id^=flash]').each(function (oldMsg) {
      oldMsg.remove();
    });
  },

  fireEvent: function (element, event) {
    var evt;
    if (document.createEventObject) {
      // dispatch for IE
      evt = document.createEventObject();
      return element.fireEvent('on' + event, evt);
    } else {
      // dispatch for firefox + others
      evt = document.createEvent("HTMLEvents");
      evt.initEvent(event, true, true); // event type,bubbling,cancelable
      return !element.dispatchEvent(evt);
    }
  }
};

Reporting.require("filters");
Reporting.require("group_bys");
Reporting.require("restore_query");
Reporting.require("controls");
Reporting.require("prototype_progress_bar");
Reporting.require("progressbar");

