var AlertMessage = {
  loading: function(message) {
    this.clear();
    $('.alert-message.loading').find('span').text(message).end().show().removeClass('hide');
  },

  error: function(message) {
    this.clear();
    $('.alert-message.error').find('span').text(message).end().show().removeClass('hide');
  },

  success: function(message) {
    this.clear();
    $('.alert-message.success').find('span').text(message).end().removeClass('hide');
  },

  clear: function() {
    $('.alert-message').addClass('hide');
  }
};
