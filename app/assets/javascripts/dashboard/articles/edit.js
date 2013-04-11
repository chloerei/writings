//= require editor

Editor.Formator.prototype.link = function(url) {
  this.editor.restoreRange();

  if (url !== undefined) {
    if (this.isWraped('a')) {
      document.getSelection().selectAllChildren($(this.commonAncestorContainer()).closest('a')[0]);
    }
    if (url !== '') {
      this.exec('createLink', url);
    } else {
      this.exec('unlink');
    }

    this.afterFormat();
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
    this.exec('insertImage', url);

    this.afterFormat();
    Dialog.hide('#image-modal');
  } else {
    Dialog.show('#image-modal');
  }
};

var ImageUploader = function(editor) {
  this.editor = editor;
  var _this = this;

  // link form
  $('#image-link-button').on('click', function(event) {
    event.preventDefault();
    if ($('#attachment_remote_file_url').val() !== '') {
      _this.editor.formator.image($('#attachment_remote_file_url').val());
      _this.resetLinkForm();
    }
  });

  $('#attachment_remote_file_url').on('keyup', function() {
    if ($(this).val() !== '') {
      _this.linkPreview();
    } else {
      _this.resetLinkForm();
    }
  });

  $('#image-fetch-submit').on('click', function(e) {
    if ($('#attachment_remote_file_url').val() === '') {
      e.preventDefault();
    }
  });

  $('#image-link-form').on('submit', function(e) {
    e.preventDefault();
    $.ajax({
      url: $(this).attr('action'),
      data: $(this).serializeArray(),
      type: 'post',
      dataType: 'json'
    }).done(function(data) {
      _this.editor.formator.image(data.files[0].url);
      _this.updateStrageStatus(data);
    }).fail(function(xhr) {
      AlertMessage.error(JSON.parse(xhr.responseText).message);
    }).always(function() {
      _this.resetLinkForm();
    });
  });

  // upload form
  $('#image-upload-submit').on('click', function(e) {
    if ($('#image-upload .filename').text() === '') {
      e.preventDefault();
    }
  });

  $(document).bind('drop dragover', function (e) {
    e.preventDefault();
  });

  $('#image-upload-form').fileupload({
    dataType: 'json',
    dropZone: $('#image-upload-form .dropable, #editarea article'),
    add: function(e, data) {
      _this.uploadPreview(data);
      $('#image-upload .filename').text(data.files[0].name);
      $('#image-upload-form').off('submit');
      if ($('#image-modal').is(':hidden')) {
        data.submit();
      } else {
        $('#image-upload-form').on('submit', function(e) {
          e.preventDefault();
          data.submit();
        });
      }
    },
    start: function(e) {
      $('#image-upload .message').hide();
      $('#image-upload .progress').show();
      $('#image-upload .dropable').addClass('start');
      AlertMessage.loading('Uploading...');
    },
    progressall: function(e, data) {
      var progress = parseInt(data.loaded / data.total * 100, 10);
      $('#image-upload .progress .bar').css('width', progress + '%');
    },
    fail: function(e, data) {
      AlertMessage.error(JSON.parse(data.jqXHR.responseText).message);
    },
    done: function(e, data) {
      _this.editor.formator.image(data.result.files[0].url);
      _this.updateStrageStatus(data.result);
      AlertMessage.success('Success');
    },
    always: function(e, data) {
      _this.resetUploadForm();
    }
  });

};

ImageUploader.prototype = {
  updateStrageStatus: function(data) {
    $('#image-modal .storage-status .used').text(data.storage_status.used_human_size);
    $('#image-modal .storage-status .limit').text(data.storage_status.limit_human_size);
  },

  linkPreview: function() {
    $('#image-link-form .preview').css('background-image', 'url(' + $('#attachment_remote_file_url').val() + ')');
    $('#image-link-form .message').hide();
  },

  resetLinkForm: function() {
    console.log('hit');
    $('#attachment_remote_file_url').val('');
    $('#image-link-form .preview').css('background-image', 'none');
    $('#image-link-form .message').show();
  },

  uploadPreview: function(data) {
    if (window.FileReader) {
      if (/(jpg|jpeg|gif|png)/i.test(data.files[0].name)) {
        var reader = new FileReader();
        reader.onload = function(e) {
          $('#image-upload .message').hide();
          $('#image-upload-form .dropable').css('background-image', 'url(' + e.target.result + ')');
        };
        reader.readAsDataURL(data.files[0]);
      } else {
        $('#image-upload-form .dropable').css('background-image', 'none');
        $('#image-upload .message').show();
      }
    }
  },

  resetUploadForm: function() {
    $('#image-upload .filename').text('');
    $('#image-upload-form').off('submit');
    $('#image-upload .progress').hide();
    $('#image-upload .progress .bar').css('width', '0%');
    if (window.FileReader) {
      $('#image-upload-form .dropable').css('background-image', 'none');
    }
    $('#image-upload .message').show();
    $('#image-upload .dropable').removeClass('start');
  }
};

var ArticleEdit = function() {
  this.editor = new Editor({
    toolbar: '#toolbar',
    editable: '#editarea article'
  });
  this.imageUploader = new ImageUploader(this.editor);

  this.article = $('#editarea article');

  this.saveCount = this.article.data('saveCount');

  this.connect('#urlname-form', 'submit', this.saveUrlname);
  this.connect('#save-status .retry a', 'click', this.saveArticle);
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

  this.article.on('editor:change', function() {
    _this.saveArticle();
  });

  $('#link-form').on('submit', function(event) {
    event.preventDefault();
    _this.editor.formator.link($(this).find('input[name=url]').val());
  });

  $('#unlink-button').on('click', function(event) {
    event.preventDefault();
    _this.editor.formator.link('');
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

  saveStart: function() {
    this.saveCount = this.saveCount + 1;
    $('#save-status .saving').show().siblings().hide();
  },

  saveCompelete: function(data) {
    if (data.save_count === this.saveCount) {
      AlertMessage.clear();
      $('#save-status .saved').attr('title', data.updated_at).show().siblings().hide();
    }
  },

  saveError: function(xhr) {
    try {
      AlertMessage.error($.parseJSON(xhr.responseText).message || 'Save Failed');
    } catch(err) {
      AlertMessage.error('Server Error');
    }
    $('#save-status .retry').show().siblings().hide();
  },

  updateArticle: function(data, success_callback, error_callback) {
    var _this = this;
    _this.saveStart();
    data.article.save_count = _this.saveCount;
    $.ajax({
      url: '/articles/' + this.article.data('id'),
      data: data,
      type: 'put',
      dataType: 'json'
    }).success(function(data) {
      _this.saveCompelete(data);
      _this.updateViewButton(data);
      if (success_callback) {
        success_callback(data);
      }
    }).error(function(xhr) {
      _this.saveError(xhr);
      if (error_callback) {
        error_callback();
      }
    });
  },

  saveUrlname: function(event) {
    event.preventDefault();
    var urlname = $('#article-urlname').val();
    if (this.isPersisted()) {
      this.updateArticle({
        article: {
          urlname: urlname
        }
      }, function(data) {
        Dialog.hide('#urlname-modal');
      });
    } else {
      this.article.data('urlname', urlname);
      this.createArticle();
      Dialog.hide('#urlname-modal');
    }
  },

  saveCategory: function(event) {
    event.preventDefault();
    var categoryId = $('#article-category-id').val();
    var categoryName = $('#category-form .dropdown-toggle').text();
    var _this = this;
    if (this.isPersisted()) {
      this.updateArticle({
        article: {
          category_id: categoryId
        }
      }, function(data) {
        _this.article.data('category-id', categoryId);
        Dialog.hide('#select-category-modal');
      });
    } else {
      this.article.data('category-id', categoryId);
      this.createArticle();
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
    if (event) {
      event.preventDefault();
    }
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
    _this.saveStart();

    if (_this.creating === true) {
      return;
    }

    _this.creating = true;
    $.ajax({
      url: '/articles',
      data: {
        article: {
          title: this.editor.editable.find('h1').text(),
          body: this.editor.editable.html(),
          urlname: this.article.data('urlname'),
          category_id : this.article.data('category-id'),
          status: this.article.data('status')
        },
        saveCount: _this.saveCount
      },
      type: 'post',
      dataType: 'json'
    }).done(function(data) {
      _this.saveCompelete(data);
      _this.article.data('id', data.token);
      _this.updateViewButton(data);
      history.replaceState(null, null, '/articles/' + data.token + '/edit');
      _this.saveArticle(); // save change between ajax response
    }).fail(function(xhr) {
      _this.saveError(xhr);
      $('#save-status .retry').show().siblings().hide();
    }).always(function() {
      _this.creating = false;
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
      this.createArticle();
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
      this.createArticle();
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
