Scribble
========

A jekyll theme. [demo](http://chloerei.com/scribble/2013/10/11/placeholder-post/)
<br />

![screenshot](http://scribble.muan.co/images/screenshot.png)

This theme is fork from https://github.com/muan/scribble .

---

### Get started

1. [Fork the repository](https://github.com/chloerei/scribble/fork).
2. Clone the repository to your computer.<br /> `git clone https://github.com/username/scribble` .
3. `bundle install` .
4. Run serve and watch assets change using `rake`, go to http://localhost:4000 for your site.

---

### Replace theme for exists site

1. Remove all theme files in your project, and commit.
2. `git remote add scribble https://github.com/username/scribble` .
3. `git pull scribble master` and fix conflict.

---

### Make it yours

1. I have extract most user specific information to `_config.yml`, you should be able to set up almost everything from it.
2. Change about.md for blog intro.
3. For domain settings, see [the guide from GitHub](https://help.github.com/articles/setting-up-a-custom-domain-with-pages).

---

### Post options

When writing a post, there are 1 option you can add to the header.

1. `disqus: false`<br />
   Close Disqus for this post.

---

### Page options

When writing a page, there are 3 options you can add to the header.

1. `disqus: false`<br />
   Close Disqus for this post.
2. `prev_page: /path/to/prev_page`<br />
   Set the prev page path for pagination.
3. `next_page: /path/to/next_page`<br />
   Set the next page path for pagination.
