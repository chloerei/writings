var AlertMessage = {
  loading: function(message, timeout) {
    this.clear();
    $('.alert-message.loading').find('span').text(message).end().removeClass('alert-hide');
    if (timeout) {
      setTimeout(this.clear, timeout);
    }
  },

  error: function(message, timeout) {
    this.clear();
    $('.alert-message.error').find('span').text(message).end().show().removeClass('alert-hide');
    if (timeout) {
      setTimeout(this.clear, timeout);
    }
  },

  success: function(message, timeout) {
    this.clear();
    $('.alert-message.success').find('span').text(message).end().removeClass('alert-hide');
    if (timeout) {
      setTimeout(this.clear, timeout);
    }
  },

  clear: function() {
    $('.alert-message').addClass('alert-hide');
  }
};
