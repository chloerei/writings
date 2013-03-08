//= require editor

Editor.Formator.prototype.link = function(url) {
  this.editor.restoreRange();

  if (url !== undefined) {
    if (this.isWraped('a')) {
      document.getSelection().selectAllChildren($(this.commonAncestorContainer()).closest('a')[0]);
    }
    if (url !== '') {
      if (!/^http/.test(url)) {
        url = 'http://' + url;
      }
      this.exec('createLink', url);
    } else {
      this.exec('unlink');
    }
    Dialog.hide('#link-modal');
  } else {
    var link = '';
    if (this.isWraped('a')) {
      link = $(this.commonAncestorContainer()).closest('a').attr('href');
    }
    Dialog.show('#link-modal');
    $('#link-modal').find('input[name=url]').val(link).focus();
  }
};

Editor.Formator.prototype.image = function(url) {
  this.editor.restoreRange();

  if (url !== undefined) {
    if (!/^http/.test(url)) {
      url = 'http://' + url;
    }
    this.exec('insertImage', url);
    Dialog.hide('#image-modal');
  } else {
    Dialog.show('#image-modal');
    $('#image-modal').find('input[name=url]').val('').focus();
  }
};

var ArticleEdit = function() {
  this.editor = new Editor({
    toolbar: '#toolbar',
    editable: '#editarea article'
  });

  this.article = $('#editarea article');

  this.connect('#urlname-form', 'submit', this.saveUrlname);
  this.connect('#save-button', 'click', this.saveArticle);
  this.connect('#publish-button', 'click', this.publishArticle);
  this.connect('#draft-button', 'click', this.draftArticle);
  this.connect('#category-form', 'submit', this.saveCategory);
  this.connect('#new-category-form', 'submit', this.createCategory);
  this.connect('#pick-up-button', 'click', this.pickUpTopbar);

  $('#category-form .dropdown').on('click', '.dropdown-menu li a', this.selectCategory);

  var _this = this;

  if (this.article.hasClass('init')) {
    this.editor.formator.h1();
    this.article.one('input', function() {
      _this.article.removeClass('init');
    });
  }

  $('#link-form').on('submit', function(event) {
    event.preventDefault();
    _this.editor.formator.link($(this).find('input[name=url]').val());
  });

  $('#unlink-button').on('click', function(event) {
    event.preventDefault();
    _this.editor.formator.link('');
  });

  $('#image-form').on('submit', function(event) {
    event.preventDefault();
    _this.editor.formator.image($(this).find('input[name=url]').val());
  });

  Mousetrap.bind(['ctrl+s', 'command+s'], function(event) {
    _this.saveArticle(event);
  });
  Mousetrap.bind(['ctrl+m', 'command+m'], function(event) {
    event.preventDefault();
    if ($('#help-modal').is(':hidden')) {
      Dialog.show('#help-modal');
    } else {
      Dialog.hide('#help-modal');
    }
  });
};

ArticleEdit.prototype = {
  connect: function(element, event, fn) {
    var _this = this;
    $(element).on(event, function(event) {
      fn.call(_this, event, this);
    });
  },

  isPersisted: function() {
    return !!this.article.data('id');
  },

  updateArticle: function(data, success_callback, error_callback) {
    var _this = this;
    AlertMessage.loading('Saving...');
    $.ajax({
      url: '/articles/' + this.article.data('id'),
      data: data,
      type: 'put',
      dataType: 'json'
    }).success(function(data) {
      AlertMessage.clear();
      if (success_callback) {
        success_callback(data);
      }
      _this.updateViewButton(data);
    }).error(function() {
      AlertMessage.error('Save Failed.');
      if (error_callback) {
        error_callback();
      }
    });
  },

  saveUrlname: function(event) {
    event.preventDefault();
    var urlname = $('#article-urlname').val();
    if (this.isPersisted()) {
      this.updateArticle($('#urlname-form').serializeArray(), function(data) {
        Dialog.hide('#urlname-modal');
      });
    } else {
      this.article.data('urlname', urlname);
      Dialog.hide('#urlname-modal');
    }
  },

  saveCategory: function(event) {
    event.preventDefault();
    var categoryId = $('#article-category-id').val();
    var categoryName = $('#category-form .dropdown-toggle').text();
    var _this = this;
    if (this.isPersisted()) {
      this.updateArticle($('#category-form').serializeArray(), function(data) {
        _this.article.data('category-id', categoryId);
        Dialog.hide('#select-category-modal');
      });
    } else {
      this.article.data('category-id', categoryId);
      Dialog.hide('#select-category-modal');
    }
  },

  createCategory: function(event) {
    event.preventDefault();
    $.ajax({
      url: '/categories/',
      data: $('#new-category-form').serializeArray(),
      type: 'post',
      dataType: 'json'
    }).success(function(data) {
      var $li = $('<li><a href="#">');
      $li.find('a').text(data.name).data('category-id', data.urlname);
      $('#category-form .dropdown-menu').prepend($li);
      $('#category-form .dropdown-toggle').text(data.name);
      $('#article-category-id').val(data.urlname);
      Dialog.hide('#new-category-modal');
    });
  },

  selectCategory: function(event) {
    event.preventDefault();
    var $item = $(this);
    $item.closest('.dropdown').find('.dropdown-toggle').text($item.text());
    $('#article-category-id').val($item.data('category-id'));
  },

  saveArticle: function(event) {
    event.preventDefault();
    if (this.isPersisted()) {
      this.updateArticle({
        article: {
          title: this.extractTitle(),
          body: this.editor.editable.html()
        }
      });
    } else {
      this.createArticle();
    }

    document.title = this.extractTitle() || 'Untitle';
  },

  extractTitle: function() {
    return this.editor.editable.find('h1').text();
  },

  createArticle: function() {
    var _this = this;
    AlertMessage.loading('Saving...');
    $.ajax({
      url: '/articles',
      data: {
        article: {
          title: this.editor.editable.find('h1').text(),
          body: this.editor.editable.html(),
          urlname: this.article.data('urlname'),
          category_id : this.article.data('category-id'),
          status: this.article.data('status')
        }
      },
      type: 'post',
      dataType: 'json'
    }).success(function(data) {
      AlertMessage.clear();
      _this.article.data('id', data.token);
      _this.updateViewButton(data);
      history.replaceState(null, null, '/articles/' + data.token + '/edit');
    }).error(function() {
      AlertMessage.error('Save Failed.');
    });
  },

  updateViewButton: function(data) {
    $('#view-button').attr('href', data.url);
    if (data.status === 'publish') {
      $('#view-button').closest('li').removeClass('hide');
    } else {
      $('#view-button').closest('li').addClass('hide');
    }
  },

  setPbulishClass: function(isPublish) {
    if (isPublish) {
      $('#draft-button').removeClass('button-actived');
      $('#publish-button').addClass('button-actived');
    } else {
      $('#publish-button').removeClass('button-actived');
      $('#draft-button').addClass('button-actived');
    }
  },

  publishArticle: function(event) {
    var _this = this;
    this.setPbulishClass(true);
    event.preventDefault();
      if (this.isPersisted()) {
      this.updateArticle({
        article: {
          status: 'publish'
        }
      }, null, function(data) {
        this.setPbulishClass(false);
        _this.article.data('status', 'draft');
      });
    } else {
      this.article.data('status', 'publish');
    }
  },

  draftArticle: function(event) {
    var _this = this;
    event.preventDefault();
    this.setPbulishClass(false);
    if (this.isPersisted()) {
      this.updateArticle({
        article: {
          status: 'draft'
        }
      }, null, function(data) {
        _this.setPbulishClass(true);
        this.article.data('status', 'publish');
      });
    } else {
      this.article.data('status', 'draft');
    }
  },

  pickUpTopbar: function() {
    $('body').toggleClass('pick-up-topbar');
    if ($('body').hasClass('pick-up-topbar')) {
      $.cookie('pick_up_topbar', true, { path: '/articles', expires: 14 });
    } else {
      $.removeCookie('pick_up_topbar',  { path: '/articles' });
    }
  }
};

page_ready(function() {
  if ($('body#articles-edit').length) {
    window.articleEdit = new ArticleEdit();
  }
});
