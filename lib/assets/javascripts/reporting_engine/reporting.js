/*jslint white: false, nomen: true, devel: true, on: true, debug: false, evil: true, onevar: false, browser: true, white: false, indent: 2 */
/*global window, $, $$, Reporting, Element */

window.Reporting = {
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
